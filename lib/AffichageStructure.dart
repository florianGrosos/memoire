import 'package:flutter/material.dart';
import 'package:memoire/Structure.dart';

class PageAffichageStructure extends StatefulWidget {
  Structure structure;

  PageAffichageStructure({super.key, required Structure this.structure});

  @override
  State<PageAffichageStructure> createState() =>
      _PageAffichageStructureState(structure);
}

class _PageAffichageStructureState extends State<PageAffichageStructure> {
  _PageAffichageStructureState(Structure structureMere) {
    print(structureMere.nom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("memoire")),
      body: Container(
        child: const Column(children: []),
      ),
    );
  }
}
