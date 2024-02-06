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
  Map<String, Map<Structure?, Tuple2<List<String>, List<String>>>> UFSort = {};
  late List<bool> selected = [];
  // Liste de toutes les structures
  List<Structure> structures;
  // Liste des structures sélectionnées
  List<Structure> structureSelect;
  // Titre
  Text title;
  // UF sélectionnée
  List<String> fonctionnalUnityList;

  _PageResultatState(this.structureSelect, this.structures, this.title,
      this.fonctionnalUnityList);
  //structureSelect = Liste des structures séléctionnées
  //structures = liste de toutes les structures

  Map<String, Structure> structureMapNameGenerate(List<Structure> struc) {
    Map<String, Structure> res = {};
    for (var structure in struc) {
      res[structure.nom] = structure;
    }
    return res;
  }

  Map<String, Map<Structure?, Tuple2<List<String>, List<String>>>> rangementUF(
      Map<String, Map<Structure?, Tuple2<List<String>, List<String>>>>
          resultatListVierge,
      Map<Structure?, Tuple2<List<String>, List<String>>> analyseRes) {
    // On entre chaque structure dans l'unité fonctionnelle correspondante
    for (var resMap in analyseRes.entries) {
      bool uncast = true;
      // On check si pour chaque unite fonctionnelle de la structure il existe un UF dans resultatLisVierge
      // Pour voir si la structure est dans une UF sélectionnée
      for (String uf in resMap.key!.uniteFonctionnelle) {
        uf = uf.trim();
        if (resultatListVierge.keys.contains(uf)) {
          resultatListVierge[uf]![resMap.key!] = resMap.value;
          uncast = false;
        }
      }
      if (uncast) {
        resultatListVierge["Autres"]![resMap.key!] = resMap.value;
      }
    }
    return resultatListVierge;
  }

  Map<String, Map<Structure?, Tuple2<List<String>, List<String>>>> analyse(
      Map<String, Structure> structureListGlobalMap,
      List<Structure> structureListChoose,
      List<String> fonctionnalityUnityChoose) {
    Map<String, Map<Structure?, Tuple2<List<String>, List<String>>>>
        analyseResultat = {};
    Map<Structure?, Tuple2<List<String>, List<String>>> globalResultat = {};

    // Début de l'analyse
    // Création d'une Map avec comme index la structure et comme objet un tuple qui liste les structures selectionnées en lien dans lesquel le lien apparait
    // On fait ça pour le premier et second niveau
    for (var struc in structureListChoose) {
      for (String lien in struc.lien) {
        // On créer l'entrée dans la map si elle n'existe pas et on fixe le nombre de lien de premier degrè à 1
        if (globalResultat[structureListGlobalMap[lien]] == null) {
          globalResultat[structureListGlobalMap[lien]] =
              Tuple2([struc.nom], []);
        } else {
          // On incrémente la valeur du premier paramètre du tuple si l'objet existe déjà dans la map
          globalResultat[structureListGlobalMap[lien]] =
              globalResultat[structureListGlobalMap[lien]]!.withItem1(
                  globalResultat[structureListGlobalMap[lien]]!.item1 +
                      [struc.nom]);
        }

        // Analyse de second ordre
        for (String lienSecond in structureListGlobalMap[lien]!.lien) {
          if (globalResultat[structureListGlobalMap[lienSecond]] == null) {
            globalResultat[structureListGlobalMap[lienSecond]] =
                Tuple2([], [lien]);
          } else {
            globalResultat[structureListGlobalMap[lienSecond]] =
                globalResultat[structureListGlobalMap[lienSecond]]!.withItem2(
                    globalResultat[structureListGlobalMap[lienSecond]]!.item2 +
                        [lien]);
          }
        }
      }
    }

    // Création de la Map de résultat
    // Boucle de génération de Map pour chaque UF sélectionnée
    for (String UF in fonctionnalityUnityChoose) {
      analyseResultat[UF] = {};
    }
    // Création de la Map qui contiendra les Structures non présente dans les UF sélectionnée
    analyseResultat["Autres"] = {};
    // On dispatch les Structure dans la Map fanal dans les UF équivalente
    analyseResultat = rangementUF(analyseResultat, globalResultat);

    return analyseResultat;
  }

  @override
  initState() {
    super.initState();
    //Analyse pour le premier ordre
    //Création de la Map {"NomDeLaStructure":Structure}
    nomToStructure = structureMapNameGenerate(structures);
    // Analyse des resultats
    UFSort = analyse(nomToStructure, structureSelect, fonctionnalUnityList);
  }

  List<Widget> showStrucureWithUF(String UF,
      Map<Structure?, Tuple2<List<String>, List<String>>>? resultat) {
    List<Widget> temp = [];
    //Le -1 c'est pour avoir un tri décroissant

    var listStruc = resultat!.entries.toList();
    listStruc.sort(((a, b) {
      int premComp = -a.value.item1.length.compareTo(b.value.item1.length);
      if (premComp == 0) {
        return -a.value.item2.length.compareTo(b.value.item2.length);
      }
      return premComp;
    }));
    temp.add(ListTile(
      title: Container(
          alignment: Alignment.center,
          child: Text(
            UF,
            style: TextStyle(
                fontSize: 25,
                // decoration: TextDecoration.underline,
                fontWeight: FontWeight.w700),
          )),
    ));
    temp.add(Divider());
    for (var i = 0; i < resultat.entries.length; i++) {
      if (listStruc[i].value.item1.length > 1) {
        temp.add(
          ListTile(
            title: Text(listStruc[i].key!.nom),
            subtitle: Text(
                "Nombre de structures en dysfonction en lien direct : ${listStruc[i].value.item1.toSet().length}\nNombre de liens intermédaires avec les structures en dysfonction : ${listStruc[i].value.item2.toSet().length}"),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PageAffichageStructure(
                      structure: listStruc[i].key,
                      lienPremier: listStruc[i].value.item1,
                      lienSecond: listStruc[i].value.item2),
                ),
              );
            },
          ),
        );
      }
    }
    temp.add(Divider());
    return temp;
  }

  Widget makeResultListView(
    List<Widget> listWidget,
  ) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            listWidget,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> resultat = [];
    for (var uf in UFSort.entries) {
      if (uf.value.isNotEmpty) {
        resultat += showStrucureWithUF(uf.key, uf.value);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Mise en lien des structures dysfonctionnelles"),
          actions: [
            IconButton(
                iconSize: 45,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SelectionUF(title: title),
                    ),
                  );
                },
                icon: const Icon(Icons.fiber_new))
          ],
        ),
        body: SizedBox(
            child: Row(children: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: makeResultListView(resultat),
          ),
          Column(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Container(
                // alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3)),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                // constraints: BoxConstraints.expand(),
                child: const Text(
                  "Beau travail, voici les structures, triées par unités fonctionelles, qui ont le plus de liens direct et intermédiaire avec les structures dysfonctionnelles de ton examen clinique\n As-tu pensé à les tester ?",
                  style: TextStyle(fontSize: 20),
                  // textWidthBasis: TextWidthBasis.parent,
                  // softWrap: true,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ])
        ])));
  }
}
