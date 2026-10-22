# FlutterFlow integration

This package is independent of the Word Drama FlutterFlow project. Add it only
through FlutterFlow's **Custom Dependencies** panel after publishing this
directory to its own GitHub repository.

## Repository layout

Publish this directory as the repository root. Keep `pubspec.yaml`, `lib/`,
`assets/`, `licenses/`, `NOTICE`, `tool/`, and `vendor/` together. The
package asset declaration in `pubspec.yaml` is required; a Dart dependency by
itself does not make package assets accessible.

## Custom Dependency

In FlutterFlow, add a Git dependency using the repository URL and a tag or
commit SHA, for example:

```yaml
word_drama_dictionary:
  git:
    url: https://github.com/YOUR_ORG/word_drama_dictionary.git
    ref: v0.1.0
```

Use an immutable release tag or commit SHA for production builds.

## Initialize once

Create a FlutterFlow Custom Action with no return value and this body:

```dart
import 'package:word_drama_dictionary/word_drama_dictionary.dart';

await WordDramaDictionary.initialize();
```

Run it during app startup before banking or placement actions. The default
loader calls:

```dart
rootBundle.loadString('packages/word_drama_dictionary/assets/words.txt')
```

That `packages/<package>/...` path is the Flutter package-asset convention and
depends on the `flutter: assets:` declaration shipped by this package.

If initialization fails, `tryInitialize()` returns `null`; use that to disable
dictionary-dependent gameplay or show a retry message rather than accepting
unchecked banks.

## Complete-word validation for BANK

Create a FlutterFlow Custom Function or Custom Action that imports the package
and delegates to the initialized instance you retain in application-level code:

```dart
bool isBankableWord(WordDramaDictionary dictionary, String word) {
  return dictionary.isValidWord(word);
}
```

Wire the result into the existing `onBank` conditional. Do not call the
dictionary before initialization, and do not reparse the asset on each tap.

## Prefix validation for placement and offers

For a prospective placement use:

```dart
dictionary.canExtendWord(currentWord, letter)
```

For a partial string use:

```dart
dictionary.isValidPrefix(prefix)
```

These methods reject punctuation, digits, unsupported characters, and words
longer than eight characters. One-letter prefixes are supported.

## FlutterFlow limitations

- FlutterFlow still requires manual Custom Dependency setup and Custom Action
  configuration; it cannot infer package-asset use from an import.
- A Custom Function cannot await initialization. Initialize once in a Custom
  Action before invoking synchronous validation functions.
- For a global cached dictionary instance, use a small Custom Action/service
  layer in FlutterFlow custom code. Avoid recreating `WordDramaDictionary` in
  each callback.
- This package supplies lexical validation only. It does not choose fair offers
  or guarantee that a given rack has a playable extension.
