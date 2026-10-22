# word_drama_dictionary

An offline Flutter dictionary package for Word Drama. It provides repeatable
complete-word and prefix validation from a locally bundled, filtered Wordnik
game-wordlist snapshot.

## What it does

- Validates complete A-Z words from 2 through 8 letters.
- Validates prefixes from 1 through 8 letters.
- Tests whether appending one letter can remain a valid word or prefix.
- Loads the bundled package asset once and reuses immutable in-memory indexes.
- Uses no network, API key, subscription, or third-party runtime dependency.

The generated word list includes accepted ordinary, unusual, short, and
interjection words such as `FLAKE`, `OHO`, `QI`, `ZA`, and `JO`; it also keeps
ordinary inflections such as `FLAKES` and `FLAKING`.

## Use

```dart
import 'package:word_drama_dictionary/word_drama_dictionary.dart';

final dictionary = await WordDramaDictionary.initialize();

dictionary.isValidWord('flake');       // true
dictionary.isValidPrefix('flak');      // true
dictionary.canExtendWord('flak', 'e'); // true
```

`isValidWord` and `isValidPrefix` normalize surrounding whitespace and case,
then reject digits, punctuation, spaces, apostrophes, hyphens, and strings
outside their supported lengths. `canExtendWord` requires exactly one A-Z
letter and never permits a result longer than eight letters.

Call `initialize()` during application startup. It loads
`packages/word_drama_dictionary/assets/words.txt`, which is declared in this
package's `pubspec.yaml`. Repeated calls share the same initialized dictionary.
For startup flows that must not throw, use `tryInitialize()` and handle `null`.

## Source, filtering, and license

The source snapshot is the [Wordnik game wordlist](https://github.com/wordnik/wordlist),
MIT licensed, Copyright (c) 2020 Wordnik. The source and its license remain in
`vendor/wordnik_wordlist/` and `licenses/WORDNIK_LICENSE`; see `NOTICE`.

The package intentionally does not treat the source as semantic proof. The
reproducible filter accepts only 2-8 character A-Z entries and applies the
reviewable decisions in `tool/curation/`. It does not drop words merely for
being rare, short, interjections, or having another acronym/name sense.

```sh
dart run tool/build_dictionary.dart
```

Read `docs/filtering_report.md` for actual counts, exclusions, limitations,
and review policy. The list is a temporary game-validation corpus; it does not
guarantee every offer creates a playable extension or replace later offline
fairness logic.

## Verification

```sh
flutter test
dart analyze
flutter test test/performance_test.dart --reporter expanded
cd example && flutter test --reporter expanded
```

See [FlutterFlow integration](docs/flutterflow_integration.md) for the GitHub
Custom Dependency, package-asset, initialization, banking, and prefix-check
setup. This repository contains no Word Drama application source.
