// Reproducibly filters the vendored Wordnik game wordlist into the package
// asset. Run from the package root with `dart run tool/build_dictionary.dart`.
import 'dart:convert';
import 'dart:io';

const _sourcePath = 'vendor/wordnik_wordlist/wordlist-20210729.txt';
const _allowlistPath = 'tool/curation/allowlist.txt';
const _denylistPath = 'tool/curation/denylist.txt';
const _assetPath = 'assets/words.txt';
const _reportPath = 'docs/filtering_report.md';

Future<void> main() async {
  final source = File(_sourcePath);
  if (!source.existsSync()) {
    stderr.writeln('Missing vendored source: $_sourcePath');
    exitCode = 2;
    return;
  }

  final allow = _readCurationFile(_allowlistPath);
  final deny = _readCurationFile(_denylistPath);
  final accepted = <String>{};
  final rejected = <String, int>{
    'invalid_json_or_non_string': 0,
    'unsupported_characters': 0,
    'outside_2_to_8_letters': 0,
    'curated_denylist': 0,
    'duplicate': 0,
  };
  var originalCount = 0;

  for (final raw in await source.readAsLines()) {
    if (raw.trim().isEmpty) continue;
    originalCount++;
    String? entry;
    try {
      final decoded = jsonDecode(raw);
      entry = decoded is String ? decoded : null;
    } on FormatException {
      // The upstream file is JSON-lines. Treat malformed rows as reviewable
      // source errors rather than guessing at their meaning.
    }
    if (entry == null) {
      rejected['invalid_json_or_non_string'] =
          rejected['invalid_json_or_non_string']! + 1;
      continue;
    }

    final word = entry.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]+$').hasMatch(word)) {
      rejected['unsupported_characters'] =
          rejected['unsupported_characters']! + 1;
      continue;
    }
    if (word.length < 2 || word.length > 8) {
      rejected['outside_2_to_8_letters'] =
          rejected['outside_2_to_8_letters']! + 1;
      continue;
    }
    if (deny.contains(word)) {
      rejected['curated_denylist'] = rejected['curated_denylist']! + 1;
      continue;
    }
    if (!accepted.add(word)) {
      rejected['duplicate'] = rejected['duplicate']! + 1;
    }
  }

  final missingAllowlist =
      allow.where((word) => !accepted.contains(word)).toList()..sort();
  if (missingAllowlist.isNotEmpty) {
    stderr.writeln(
      'Curated retain entries were not accepted from the vendored source: '
      '${missingAllowlist.join(', ')}',
    );
    exitCode = 3;
    return;
  }

  final sorted = accepted.toList()..sort();
  await File(_assetPath).writeAsString('${sorted.join('\n')}\n');
  await File(_reportPath).writeAsString(_buildReport(
    originalCount: originalCount,
    acceptedCount: sorted.length,
    rejected: rejected,
    allowCount: allow.length,
    denyCount: deny.length,
    missingAllowlist: missingAllowlist,
  ));

  stdout.writeln(
    'Built $_assetPath with ${sorted.length} accepted words from '
    '$originalCount source entries.',
  );
}

Set<String> _readCurationFile(String path) {
  return File(path)
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .map((line) => line.toUpperCase())
      .toSet();
}

String _buildReport({
  required int originalCount,
  required int acceptedCount,
  required Map<String, int> rejected,
  required int allowCount,
  required int denyCount,
  required List<String> missingAllowlist,
}) {
  final exclusions = rejected.entries
      .map((entry) => '| `${entry.key}` | ${entry.value} |')
      .join('\n');
  return '''# Dictionary filtering report

## Source

- Source: Wordnik game wordlist, `wordlist-20210729.txt`
- Vendored revision: `46e6215d0f90356afe9c8ba4be347e7e98cb425c`
- License: MIT, Copyright (c) 2020 Wordnik; see `licenses/WORDNIK_LICENSE`.
- Build command: `dart run tool/build_dictionary.dart`

## Counts

| Measure | Count |
| --- | ---: |
| Original source entries | $originalCount |
| Accepted A-Z words (2-8 letters) | $acceptedCount |
| Curated retain entries checked | $allowCount |
| Curated rejected entries | $denyCount |

## Exclusions

| Reason | Count |
| --- | ---: |
$exclusions

## Ambiguous entries and review

The review register is `tool/curation/review_words.md`. It deliberately keeps
FLAKE, FLAKES, FLAKING, OHO, QI, ZA, and JO when present in the source.
No word is rejected for rarity, short length alone, an interjection use, or a
possible acronym/name use. The current curated denylist rejects only explicit,
reviewable entries: FBI, NASA, AARON, OHIO, and QXZ.

Missing curated retain entries: ${missingAllowlist.isEmpty ? 'none' : missingAllowlist.join(', ')}.

## Limitations

The source does not supply lexical labels or definitions. This filter enforces
format and length mechanically and applies only documented curated decisions;
it cannot prove that every remaining source entry is an ordinary English word
or identify every proper noun or abbreviation. Ambiguous words are retained
for review rather than automatically classified from capitalization, rarity,
or length. The generated data is suitable for offline game validation, not a
claim of exhaustive dictionary authority or guaranteed playable moves.
''';
}
