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
  late Structure structureActuelle;
  _PageAffichageStructureState(Structure structureMere) {
    structureActuelle = structureMere;
    print(structureMere.nom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Le mémoire")),
      body: Container(
        child: Column(children: [
          Text(structureActuelle.nom),
          Text("Lien : "),
          Text(structureActuelle.lien.toString()),
          Text("Description :"),
          Text(structureActuelle.description),
          Text("Image :"),
          // Image(image: AssetImage("assets/480538.png"))
        ]),
      ),
    );
  }
}
