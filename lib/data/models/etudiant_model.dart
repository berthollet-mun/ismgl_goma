class EtudiantModel {
  final int idEtudiant;
  final int? idUser;
  final String numeroEtudiant;
  final String matricule;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String dateNaissance;
  final String? lieuNaissance;
  final String sexe;
  final String? nationalite;
  final String? adresse;
  final String? ville;
  final String? province;
  final String? nomPere;
  final String? nomMere;
  final String? telephoneUrgence;
  final String? groupeSanguin;
  final String? photoIdentite;
  final String statut;
  final bool estActif;
  final String? datePremierInscription;
  final String? dateCreation;
  final String? dateModification;

  EtudiantModel({
    required this.idEtudiant,
    this.idUser,
    required this.numeroEtudiant,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.dateNaissance,
    this.lieuNaissance,
    required this.sexe,
    this.nationalite,
    this.adresse,
    this.ville,
    this.province,
    this.nomPere,
    this.nomMere,
    this.telephoneUrgence,
    this.groupeSanguin,
    this.photoIdentite,
    this.statut = 'Actif',
    this.estActif = true,
    this.datePremierInscription,
    this.dateCreation,
    this.dateModification,
  });

  factory EtudiantModel.fromJson(Map<String, dynamic> json) {
    return EtudiantModel(
      idEtudiant:            json['id_etudiant']             as int,
      idUser:                json['id_user']                 as int?,
      numeroEtudiant:        json['numero_etudiant']         as String? ?? '',
      matricule:             json['matricule']               as String? ??
                             json['numero_etudiant']         as String? ?? '',
      nom:                   json['nom']                     as String,
      prenom:                json['prenom']                  as String,
      email:                 json['email']                   as String,
      telephone:             json['telephone']               as String?,
      dateNaissance:         json['date_naissance']          as String,
      lieuNaissance:         json['lieu_naissance']          as String?,
      sexe:                  json['sexe']                    as String,
      nationalite:           json['nationalite']             as String?,
      adresse:               json['adresse']                 as String?,
      ville:                 json['ville']                   as String?,
      province:              json['province']                as String?,
      nomPere:               json['nom_pere']                as String?,
      nomMere:               json['nom_mere']                as String?,
      telephoneUrgence:      json['telephone_urgence']       as String?,
      groupeSanguin:         json['groupe_sanguin']          as String?,
      photoIdentite:         json['photo_identite']          as String?,
      statut:                json['statut']                  as String? ?? 'Actif',
      estActif:              json['est_actif'] == true || json['est_actif'] == 1,
      datePremierInscription: json['date_premiere_inscription'] as String?,
      dateCreation:          json['date_creation']           as String?,
      dateModification:      json['date_modification']       as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_etudiant':              idEtudiant,
        'id_user':                  idUser,
        'numero_etudiant':          numeroEtudiant,
        'nom':                      nom,
        'prenom':                   prenom,
        'email':                    email,
        'telephone':                telephone,
        'date_naissance':           dateNaissance,
        'lieu_naissance':           lieuNaissance,
        'sexe':                     sexe,
        'nationalite':              nationalite,
        'adresse':                  adresse,
        'ville':                    ville,
        'province':                 province,
        'nom_pere':                 nomPere,
        'nom_mere':                 nomMere,
        'telephone_urgence':        telephoneUrgence,
        'groupe_sanguin':           groupeSanguin,
        'statut':                   statut,
        'est_actif':                estActif,
        'date_premiere_inscription': datePremierInscription,
      };

  String get fullName => '$prenom $nom';
  bool get isActive => statut == 'Actif';
}