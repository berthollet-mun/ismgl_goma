class FiliereModel {
  final int idFiliere;
  final String codeFiliere;
  final String nomFiliere;
  final int idDepartement;
  final String? nomDepartement;
  final String? nomFaculte;
  final String? diplomeDelivre;
  final int dureeEtudes;
  final String? description;
  final bool estActif;
  final String? dateCreation;
  final String? dateModification;

  FiliereModel({
    required this.idFiliere,
    required this.codeFiliere,
    required this.nomFiliere,
    required this.idDepartement,
    this.nomDepartement,
    this.nomFaculte,
    this.diplomeDelivre,
    this.dureeEtudes = 3,
    this.description,
    this.estActif = true,
    this.dateCreation,
    this.dateModification,
  });

  factory FiliereModel.fromJson(Map<String, dynamic> json) {
    return FiliereModel(
      idFiliere:        json['id_filiere']       as int,
      codeFiliere:      json['code_filiere']     as String,
      nomFiliere:       json['nom_filiere']      as String,
      idDepartement:    json['id_departement']   as int,
      nomDepartement:   json['nom_departement']  as String?,
      nomFaculte:       json['nom_faculte']      as String?,
      diplomeDelivre:   json['diplome_delivre']  as String?,
      dureeEtudes:      json['duree_etudes']     as int? ?? 3,
      description:      json['description']      as String?,
      estActif:         json['est_actif'] == true || json['est_actif'] == 1,
      dateCreation:     json['date_creation']    as String?,
      dateModification: json['date_modification'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_filiere':       idFiliere,
        'code_filiere':     codeFiliere,
        'nom_filiere':      nomFiliere,
        'id_departement':   idDepartement,
        'diplome_delivre':  diplomeDelivre,
        'duree_etudes':     dureeEtudes,
        'description':      description,
        'est_actif':        estActif,
      };

  @override
  String toString() => nomFiliere;
}
