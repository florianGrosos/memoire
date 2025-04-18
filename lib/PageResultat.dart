// ignore_for_file: use_build_context_synchronously, file_names

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memoire/AffichageStructure.dart';
import 'package:memoire/selection_unite_fonctionnelle.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'Structure.dart';
import 'package:mailto/mailto.dart';
// For Flutter applications, you'll most likely want to use
// the url_launcher package.
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:string_validator/string_validator.dart';

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
  Map<String, Map<Structure?, Tuple3<List<String>, List<String>, bool>>>
      UFSort = {};
  late List<bool> selected = [];
  // Liste de toutes les structures
  List<Structure> structures;
  // Liste des structures sélectionnées
  List<Structure> structureSelect;
  // Titre
  Text title;
  // UF sélectionnée
  List<String> fonctionnalUnityList;
  // Controller pour saise de mail
  TextEditingController _mail = TextEditingController();
  DateTime now = DateTime.now();
  String _errorMailMessage = "";
  int nbMaxStruct = 5;

  String genBody() {
    String body = "";
    int spaceCote = 2;
    // affichage des structures selctionnées
    body = body + "Structures sélectionnées : \n";
    for (var struc in structureSelect) {
      body = body + "\t -" + struc.nom + "\n";
    }

    body = body +
        " Voici les structures qui auraient pu être investiguees dans l’UF (X) compte tenu des liens anatomiques existants avec les structures retrouvées dysfonctionnelles à l’examen clinique : \n";
    UFSort.forEach((key, value) {
      // body = body + "<h1>" + key + "</h1>" + "\n";

      body = body + "-" * spaceCote + "-" * key.length + "-" * spaceCote + "\n";
      // body = body +
      //     "|" +
      //     " " * spaceCote +
      //     " " * key.length +
      //     " " * spaceCote +
      //     "|" +
      //     "\n";
      body = body + "|" + " " * spaceCote + key + " " * spaceCote + "|" + "\n";
      body = body + "-" * spaceCote + "-" * key.length + "-" * spaceCote + "\n";

      var listStruc = value!.entries.toList();
      listStruc.sort(((a, b) {
        int premComp = -a.value.item1.length.compareTo(b.value.item1.length);
        if (premComp == 0) {
          return -a.value.item2.length.compareTo(b.value.item2.length);
        }
        return premComp;
      }));

      int structInMail = 0;
      for (var mapStrucRes in listStruc) {
        if (mapStrucRes.value.item1.length > 1 &&
            structInMail <= nbMaxStruct - 1) {
          int nbLienDirect = mapStrucRes.value.item1.toSet().toList().length;
          int nbLienInter = mapStrucRes.value.item2.toSet().toList().length;
          body = body +
              (mapStrucRes.value.item3 ? "" : " X") +
              "\t -" +
              mapStrucRes.key!.nom +
              "\n";
          body = body +
              "\t\t " +
              "--- Nombre de structures en dysfontion en lien direct : " +
              nbLienDirect.toString() +
              "\n";
          body = body +
              "\t\t " +
              "--- Nombre de liens intermédiaires avec les structures en dysfontion : " +
              nbLienInter.toString() +
              "\n";
          structInMail++;
        }
      }
    });
    return body;
  }

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

  Map<String, Map<Structure?, Tuple3<List<String>, List<String>, bool>>>
      rangementUF(
          Map<String, Map<Structure?, Tuple3<List<String>, List<String>, bool>>>
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
          resultatListVierge[uf]![resMap.key!] =
              Tuple3(resMap.value.item1, resMap.value.item1, false);
          uncast = false;
        }
      }
      if (uncast) {
        resultatListVierge["Autres"]![resMap.key!] =
            Tuple3(resMap.value.item1, resMap.value.item1, false);
      }
    }
    return resultatListVierge;
  }

  Map<String, Map<Structure?, Tuple3<List<String>, List<String>, bool>>>
      analyse(
          Map<String, Structure> structureListGlobalMap,
          List<Structure> structureListChoose,
          List<String> fonctionnalityUnityChoose) {
    Map<String, Map<Structure?, Tuple3<List<String>, List<String>, bool>>>
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
      Map<Structure?, Tuple3<List<String>, List<String>, bool>>? resultat) {
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
      if (listStruc[i].value.item1.length > 1 && i <= nbMaxStruct - 1) {
        temp.add(
          ListTile(
            title: Text(listStruc[i].key!.nom),
            subtitle: Row(children: [
              Text(
                  "Nombre de structures en dysfonction en lien direct : ${listStruc[i].value.item1.toSet().length}\nNombre de liens intermédaires avec les structures en dysfonction : ${listStruc[i].value.item2.toSet().length}"),
              Spacer(),
              Checkbox(
                value: listStruc[i].value.item3,
                onChanged: (bool? value) {
                  // List<
                  //         MapEntry<Structure?,
                  //             Tuple3<List<String>, List<String>, bool>>>
                  //     newListStruc = List.from(listStruc);
                  // newListStruc[i] = MapEntry(
                  //     listStruc[i].key!, listStruc[i].value.withItem3(value!));
                  // listStruc = newListStruc;
                  // print(listStruc[i].key!.nom);
                  // print(listStruc[i].value.item3);
                  // listStruc = newListStruc;

                  setState(() {
                    UFSort[UF]![listStruc[i].key] =
                        listStruc[i].value.withItem3(value!);
                  });
                },
              )
            ]),
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

  Future<void> launchMailto() async {
    String body = genBody();
    print(body);
    if (isEmail(_mail.text)) {
      setState(() {
        _errorMailMessage = "";
      });
      DateFormat isoFormat = DateFormat("yyyy-MM-dd");
      String day = isoFormat.format(now);
      final mailtoLink = Mailto(
        to: [_mail.text],
        cc: [],
        subject: 'Session du ' + day.toString(),
        body: body,
      );
      print(mailtoLink);
      await launch('$mailtoLink');
    } else {
      setState(() {
        _errorMailMessage = "Entre un email valide";
      });
    }
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
            ),
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
                  "Une fois que tu as parcouru les structures, entres ton adresse mail si tu souhaites une sauvegarde de ta session",
                  style: TextStyle(fontSize: 20),
                  // textWidthBasis: TextWidthBasis.parent,
                  // softWrap: true,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width / 3,
                child: TextField(
                  controller: _mail, // Associe le controller à ce TextField
                  decoration: InputDecoration(
                    labelText: 'Entre ton adresse mail',
                    prefixIcon: Icon(Icons.mail),
                  ),
                )),
            Text(
              _errorMailMessage,
              style: TextStyle(color: Colors.red),
            ),
            ElevatedButton(
                onPressed: () async {
                  await launchMailto();
                },
                child: Text("Envoyer")),
          ])
        ])));
  }
}
