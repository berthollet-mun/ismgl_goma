class NotificationModel {
  final int idNotification;
  final int idUser;
  final String titre;
  final String message;
  final String typeNotification;
  final bool estLu;
  final String? dateLecture;
  final String? lien;
  final String? dateCreation;

  NotificationModel({
    required this.idNotification,
    required this.idUser,
    required this.titre,
    required this.message,
    this.typeNotification = 'Info',
    this.estLu = false,
    this.dateLecture,
    this.lien,
    this.dateCreation,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotification:   json['id_notification']   as int,
      idUser:           json['id_user']           as int? ?? 0,
      titre:            json['titre']             as String,
      message:          json['message']           as String,
      typeNotification: json['type_notification'] as String? ?? 'Info',
      estLu:            json['est_lu'] == true || json['est_lu'] == 1,
      dateLecture:      json['date_lecture']      as String?,
      lien:             json['lien']              as String?,
      dateCreation:     json['date_creation']     as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_notification':   idNotification,
        'id_user':           idUser,
        'titre':             titre,
        'message':           message,
        'type_notification': typeNotification,
        'est_lu':            estLu,
        'date_lecture':      dateLecture,
        'lien':              lien,
        'date_creation':     dateCreation,
      };
}