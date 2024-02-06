import 'package:flutter/material.dart';
import 'package:memoire/selection_unite_fonctionnelle.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Text title = Text("Mémoire");
    // return SelectionUF(title: title);
    return MaterialApp(
      title: "Mémoire",
      home: SelectionUF(title: title),
      debugShowCheckedModeBanner: false,
    );
  }
}
