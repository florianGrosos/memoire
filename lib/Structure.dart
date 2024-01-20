// ignore_for_file: file_names

class Structure {
  String nom;
  String description;
  List<String> lien;
  String image;
  String tips;
  String type = "";
  String uniteFonctionnelle;

  Structure(this.nom, this.description, this.lien, this.image, this.tips,
      this.uniteFonctionnelle);

  String affichage() {
    String resultat;
    resultat = '------------ $nom ------------';
    resultat = '$resultat \n DESCRIPTION \n $description';
    resultat = '$resultat \n LIEN \n';
    for (var i in lien) {
      resultat = '$resultat \n $i \n';
    }
    resultat = '$resultat \n image : $image';
    resultat = '$resultat \n TIPS \n $tips';
    return resultat;
  }
  //A voir pour l'affichage de la class
}
