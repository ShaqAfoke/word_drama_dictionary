import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;

/// Loads a package asset. Supplying a loader makes the dictionary easy to use
/// in applications with a different asset system and easy to test offline.
typedef DictionaryAssetLoader = Future<String> Function(String assetPath);

/// Thrown when the bundled dictionary cannot be loaded or is malformed.
final class DictionaryInitializationException implements Exception {
  DictionaryInitializationException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'DictionaryInitializationException: $message';
}

/// Immutable offline dictionary for complete-word and prefix checks.
///
/// Call [initialize] once during application startup and retain the returned
/// instance. Repeated calls share the same in-memory instance. The default
/// loader reads this package's declared Flutter asset, not an app-local path.
final class WordDramaDictionary {
  WordDramaDictionary._(this._words, this._prefixes);

  static const assetPath = 'packages/word_drama_dictionary/assets/words.txt';

  static WordDramaDictionary? _shared;
  static Future<WordDramaDictionary>? _initializing;

  final Set<String> _words;
  final Set<String> _prefixes;

  /// Initializes the bundled dictionary once.
  static Future<WordDramaDictionary> initialize({
    DictionaryAssetLoader? assetLoader,
  }) {
    final existing = _shared;
    if (existing != null) return Future.value(existing);

    return _initializing ??= _load(assetLoader).then((dictionary) {
      _shared = dictionary;
      return dictionary;
    }).whenComplete(() {
      _initializing = null;
    });
  }

  /// A non-throwing initialization alternative for startup flows that need to
  /// disable banking gracefully when a packaged asset is unavailable.
  static Future<WordDramaDictionary?> tryInitialize({
    DictionaryAssetLoader? assetLoader,
  }) async {
    try {
      return await initialize(assetLoader: assetLoader);
    } on DictionaryInitializationException {
      return null;
    }
  }

  static Future<WordDramaDictionary> _load(
    DictionaryAssetLoader? assetLoader,
  ) async {
    try {
      final source = await (assetLoader ?? rootBundle.loadString)(assetPath);
      return WordDramaDictionary.fromWordList(source);
    } catch (error) {
      if (error is DictionaryInitializationException) rethrow;
      throw DictionaryInitializationException(
        'Unable to load the bundled dictionary asset at $assetPath.',
        error,
      );
    }
  }

  /// Parses generated newline-delimited uppercase words. Public for offline
  /// testing and alternate build systems; regular apps should use [initialize].
  factory WordDramaDictionary.fromWordList(String source) {
    final words = <String>{};
    final prefixes = <String>{};

    for (final rawLine in source.split(RegExp(r'\r?\n'))) {
      final word = rawLine.trim().toUpperCase();
      if (!_isDictionaryWord(word)) continue;
      words.add(word);
      for (var length = 1; length <= word.length; length++) {
        prefixes.add(word.substring(0, length));
      }
    }

    if (words.isEmpty) {
      throw DictionaryInitializationException(
        'The bundled dictionary contained no valid 2–8 letter words.',
      );
    }
    return WordDramaDictionary._(
      Set.unmodifiable(words),
      Set.unmodifiable(prefixes),
    );
  }

  /// True only for an accepted complete word from two through eight letters.
  bool isValidWord(String? word) {
    final normalized = _normalize(word);
    return normalized != null && _words.contains(normalized);
  }

  /// True if [prefix] begins at least one accepted word of at most eight
  /// letters. One-letter prefixes are deliberately supported.
  bool isValidPrefix(String? prefix) {
    final normalized = _normalize(prefix, minimumLength: 1);
    return normalized != null && _prefixes.contains(normalized);
  }

  /// True if appending one letter can yield a complete accepted word or an
  /// accepted prefix. Invalid characters and strings beyond eight letters are
  /// rejected without throwing.
  bool canExtendWord(String? currentWord, String? letter) {
    final current = _normalize(currentWord, minimumLength: 0);
    final nextLetter = _normalize(letter, minimumLength: 1, maximumLength: 1);
    if (current == null || nextLetter == null) return false;
    final candidate = '$current$nextLetter';
    if (candidate.length > 8) return false;
    return _words.contains(candidate) || _prefixes.contains(candidate);
  }

  /// Exposed for diagnostics and performance reporting; it is not game state.
  int get wordCount => _words.length;

  static String? _normalize(
    String? input, {
    int minimumLength = 2,
    int maximumLength = 8,
  }) {
    if (input == null) return null;
    final normalized = input.trim().toUpperCase();
    if (normalized.length < minimumLength ||
        normalized.length > maximumLength) {
      return null;
    }
    return RegExp(r'^[A-Z]+$').hasMatch(normalized) ? normalized : null;
  }

  static bool _isDictionaryWord(String word) =>
      word.length >= 2 &&
      word.length <= 8 &&
      RegExp(r'^[A-Z]+$').hasMatch(word);
}
