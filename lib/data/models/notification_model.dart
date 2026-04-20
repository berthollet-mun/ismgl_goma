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

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _asString(dynamic v) => v?.toString() ?? '';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotification:   _asInt(json['id_notification'] ?? json['id']),
      idUser:           _asInt(json['id_user']),
      titre:            _asString(json['titre']),
      message:          _asString(json['message']),
      typeNotification: _asString(json['type_notification']).isEmpty
          ? 'Info'
          : _asString(json['type_notification']),
      estLu:            json['est_lu'] == true || json['est_lu'] == 1,
      dateLecture:      json['date_lecture'] as String?,
      lien:             json['lien'] as String?,
      dateCreation:     json['date_creation'] as String?,
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