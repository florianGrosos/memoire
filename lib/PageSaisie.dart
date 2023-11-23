import 'package:flutter/material.dart';
import 'package:memoire/PageResultat.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
import 'Structure.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

List<Structure> structures = [];
List<Structure> structureSelect = [];

class PagePrincipal extends StatefulWidget {
  const PagePrincipal({super.key, required this.title});

  final String title;

  @override
  State<PagePrincipal> createState() => _PagePrincipalState();
}

class _PagePrincipalState extends State<PagePrincipal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("memoire")),
      body: Container(
        child: const Column(children: [
          SearchAndSelect(),
          BoutonValidation(),
        ]),
      ),
    );
  }
}

class SearchAndSelect extends StatefulWidget {
  const SearchAndSelect({super.key});

  @override
  State<SearchAndSelect> createState() => _SearchAndSelectState();
}

class _SearchAndSelectState extends State<SearchAndSelect> {
  int tailleDonne = 10;

  // Suppression des espaces en début et en fin de mot
  String miseAuPropre(String chaine) {
    // print(chaine[0]);
    while (chaine[0] == " ") {
      chaine = chaine.replaceRange(0, 1, '');
    }
    while (chaine[chaine.length - 1] == " ") {
      chaine = chaine.replaceRange(chaine.length - 1, chaine.length, '');
    }
    // print(chaine);
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
        struc.add(Structure(donnee[0], donnee[4], lien, donnee[5], donnee[6]));
      }
    }
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
    // while (structures.length != tailleDonne) {
    //   print(structures.length);
    //   print(tailleDonne);
    // }
    // for(var donnee in donneeBrut){
  }

  @override
  Widget build(BuildContext context) {
    return MultipleSearchSelection(
      items: structures,
      pickedItemBuilder: (structure) {
        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 0, 0),
            border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
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
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 12,
              ),
              child: Text(structure.nom),
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
    );
  }
}

class BoutonValidation extends StatelessWidget {
  const BoutonValidation({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PageResultat(),
          ),
        );
      },
      child: const Text("Valider"),
    );
  }
}
