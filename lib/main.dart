
import 'package:flutter/material.dart';
import 'PageSaisie.dart';

/// Flutter code sample for [TextButton].

// Variables
// final List<Widget> _listDeproposition = [];
// Map<String, (Structure, bool)> _structures = HashMap();
// List<Structure> structures = [];

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Mémoire",
      home: PagePrincipal(title: 'Mémoire'),
    );
  }
}
