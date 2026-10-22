import 'package:flutter/material.dart';
import 'package:word_drama_dictionary/word_drama_dictionary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dictionary = await WordDramaDictionary.initialize();
  runApp(_ExampleApp(wordCount: dictionary.wordCount));
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp({required this.wordCount});

  final int wordCount;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Text('Words: $wordCount')));
  }
}
