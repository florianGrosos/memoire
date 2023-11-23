// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:memoire/AffichageStructure.dart';
import 'package:memoire/PageSaisie.dart';
import 'package:tuple/tuple.dart';
import 'Structure.dart';
import 'package:gsheets/gsheets.dart';

const _credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheet-memoire",
  "private_key_id": "13676963a677d521edf79515d5f90d7d4954acd5",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCvqO4scrU2R8BV\nQn48n4XxIpLDNkgp3X1FaZ+ihBMs3WZUHqFcNO4o/9sTmJfVP5UEtsmwH4hgToId\nVkua+bGVJXcGpo9ay8BDVImM3twRoJIkib3uWrOQU22e+8jQJBM3jMV1vFJK+ren\nPZ9RmICVLxs75Nx3UM3CntDHU5gE7HRXO/LJ5cE/ae2xiHwtmbL+is7zIwfTeHgk\nDD21kHWrEvbVpMFA63AMdpodtAayg+Ikg1rs0JCggZHgw9h0f54dRKgCJnbiHHNJ\nVGADDZtJ62OfCDZqSNldNHWILhfUn6JAOacV6Nuo7Jg6PG9pndSRNDqv1eCg/7WL\npgyGAH4JAgMBAAECggEAAKIbA7GBKjotfRExi83maXVespH0RiRcgn7MOsV/nTKK\nHyUCH2c4cZDkjQhIidYCF0OCbB5c+z3lNa5dNOiQBZHeQTmh/CmOXp/EJCwcfnrF\n9BhEBUMx8QP/+en98hQjNpjNEGzWnhsTxOhRtfVXB1KlZjyft9VkfH5ekc1hF6ly\nBEk8KApDWq0GtshvAfiM5hoI60wnA6HiTgH2IbLKCAQ9WMKcWxj4aVOFF+np0cQB\nl44J0jRI4+e7tU107QL1h6Ibh8UENVTP4lGVCOM2otRJssnRgeHkW4BII6ONP6eH\nBfc0ziOQzVAbJrt/C94772MzAmdFJhyOZnq8JeNw9QKBgQDlmKEGk25PyqlmXtk8\n6q/Br/UuG/xBD8nMH1NHwgWIEAMxA1f95udwkk3j5dHoz/0HHCwzNqNJEp3GaY/T\nErQtfBwMyHp6niidiMzqhtfRnZopBSWPE9wc/Soy7u9fVCQRJGuQOsnmR29ibucz\nDKnEjpZDUnjZqWnpXPhokh2WBQKBgQDD3Gb46vkMNK2vWhwayx0DSt0fiD4ByGXe\nQJLiRftfmA8bsmE5x6W3GLWqpDxYNIcChIrCrJSpJKWiyrt+gigK8TIudPK2zyw4\nN8Lx3GGl3j7HHYY6N+wR0wWAuHZggc8VC01jsDAW1UNGw9vXdu07fkXDyFYytc4h\nv3aCf5LjNQKBgQCcwksfPEYTAKIMnTHhn7MEoWjbZIwkt+zmC3VHBzfToGstacUI\nPEFE4P+BXIanWGrAEgIzrVhrKeTDdYuXZ6vRam2UZMULNzUv6hlO/2YXXm3FGBh+\nyeZ9fHT1daHGCqLdeWpffWQgcCGiqWn9tuWqqFf7+zE8G6mOhcWtUCYXKQKBgQCE\nRT1ZTz5fytec+2rNgWwXhCBvIhBWHeMFxHAt1XscpNFXMBFO9xBn5Y0SL5X9L4QZ\n5C7dp7VBwVkG5ojWt8mZEiiEjUA4yxKe6LGDqwRbAws8Zyj1+jw4EV2+/1Qaeq/C\nE37xGtRvJxknGjBGg69UpUMyJAJqfrM1wVqkaMlnHQKBgAe2UU5tEV9b5SogAw/L\n2bl6JVqby6TmG7s/Ncyd6C8kUvBv4bO4R9a6nVdnGzAxNK+TF76jogd/DM6poGKM\nWjyRTzlqrjzBOIw4eMhcL/vZau3fzjYIEY5DYs8b0IxMZbbSCMjifWLUuKn+NKVS\nhVqgvQvYxpeGY9eGOQPLV7aL\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheet-memoire@gsheet-memoire.iam.gserviceaccount.com",
  "client_id": "105300172292119216265",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheet-memoire%40gsheet-memoire.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';
const _spreadsheetId = '1-t68568yghbvGTUC65f-pwBLoD1_IYzWLaMJGq3-lRA';

// ignore: must_be_immutable
class PageResultat extends StatefulWidget {
  const PageResultat({super.key});

  @override
  State<PageResultat> createState() => _PageResultatState();
}

class _PageResultatState extends State<PageResultat> {
  Map<String, Structure> nomToStructure = {};
  Map<Structure, Tuple2<int, int>> res = {};
  late List<bool> selected = [];
  //structureSelect = Liste des structure séléctionné
  //structures = liste de toutes les structures
  void envoieResultat() async {
    // init GSheets
    final gsheets = GSheets(_credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(_spreadsheetId);

    print(ss.data.namedRanges.byName.values
        .map((e) => {
              'name': e.name,
              'start':
                  '${String.fromCharCode((e.range?.startColumnIndex ?? 0) + 97)}${(e.range?.startRowIndex ?? 0) + 1}',
              'end':
                  '${String.fromCharCode((e.range?.endColumnIndex ?? 0) + 97)}${(e.range?.endRowIndex ?? 0) + 1}'
            })
        .join('\n'));

    // get worksheet by its title
    var sheet = ss.worksheetByTitle('example');
    // create worksheet if it does not exist yet
    sheet ??= await ss.addWorksheet('example');

    // update cell at 'B2' by inserting string 'new'
    await sheet.values.insertValue('new', column: 2, row: 2);
    // prints 'new'
    print(await sheet.values.value(column: 2, row: 2));
    // get cell at 'B2' as Cell object
    final cell = await sheet.cells.cell(column: 2, row: 2);
    // prints 'new'
    print(cell.value);
    // update cell at 'B2' by inserting 'new2'
    await cell.post('new2');
    // prints 'new2'
    print(cell.value);
    // also prints 'new2'
    print(await sheet.values.value(column: 2, row: 2));

    // insert list in row #1
    final firstRow = ['index', 'letter', 'number', 'label'];
    await sheet.values.insertRow(1, firstRow);
    // prints [index, letter, number, label]
    print(await sheet.values.row(1));

    // insert list in column 'A', starting from row #2
    final firstColumn = ['0', '1', '2', '3', '4'];
    await sheet.values.insertColumn(1, firstColumn, fromRow: 2);
    // prints [0, 1, 2, 3, 4, 5]
    print(await sheet.values.column(1, fromRow: 2));

    // insert list into column named 'letter'
    final secondColumn = ['a', 'b', 'c', 'd', 'e'];
    await sheet.values.insertColumnByKey('letter', secondColumn);
    // prints [a, b, c, d, e, f]
    print(await sheet.values.columnByKey('letter'));

    // insert map values into column 'C' mapping their keys to column 'A'
    // order of map entries does not matter
    final thirdColumn = {
      '0': '1',
      '1': '2',
      '2': '3',
      '3': '4',
      '4': '5',
    };
    await sheet.values.map.insertColumn(3, thirdColumn, mapTo: 1);
    // prints {index: number, 0: 1, 1: 2, 2: 3, 3: 4, 4: 5, 5: 6}
    print(await sheet.values.map.column(3));

    // insert map values into column named 'label' mapping their keys to column
    // named 'letter'
    // order of map entries does not matter
    final fourthColumn = {
      'a': 'a1',
      'b': 'b2',
      'c': 'c3',
      'd': 'd4',
      'e': 'e5',
    };
    await sheet.values.map.insertColumnByKey(
      'label',
      fourthColumn,
      mapTo: 'letter',
    );
    // prints {a: a1, b: b2, c: c3, d: d4, e: e5, f: f6}
    print(await sheet.values.map.columnByKey('label', mapTo: 'letter'));

    // appends map values as new row at the end mapping their keys to row #1
    // order of map entries does not matter
    final secondRow = {
      'index': '5',
      'letter': 'f',
      'number': '6',
      'label': 'f6',
    };
    await sheet.values.map.appendRow(secondRow);
    // prints {index: 5, letter: f, number: 6, label: f6}
    print(await sheet.values.map.lastRow());

    // get first row as List of Cell objects
    final cellsRow = await sheet.cells.row(1);
    // update each cell's value by adding char '_' at the beginning
    cellsRow.forEach((cell) => cell.value = '_${cell.value}');
    // actually updating sheets cells
    await sheet.cells.insert(cellsRow);
    // prints [_index, _letter, _number, _label]
    print(await sheet.values.row(1));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PagePrincipal(
          title: 'memoire',
        ),
      ),
    );
  }

  @override
  initState() {
    super.initState();
    //Analyse pour le premier ordre
    //Création de la Map {"NomDeLaStructure":Structure}
    for (var structure in structures) {
      nomToStructure[structure.nom] = structure;
    }
    //1er ordre
    //Réalisation de la Map {Structure: (NbIterationDeLaStructure,0} pour avoir le nombre d'itération de chaque structure dans la liste des lien des Structure sélectionnées
    for (var strucSelect in structureSelect) {
      for (String lien in strucSelect.lien) {
        print(strucSelect.lien);
        print(
            lien); //Tracage, point d'arret pour savoir quelle Structure n'existe pas
        print(nomToStructure[lien]! == null);
        print(nomToStructure[lien]!);
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

  @override
  Widget build(BuildContext context) {
    List<Widget> affichageResult = [];

    //Le -1 c'est pour avoir un tri décroissant
    var resSort = Map.fromEntries(res.entries.toList()
      ..sort((e1, e2) => -1 * e1.value.item1.compareTo(e2.value.item1)));
    var listStruc = resSort.entries.toList();
    //Réalisation de la liste de ListTile
    if (resSort.isNotEmpty) {
      for (var i = 0; i < resSort.entries.length; i++) {
        affichageResult.add(
          ListTile(
            title: Text(listStruc[i].key.nom),
            subtitle: Text(
                "Nombre de lien de premier ordre : ${listStruc[i].value.item1}\nNombre de lien de second ordre : ${listStruc[i].value.item2}"),
            trailing: Checkbox(
              value: selected[i],
              onChanged: (val) {
                setState(() {
                  selected[i] = val!;
                });
              },
            ),
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
    } else {
      affichageResult.add(const ListTile(
        title: Text("Aucune structure en commun"),
      ));
    }

    return Scaffold(
        appBar: AppBar(title: const Text("memoire")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: affichageResult,
              ),
            ),
            FilledButton(
                onPressed: envoieResultat, child: const Text("Terminer"))
          ],
        ));
  }
}
