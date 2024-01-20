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
    var rawData = await rootBundle.loadString("assets/donneeTest.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    // tailleDonne = listData.length;
    donneebrut = listData;
    for (var donnee in donneebrut.sublist(1)) {
      if (donnee[0] != "") {
        //On oublie les lignes vides
        //traitement pour supprimé les espace de début et de fin de nom
        if (donnee[0] != "") donnee[0] = miseAuPropre(donnee[0]);
        //création de la liste et filtrage des strings des liens
        List<String> lien = [];

        lien =
            donnee[1].split("/") + donnee[2].split("/") + donnee[3].split("/");
        // purge de la liste des '' ou des ' '
        while (lien.contains('')) {
          lien.remove('');
        }
        while (lien.contains(' ')) {
          lien.remove(' ');
        }
        for (var cpt = 0; cpt < lien.length; cpt++) {
          if (lien[cpt].isNotEmpty) {
            lien[cpt] = miseAuPropre(lien[cpt]);
          }
        }
        //Création de la liste de toutes les structures
        struc.add(Structure(
            donnee[0], donnee[4], lien, donnee[5], donnee[6], donnee[7]));
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
    // print(struc);
    return struc;
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

  List<Widget> makeUFView() {
    final List<Widget> UFlistTile = [];
    for (var UFName in fonctionnalUnityList) {
      UFlistTile.add(Text("- " + UFName));
    }
    return UFlistTile;
  }

  @override
  Widget build(BuildContext context) {
    const double textSize = 1.4;

    return Scaffold(
      appBar: AppBar(title: title),
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
                itemBuilder: (structure, truc) {
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
                          children: [
                            // Marche pas pour l'instant
                            // GestureDetector(
                            //   child: Container(
                            //     padding: const EdgeInsets.all(3),
                            //     child: const Icon(Icons.info),
                            //   ),
                            //   onTap: () {
                            //     Navigator.of(context).push(
                            //       MaterialPageRoute(
                            //         builder: (context) => PageResultat(
                            //           title: title,
                            //           structures: structures,
                            //           structureSelect: structureSelect,
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // ),
                            Text(structure.nom)
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onItemAdded: (p0) {
                  structureSelect.add(p0);
                },
                onItemRemoved: (p0) {
                  structureSelect.remove(p0);
                },
                hintText: "Recherche",
                maximumShowItemsHeight:
                    MediaQuery.of(context).size.height * (7 / 10))),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3)),
              padding: const EdgeInsets.all(10),
              child: const Text(
                "Sélectionné les structures douloureuses de votre patient",
                textScaleFactor: textSize,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
              ),
            ),
            const Text("UF sélectionné"),
            Column(
              children: makeUFView(),
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            TextButton(
              onPressed: () {
                // print(structureSelect);
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
              child: const Text("Valider"),
            )
          ],
        )
      ]),
    );
  }
}
