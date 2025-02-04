import 'package:flutter/material.dart';
import 'package:memoire/Structure.dart';

class PageAffichageStructure extends StatefulWidget {
  Structure? structure;
  List<String> lienPremier;
  List<String> lienSecond;

  PageAffichageStructure(
      {required this.structure,
      required this.lienPremier,
      required this.lienSecond,
      super.key});

  @override
  State<PageAffichageStructure> createState() =>
      _PageAffichageStructureState(structure, lienPremier, lienSecond);
}

class _PageAffichageStructureState extends State<PageAffichageStructure> {
  late Structure structureActuelle;
  late List<String> lienPremier;
  late List<String> lienSecond;

  _PageAffichageStructureState(
      Structure? structureMere, this.lienPremier, this.lienSecond) {
    structureActuelle = structureMere!;
  }

  Widget makeLink(List<String> liens) {
    List<Widget> linkList = [];
    for (String lien in liens) {
      if (lienPremier.contains(lien.trim())) {
        linkList.add(Chip(backgroundColor: Colors.red, label: Text(lien)));
      } else if (lienSecond.contains(lien.trim())) {
        linkList.add(Chip(backgroundColor: Colors.orange, label: Text(lien)));
      } else {
        // linkList.add(Chip(label: Text(lien)));
      }
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20.0,
      runSpacing: 10.0,
      children: linkList,
    );
  }

  Widget makeDescription() {
    if (structureActuelle.description.isNotEmpty) {
      return Column(children: [
        Divider(),
        Text(
          "Description :",
          style: TextStyle(fontSize: 20),
        ),
        Text(
          structureActuelle.description,
          style: TextStyle(fontSize: 16),
        )
      ]);
    }
    return Column(
      children: [],
    );
  }

  Widget makeImage() {
    if (structureActuelle.image.isNotEmpty) {
      return Column(children: [
        Divider(),
        Text(
          "Image :",
          style: TextStyle(fontSize: 20),
        ),
        Expanded(
          child: Image.network(
            structureActuelle.image,
          ),
        ),
      ]);
    }
    return Column(
      children: [],
    );
  }

  Widget makeTips() {
    if (structureActuelle.tips.isNotEmpty) {
      return Column(children: [
        Divider(),
        Text(
          "Mise en evidence :",
          style: TextStyle(fontSize: 20),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width * 3 / 5,
            child: Text(
              structureActuelle.tips,
              overflow: TextOverflow.fade,
            ),
          ),
        )
      ]);
    }
    return Column(
      children: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(structureActuelle.tips);
    return Scaffold(
        appBar: AppBar(title: const Text("Fiche de la structure")),
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                structureActuelle.nom,
                style: TextStyle(fontSize: 30),
              ),
              Text(
                "Lien : ",
                style: TextStyle(fontSize: 20),
              ),
              Container(
                  margin: EdgeInsets.all(5),
                  child: Text(
                    "En rouge, tu vas retrouver les structures disfonctionnelle de l'examen cinique en lien direct avec " +
                        structureActuelle.nom +
                        ".\nEn orange, les structure entre le " +
                        structureActuelle.nom +
                        " et les structures dysfonctionnelles de l'examen clinique.",
                    style: TextStyle(fontSize: 13),
                  )),
              makeLink(structureActuelle.lien),
              makeDescription(),
              Divider(),
              Expanded(
                  child: Row(
                children: [makeImage(), VerticalDivider(), makeTips()],
              ))
            ],
          ),
        ));
  }
}
