import 'package:flutter_test/flutter_test.dart';
import 'package:word_drama_dictionary/word_drama_dictionary.dart';

void main() {
  testWidgets('loads the dependency asset through the package asset path',
      (tester) async {
    final dictionary = await tester.runAsync(WordDramaDictionary.initialize);
    expect(dictionary, isNotNull);
    final loaded = dictionary!;
    expect(loaded.isValidWord('FLAKE'), isTrue);
    expect(loaded.isValidPrefix('F'), isTrue);
  });
}
