import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_drama_dictionary/word_drama_dictionary.dart';

void main() {
  late WordDramaDictionary dictionary;

  setUpAll(() {
    dictionary = WordDramaDictionary.fromWordList(
      File('assets/words.txt').readAsStringSync(),
    );
  });

  test('accepts common, unusual, and inflected words', () {
    expect(dictionary.isValidWord('cat'), isTrue);
    expect(dictionary.isValidWord('FLAKE'), isTrue);
    expect(dictionary.isValidWord('flakes'), isTrue);
    expect(dictionary.isValidWord('flaking'), isTrue);
    expect(dictionary.isValidWord('OHO'), isTrue);
    expect(dictionary.isValidWord('QI'), isTrue);
    expect(dictionary.isValidWord('ZA'), isTrue);
    expect(dictionary.isValidWord('JO'), isTrue);
  });

  test('rejects curated non-words, invalid input, and invalid lengths', () {
    for (final word in [
      'FBI',
      'NASA',
      'AARON',
      'OHIO',
      'QXZ',
      'CIA',
      'NSA',
      'IRS',
      'EPA',
      'FAA',
      'FDA',
      'NATO',
      'UNESCO',
      'UEFA',
      'GPS',
      'HTTP',
      'URL',
      'PDF',
      'DR',
      'MR',
      'MRS',
      'INC',
      'LTD',
      'PARIS',
      'LONDON',
      '',
      'A',
      'CAN\'T',
      'TWO-WORD',
      'A1'
    ]) {
      expect(dictionary.isValidWord(word), isFalse, reason: word);
    }
    expect(dictionary.isValidWord(null), isFalse);
    expect(dictionary.isValidWord('ABCDEFGHI'), isFalse);
    expect(dictionary.isValidWord('AARDVARK'), isTrue);
    expect(dictionary.isValidWord('AARDVARKS'), isFalse);
  });

  test('supports one-letter prefixes and rejects dead prefixes', () {
    expect(dictionary.isValidPrefix('f'), isTrue);
    expect(dictionary.isValidPrefix('flak'), isTrue);
    expect(dictionary.isValidPrefix('flake'), isTrue);
    expect(dictionary.isValidPrefix('qxz'), isFalse);
    expect(dictionary.isValidPrefix('a-'), isFalse);
    expect(dictionary.isValidPrefix(''), isFalse);
    expect(dictionary.isValidPrefix(null), isFalse);
    expect(dictionary.isValidPrefix('ABCDEFGHI'), isFalse);
  });

  test('checks whether an appended letter remains playable', () {
    expect(dictionary.canExtendWord('FLAK', 'E'), isTrue);
    expect(dictionary.canExtendWord('FLAKE', 'S'), isTrue);
    expect(dictionary.canExtendWord('Q', 'I'), isTrue);
    expect(dictionary.canExtendWord('FLAKE', '1'), isFalse);
    expect(dictionary.canExtendWord('ABCDEFGH', 'I'), isFalse);
    expect(dictionary.canExtendWord('QXZ', 'A'), isFalse);
    expect(dictionary.canExtendWord(null, 'A'), isFalse);
  });

  test('fails safely for an unavailable asset before initialization', () async {
    final result = await WordDramaDictionary.tryInitialize(
      assetLoader: (_) => Future<String>.error(StateError('not found')),
    );
    expect(result, isNull);
  });

  test('initializes once and gives consistent repeated lookups', () async {
    Future<String> loader(String _) => File('assets/words.txt').readAsString();
    final first = await WordDramaDictionary.initialize(assetLoader: loader);
    final second = await WordDramaDictionary.initialize(assetLoader: loader);
    expect(identical(first, second), isTrue);
    expect(first.isValidWord('flake'), second.isValidWord('FLAKE'));
  });
}
