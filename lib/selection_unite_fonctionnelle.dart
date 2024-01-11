import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_map/flutter_image_map.dart';
import 'PageSaisie.dart';

class SelectionUF extends StatefulWidget {
  Text title;

  SelectionUF({super.key, required Text this.title});

  @override
  State<SelectionUF> createState() => _SelectionUFState(this.title);
}

class _SelectionUFState extends State<SelectionUF> {
  bool isCrane = false;
  bool isSup = false;
  bool isRachis = false;
  bool isThorax = false;
  bool isMoyenne = false;
  bool isAbdomen = false;
  bool isInferieure = false;
  Map<String, List<int>> coorUF = {
    "Crane": [],
    "Superieur": [],
    "Rachis": [],
    "Thorax": [],
    "Moyenne": [],
    "Abdomen": [],
    "Inferieur": []
  };

  Text title;

  _SelectionUFState(this.title);

  List<Offset> makeOffset(List<int> brutList) {
    List<Offset> offsetList = [];
    for (int index = 0; index < brutList.length; index = index + 2) {
      offsetList.add(
          Offset(brutList[index].toDouble(), brutList[index + 1].toDouble()));
    }
    return offsetList;
  }

  Future<Map<String, List<int>>> loadCoor() async {
    var jsonData = await rootBundle.loadString("assets/coordonee.json");
    var jsonDataMap = jsonDecode(jsonData) as Map<String, dynamic>;
    Map<String, List<int>> finalMap = {};
    for (String fonctionnalUnity in jsonDataMap.keys) {
      finalMap[fonctionnalUnity] = jsonDataMap[fonctionnalUnity].cast<int>();
    }
    return finalMap;
  }

  @override
  initState() {
    super.initState();
    loadCoor().then((value) {
      setState(() => coorUF = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Taille texte hors titre
    const double textSize = 1.4;

    return Scaffold(
        appBar: AppBar(
          title: title,
        ),
        body: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          ImageMap(
            image: Image.asset('assets/corps.jpg'),
            onTap: (region) {},
            regions: [
              ImageMapRegion.fromPoly(
                  points: makeOffset(coorUF["Crane"]!),
                  color: isCrane ? Colors.red : Colors.transparent),
              ImageMapRegion.fromPoly(
                  points: makeOffset(coorUF["Superieur"]!),
                  color: isSup ? Colors.red : Colors.transparent),
              ImageMapRegion.fromPoly(
                  points: makeOffset(coorUF["Rachis"]!),
                  color: isRachis ? Colors.red : Colors.transparent),
              ImageMapRegion.fromPoly(
                  points: makeOffset(coorUF["Thorax"]!),
                  color: isThorax ? Colors.red : Colors.transparent),
              ImageMapRegion.fromPoly(
                  points: makeOffset(coorUF["Moyenne"]!),
                  color: isMoyenne ? Colors.red : Colors.transparent),
              ImageMapRegion.fromPoly(
                  points: makeOffset(coorUF["Abdomen"]!),
                  color: isAbdomen ? Colors.red : Colors.transparent),
              ImageMapRegion.fromPoly(
                  points: makeOffset(coorUF["Inferieur"]!),
                  color: isInferieure ? Colors.red : Colors.transparent)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    'Sélection des Unités Fonctionelles (UF)',
                    textScaleFactor: 3,
                  )),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Checkbox(
                      value: isSup,
                      onChanged: (bool? value) {
                        setState(() {
                          isSup = value!;
                        });
                      }),
                  const Text(
                    "UF supérieur",
                    textScaleFactor: textSize,
                  ),
                ]),
                Row(children: [
                  Checkbox(
                      value: isCrane,
                      onChanged: (bool? value) {
                        setState(() {
                          isCrane = value!;
                        });
                      }),
                  const Text(
                    "UF Crâne",
                    textScaleFactor: textSize,
                  ),
                ]),
                Row(children: [
                  Checkbox(
                      value: isRachis,
                      onChanged: (bool? value) {
                        setState(() {
                          isRachis = value!;
                        });
                      }),
                  const Text(
                    "UF Rachis",
                    textScaleFactor: textSize,
                  ),
                ]),
                Row(children: [
                  Checkbox(
                      value: isThorax,
                      onChanged: (bool? value) {
                        setState(() {
                          isThorax = value!;
                        });
                      }),
                  const Text(
                    "UF Thorax",
                    textScaleFactor: textSize,
                  ),
                ]),
                Row(children: [
                  Checkbox(
                      value: isMoyenne,
                      onChanged: (bool? value) {
                        setState(() {
                          isMoyenne = value!;
                        });
                      }),
                  const Text(
                    "UF Moyenne",
                    textScaleFactor: textSize,
                  ),
                ]),
                Row(children: [
                  Checkbox(
                      value: isAbdomen,
                      onChanged: (bool? value) {
                        setState(() {
                          isAbdomen = value!;
                        });
                      }),
                  const Text(
                    "UF Abdomen",
                    textScaleFactor: textSize,
                  ),
                ]),
                Row(children: [
                  Checkbox(
                      value: isInferieure,
                      onChanged: (bool? value) {
                        setState(() {
                          isInferieure = value!;
                        });
                      }),
                  const Text(
                    "UF Inférieur",
                    textScaleFactor: textSize,
                  ),
                ]),
              ]),
              Row(children: [
                Container(
                  // alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3)),
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    "Bonjour, pour commencer ton évaluation, sélectionnes les Unités fonctionnelles douloureuse du patient.",
                    textScaleFactor: textSize,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ]),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PagePrincipal(title),
                        ),
                      );
                    },
                    child: const Text("Valider")),
              )
            ],
          ),
        ]));
  }
}
