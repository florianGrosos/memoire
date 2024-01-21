// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:memoire/AffichageStructure.dart';
import 'package:memoire/selection_unite_fonctionnelle.dart';
import 'package:tuple/tuple.dart';
import 'Structure.dart';

// ignore: must_be_immutable
class PageResultat extends StatefulWidget {
  final List<Structure> structures;
  final List<Structure> structureSelect;
  final Text title;
  final List<String> fonctionnalUnityList;

  const PageResultat(
      {super.key,
      required this.title,
      required this.structures,
      required this.structureSelect,
      required this.fonctionnalUnityList});

  @override
  State<PageResultat> createState() => _PageResultatState(
      structureSelect, structures, title, fonctionnalUnityList);
}

class _PageResultatState extends State<PageResultat> {
  Map<String, Structure> nomToStructure = {};
  Map<Structure, Tuple2<int, int>> res = {};
  Map<String, Map<Structure, Tuple2<int, int>>> UFSort = {
    "Crane": {},
    "Superieur": {},
    "Rachis": {},
    "Thorax": {},
    "Moyenne": {},
    "Abdomen": {},
    "Inferieur": {}
  };
  late List<bool> selected = [];
  List<Structure> structures;
  List<Structure> structureSelect;
  Text title;
  List<String> fonctionnalUnityList;
  Map<String, bool> condUFSelect = {};

  _PageResultatState(this.structureSelect, this.structures, this.title,
      this.fonctionnalUnityList);
  //structureSelect = Liste des structures séléctionnées
  //structures = liste de toutes les structures

  @override
  initState() {
    super.initState();
    var truc = "";
    //Analyse pour le premier ordre
    //Création de la Map {"NomDeLaStructure":Structure}
    for (var structure in structures) {
      nomToStructure[structure.nom] = structure;
    }
    //1er ordre
    //Réalisation de la Map {Structure: (NbIterationDeLaStructure,0} pour avoir le nombre d'itération de chaque structure dans la liste des lien des Structure sélectionnées
    for (var strucSelect in structureSelect) {
      for (String lien in strucSelect.lien) {
        // print(nomToStructure[lien]!.uniteFonctionnelle);
        res = UFSort[nomToStructure[lien]!.uniteFonctionnelle]!;
        try {
          truc = lien;
          //Tracage, point d'arret pour savoir quelle Structure n'existe pas
        } catch (e) {
          Exception(truc);
          break;
        }
        if (res[nomToStructure[lien]!] == null) {
          res[nomToStructure[lien]!] = const Tuple2(1, 0);
          selected.add(false);
        } else {
          res[nomToStructure[lien]!] = res[nomToStructure[lien]!]!
              .withItem1(res[nomToStructure[lien]!]!.item1 + 1);
        }
        //Second ordre
        //Pour chaque structure, on cherche si
        for (String lienSecond in nomToStructure[lien]!.lien) {
          if (res.containsKey(nomToStructure[lienSecond])) {
            res[nomToStructure[lien]!] = res[nomToStructure[lien]!]!
                .withItem2(res[nomToStructure[lien]!]!.item2 + 1);
          }
        }
      }
    }
    // liste de la forme
  }

  Widget showStrucureWithUF(
      String UF, Map<Structure, Tuple2<int, int>>? resultat) {
    List<Widget> temp = [];
    //Le -1 c'est pour avoir un tri décroissant

    var resSort = Map.fromEntries(resultat!.entries.toList()
      ..sort((e1, e2) => -1 * e1.value.item1.compareTo(e2.value.item1)));
    var listStruc = resSort.entries.toList();

    for (var i = 0; i < resSort.entries.length; i++) {
      temp.add(
        ListTile(
          title: Text(listStruc[i].key.nom),
          subtitle: Text(
              "Nombre de lien de premier ordre : ${listStruc[i].value.item1}\nNombre de lien de second ordre : ${listStruc[i].value.item2}"),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    PageAffichageStructure(structure: listStruc[i].key),
              ),
            );
          },
        ),
      );
    }
    print(temp);
    print(UF);
    return Row(
      children: [
        Text(UF),
        ListView(
          scrollDirection: Axis.vertical,
          children: temp,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // List<Widget> affichageResult = [];

    // for (var structure in structureSelect) {
    //   UFSort[structure.uniteFonctionnelle]?.add(structure);
    // }

    //Le -1 c'est pour avoir un tri décroissant
    // var resSort = Map.fromEntries(res.entries.toList()
    //   ..sort((e1, e2) => -1 * e1.value.item1.compareTo(e2.value.item1)));
    // var listStruc = resSort.entries.toList();
    //Réalisation de la liste de ListTile
    // if (resSort.isNotEmpty) {
    //   for (var i = 0; i < resSort.entries.length; i++) {
    //     affichageResult.add(
    //       ListTile(
    //         title: Text(listStruc[i].key.nom),
    //         subtitle: Text(
    //             "Nombre de lien de premier ordre : ${listStruc[i].value.item1}\nNombre de lien de second ordre : ${listStruc[i].value.item2}"),
    //         trailing: Checkbox(
    //           value: selected[i],
    //           onChanged: (val) {
    //             setState(() {
    //               selected[i] = val!;
    //             });
    //           },
    //         ),
    //         onTap: () {
    //           Navigator.of(context).push(
    //             MaterialPageRoute(
    //               builder: (context) =>
    //                   PageAffichageStructure(structure: listStruc[i].key),
    //             ),
    //           );
    //         },
    //       ),
    //     );
    //   }
    // } else {
    //   affichageResult.add(const ListTile(
    //     title: Text("Aucune structure en commun"),
    //   ));
    // }

    return Scaffold(
        appBar: AppBar(title: const Text("memoire")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(child: showStrucureWithUF("Rachis", UFSort["Rachis"])),
            // for(var i in UFSort.entries){
            //   showStrucureWithUF(i.key,i.value);
            // }],
            // Expanded(
            //   child:
            // ListView(
            //   children: affichageResult,
            // ),
            // ),
            FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SelectionUF(title: title),
                    ),
                  );
                },
                child: const Text("Terminer"))
          ],
        ));
  }
}
