// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:memoire/PageResultat.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
import 'Structure.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class PagePrincipal extends StatefulWidget {
  final Text title;
  final List<String> fonctionnalUnityList;
  PagePrincipal(this.title, this.fonctionnalUnityList, {super.key});

  @override
  State<PagePrincipal> createState() =>
      // ignore: no_logic_in_create_state
      _PagePrincipalState(title, fonctionnalUnityList);
}

class _PagePrincipalState extends State<PagePrincipal> {
  Text title;
  List<String> fonctionnalUnityList;
  List<Structure> structures = [];
  List<Structure> structureSelect = [];

  _PagePrincipalState(this.title, this.fonctionnalUnityList);

  int tailleDonne = 10;

  // Suppression des espaces en début et en fin de mot
  String miseAuPropre(String chaine) {
    chaine = chaine.trim();
    return chaine;
  }

  Future<List<Structure>> createData() async {
    List<Structure> struc = [];
    List<List<dynamic>> donneebrut = [];
    var rawData = await rootBundle.loadString("assets/donnee.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    // tailleDonne = listData.length;
    donneebrut = listData;
    for (var donnee in donneebrut.sublist(1)) {
      if (donnee[0] != "") {
        //On oublie les lignes vides
        //traitement pour supprimé les espace de début et de fin de nom
        if (donnee[0] != "") donnee[0] = donnee[0].trim();
        //création de la liste et filtrage des strings des liens
        List<String> lien = [];

        lien =
            donnee[2].split("/") + donnee[3].split("/") + donnee[4].split("/");
        // purge de la liste des '' ou des ' '
        while (lien.contains('')) {
          lien.remove('');
        }
        while (lien.contains(' ')) {
          lien.remove(' ');
        }
        for (var cpt = 0; cpt < lien.length; cpt++) {
          if (lien[cpt].isNotEmpty) {
            lien[cpt] = lien[cpt].trim();
          }
        }
        if (donnee[1].toString()[0] == "/") {
          donnee[1] =
              donnee[1].toString().substring(1, donnee[1].toString().length);
        }
        if (donnee[1].toString()[donnee[1].toString().length - 1] == "/") {
          donnee[1] = donnee[1]
              .toString()
              .substring(0, donnee[1].toString().length - 1);
        }
        List<String> listUF = donnee[1].split("/");
        // for (String uf in listUF) {
        //   uf = uf.trim();
        // }

        //Création de la liste de toutes les structures
        struc.add(Structure(
            donnee[0], donnee[5], lien, donnee[6], donnee[7], listUF));
      }
    }

    for (var structure in struc) {
      // A faire en regex ou .contains
      if (structure.nom.length > 2) {
        if (structure.nom.substring(0, 2) == 'M.') {
          structure.type = "Muscle";
        }
      }
      if (structure.nom.length > 12) {
        if (structure.nom.substring(0, 12) == 'Articulation') {
          structure.type = "Articulation";
        }
      }
      if (structure.nom.length > 5) {
        if (structure.nom.substring(0, 6) == 'Plexus') {
          structure.type = "Nerf";
        }
      }
      if (structure.nom.length > 3) {
        if (structure.nom.substring(0, 4) == 'Nerf') {
          structure.type = "Nerf";
        }
      }
      if (structure.type == "") {
        structure.type = "Os";
      }
    }
    return struc;
  }

  Map<String, Structure> generateMapNameToStructure(List<Structure> struc) {
    Map<String, Structure> res = {};
    for (var structure in struc) {
      res[structure.nom] = structure;
    }
    return res;
  }

  @override
  initState() {
    createData().then((value) {
      setState(() {
        structures = value;
      });
    });
    super.initState();
  }

  Color choiceColor(typeStructure) {
    switch (typeStructure) {
      case "Muscle":
        return const Color.fromARGB(255, 252, 76, 36);
      case "Articulation":
        return const Color.fromARGB(255, 44, 120, 242);
      case "Nerf":
        return const Color.fromARGB(255, 252, 242, 51);
      case "Os":
        return const Color.fromARGB(255, 255, 255, 255);
    }
    return const Color.fromARGB(255, 255, 255, 255);
  }

  Widget UFSelectedView() {
    final List<Widget> UFlistTile = [];
    for (var UFName in fonctionnalUnityList) {
      UFlistTile.add(Text(
        "- " + UFName,
        style: TextStyle(fontSize: 17),
      ));
    }

    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.topLeft,
          child: const Text(
            "UF sélectionnée(s)",
            style: TextStyle(fontSize: 20),
          )),
      Container(
          margin: EdgeInsets.fromLTRB(70, 4, 4, 4),
          child: Column(
            children: UFlistTile,
            crossAxisAlignment: CrossAxisAlignment.start,
          ))
    ]));
  }

  Widget donneeList(Color? color, String text) {
    return Container(
        margin: EdgeInsets.fromLTRB(70, 4, 4, 4),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: color,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 15),
        ));
  }

  @override
  Widget build(BuildContext context) {
    const double textSize = 1.4;
    Map<String, Structure> mapNameToStructure = {};
    mapNameToStructure = generateMapNameToStructure(structures);

    return Scaffold(
      appBar: AppBar(
          title: Text(
              "Sélection des dysfonctions retrouvées à l'examen clinique")),
      body: Row(children: [
        SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: MultipleSearchSelection(
              items: structures,
              pickedItemBuilder: (structure) {
                return Container(
                  decoration: BoxDecoration(
                    color: choiceColor(structure.type),
                    border:
                        Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(structure.nom),
                  ),
                );
              },
              fieldToCheck: (val) {
                return val.nom;
              },
              itemBuilder: (structure, nbInconnu) {
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: choiceColor(structure.type),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [Text(structure.nom)],
                      ),
                    ),
                  ),
                );
              },
              onItemAdded: (p0) {
                structureSelect.add(p0);
              },
              onItemRemoved: (p0) {
                structureSelect.remove(mapNameToStructure[p0.nom]);
              },
              hintText: "Rechercher",
              maximumShowItemsHeight:
                  MediaQuery.of(context).size.height * (6 / 10),
              pickedItemsContainerMaxHeight: 100,
            )),
        SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3)),
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    "Maintenant, sélectionne les structures anatomiques dysfonctionnelles retrouvées à l'examen clinique",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ),
                ),
                Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                          margin: EdgeInsets.all(10),
                          child: const Text(
                            "Pour cela, tu peux utiliser la barre de recheche ou retrouver les structures dans le menu déroulant sachant que les couleurs correspondent à un type de structure anatomique :",
                            style: TextStyle(fontSize: 14),
                          )),
                      donneeList(choiceColor("Articulation"), "- Articulation"),
                      donneeList(choiceColor("Muscle"), "- Muscle"),
                      donneeList(choiceColor("Os"), "- Os"),
                      donneeList(choiceColor("Nerf"), "- Nerf"),
                    ])),
                UFSelectedView(),
                Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.fromLTRB(0, 20, 20, 0),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_circle_right_outlined,
                        color: Colors.blue,
                        size: 50,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PageResultat(
                              title: title,
                              structures: structures,
                              structureSelect: structureSelect,
                              fonctionnalUnityList: fonctionnalUnityList,
                            ),
                          ),
                        );
                      },
                      // child: const Text("Valider"),
                    ))
              ],
            ))
      ]),
    );
  }
}
