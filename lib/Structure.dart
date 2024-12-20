// ignore_for_file: file_names

class Structure {
  String nom;
  String description;
  List<String> lien;
  String image;
  String tips;
  String type = "";
  List<String> uniteFonctionnelle;

  Structure(this.nom, this.description, this.lien, this.image, this.tips,
      this.uniteFonctionnelle);

  String affichage() {
    String resultat;
    resultat = '------------ $nom ------------';
    resultat = '$resultat \n DESCRIPTION \n $description';
    resultat = '$resultat \n LIEN ';
    for (var i in lien) {
      resultat = '$resultat \n $i ';
    }
    resultat = '$resultat \n UF';
    for (var i in uniteFonctionnelle) {
      resultat = '$resultat \n $i ';
    }
    resultat = '$resultat \n image : $image';
    resultat = '$resultat \n TIPS \n $tips';
    return resultat;
  }

  void add(Structure structure) {}
  //A voir pour l'affichage de la class
}
