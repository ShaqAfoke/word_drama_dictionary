import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_drama_dictionary/word_drama_dictionary.dart';

void main() {
  test('measures initialization and repeated lookup performance', () {
    final source = File('assets/words.txt').readAsStringSync();
    final initialization = Stopwatch()..start();
    final dictionary = WordDramaDictionary.fromWordList(source);
    initialization.stop();

    const queries = ['FLAKE', 'OHO', 'QI', 'ZA', 'JO', 'QXZ', 'FLAK', 'A'];
    const iterations = 100000;
    final lookups = Stopwatch()..start();
    var trueResults = 0;
    for (var index = 0; index < iterations; index++) {
      if (dictionary.isValidWord(queries[index % queries.length])) {
        trueResults++;
      }
      if (dictionary.isValidPrefix(queries[(index + 1) % queries.length])) {
        trueResults++;
      }
    }
    lookups.stop();

    // Printed by `flutter test --reporter expanded` for release tracking.
    // ignore: avoid_print
    print('dictionary_words=${dictionary.wordCount} '
        'initialization_ms=${initialization.elapsedMilliseconds} '
        'lookups=${iterations * 2} '
        'lookup_total_ms=${lookups.elapsedMilliseconds} '
        'lookup_true_results=$trueResults');

    expect(dictionary.wordCount, greaterThan(0));
    expect(trueResults, greaterThan(0));
  });
}
