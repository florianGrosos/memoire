// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:memoire/PageResultat.dart';
import 'Structure.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class PagePrincipal extends StatefulWidget {
  final Text title;
  final List<String> fonctionnalUnityList;
  const PagePrincipal(this.title, this.fonctionnalUnityList, {super.key});

  @override
  State<PagePrincipal> createState() =>
      // ignore: no_logic_in_create_state
      _PagePrincipalState(title, fonctionnalUnityList);
}

class _PagePrincipalState extends State<PagePrincipal> {
  Text title;
  List<String> fonctionnalUnityList;
  List<Structure> structures = []; //liste de toute les structures
  List<String> structureSelect =
      []; // liste de structure qui sera envoyé à la page suivante

  bool _typeSelect = false; //Bool pour signifié si un typer à été selectionné
  String typeSelect = ""; //Valeur du type selectionné
  //Variable pour la recherche de structure
  List<String> _items =
      []; //Liste de string des structures correspondant au type selectionné
  List<String> _filteredItems =
      []; //Liste de string des structures correspondant au type selectionné et filtré par la recherche

  Map<String, Structure> mapNameToStructure =
      {}; //Map des structures avec pour clé leur nom
  Map<String, List<String>> mapTypeToStructure =
      {}; //Map de liste des structures avec pour clé leur type

  _PagePrincipalState(this.title, this.fonctionnalUnityList);

  int tailleDonne = 10;
  final TextEditingController _searchController = TextEditingController();

  // Suppression des espaces en début et en fin de mot
  String miseAuPropre(String chaine) {
    chaine = chaine.trim();
    return chaine;
  }

  // Création des objets
  Future<List<Structure>> createData() async {
    List<Structure> struc = [];
    List<List<dynamic>> donneebrut = [];
    var rawData = await rootBundle.loadString("assets/donnee.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    // tailleDonne = listData.length;
    // print(tailleDonne);
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

  Map<String, List<String>> generateMapTypeToListStructure(
      List<Structure> struc) {
    Map<String, List<String>> res = {};
    for (var structure in struc) {
      if (res.containsKey(structure.type)) {
        res[structure.type]?.add(structure.nom);
      } else {
        res[structure.type] = [structure.nom];
      }
    }
    return res;
  }

  @override
  initState() {
    createData().then((value) {
      setState(() {
        structures = value;
        mapNameToStructure = generateMapNameToStructure(structures);
        mapTypeToStructure = generateMapTypeToListStructure(structures);
        _items = mapTypeToStructure["Os"]!;
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

  void search(String query) {
    setState(
      () {
        _filteredItems = _items
            .where(
              (item) => item.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      },
    );
  }

// Il faut installer le bouton retour et le fait de rendre les boutton de la liste cliquable ###############################################################
  Widget affichageListStruc(List<String> listStruc) {
    if (_filteredItems.length == 0) {
      _items = listStruc;
      _filteredItems = _items;
    }
    return Column(children: [
      Row(
        children: [
          Container(
            child: IconButton(
                onPressed: () {
                  setState(() {
                    _typeSelect = false;
                    typeSelect = "";
                    _filteredItems = [];
                  });
                },
                icon: Icon(Icons.arrow_back)),
          ),
          Expanded(
            // child: Text("Search"),
            child: TextField(
              controller: _searchController,
              onChanged: search,
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          )
        ],
      ),
      Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredItems[index]),
                  onTap: () {
                    // Action à effectuer lorsque l'élément est cliqué
                    setState(() {
                      structureSelect.add(_filteredItems[index]);
                      _items.remove(_filteredItems[index]);
                      search(_searchController.text);
                    });
                  },
                );
                // return Container(
                //   height: 50,
                //   color: Colors.white,
                //   child: Center(child: Text(_filteredItems[index])),
                // );
              }))
    ]);
  }

  Widget affichageType() {
    _searchController.text = "";
    return GridView.count(crossAxisCount: 2, children: [
      Center(
          child: AspectRatio(
        aspectRatio: 0.8,
        child: InkWell(
          child: const Column(
            children: [
              Image(image: AssetImage('assets/articulation.png')),
              Text("Articulation")
            ],
          ),
          onTap: () {
            setState(() {
              _typeSelect = true;
              typeSelect = "Articulation";
            });
          },
        ),
      )),
      Center(
          child: AspectRatio(
        aspectRatio: 0.8,
        child: InkWell(
          child: const Column(
            children: [
              Image(image: AssetImage('assets/muscle.png')),
              Text("Muscle")
            ],
          ),
          onTap: () {
            setState(() {
              _typeSelect = true;
              typeSelect = "Muscle";
            });
          },
        ),
      )),
      Center(
          child: AspectRatio(
              aspectRatio: 0.8,
              child: InkWell(
                child: const Column(
                  children: [
                    Image(image: AssetImage('assets/nerf.png')),
                    Text("Nerf")
                  ],
                ),
                onTap: () {
                  setState(() {
                    _typeSelect = true;
                    typeSelect = "Nerf";
                  });
                },
              ))),
      Center(
        child: AspectRatio(
            aspectRatio: 0.8,
            child: InkWell(
              child: const Column(
                children: [
                  Image(image: AssetImage('assets/os.png')),
                  Text("Os")
                ],
              ),
              onTap: () {
                setState(() {
                  _typeSelect = true;
                  typeSelect = "Os";
                });
              },
            )),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    const double textSize = 1.4;

    return Scaffold(
      appBar: AppBar(
          title: const Text(
              "Sélection des dysfonctions retrouvées à l'examen clinique")),
      body: Row(children: [
        SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height,
            child: Container(
              child: _typeSelect
                  ? affichageListStruc(mapTypeToStructure[typeSelect]!)
                  : affichageType(),
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
                    "Sélectionnes les structures en dysfonction retrouvées lors de ton examen clinique",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ),
                ),
                Container(
                    child: Expanded(
                  child: ListView.builder(
                    itemCount: structureSelect.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          String typeOnTile =
                              mapNameToStructure[structureSelect[index]]!.type;
                          setState(() {
                            mapTypeToStructure[typeOnTile]!
                                .add(structureSelect[index]);
                            structureSelect.remove(structureSelect[index]);
                            search(_searchController.text);
                          });
                        },
                        title: Text(structureSelect[index]),
                      );
                    },
                  ),
                )
                    // Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //   Container(
                    //       margin: EdgeInsets.all(10),
                    //       child: const Text(
                    //         "Pour cela, tu peux utiliser la barre de recheche ou retrouver les structures dans le menu déroulant sachant que les couleurs correspondent à un type de structure anatomique :",
                    //         style: TextStyle(fontSize: 14),
                    //       )),
                    //   donneeList(choiceColor("Articulation"), "- Articulation"),
                    //   donneeList(choiceColor("Muscle"), "- Muscle"),
                    //   donneeList(choiceColor("Os"), "- Os"),
                    //   donneeList(choiceColor("Nerf"), "- Nerf"),
                    // ])
                    ),
                UFSelectedView(),
                Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.fromLTRB(0, 20, 20, 0),
                    child: IconButton(
                      iconSize: 42,
                      icon: const Icon(
                        Icons.arrow_circle_right_outlined,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        List<Structure> structureSelectInStruct = [];
                        for (var strucString in structureSelect) {
                          structureSelectInStruct
                              .add(mapNameToStructure[strucString]!);
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PageResultat(
                              title: title,
                              structures: structures,
                              structureSelect: structureSelectInStruct,
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
