import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class RapportService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  /// Statistiques globales.
  Future<Map<String, dynamic>> getStatistiques({int? idAnnee}) =>
      _api.get('/rapports/statistiques',
          params: {if (idAnnee != null) 'annee': idAnnee});

  /// Rapport paiements par période.
  Future<Map<String, dynamic>> getPaiements({
    String? dateDebut,
    String? dateFin,
    int? caissier,
  }) =>
      _api.get('/rapports/paiements', params: {
        if (dateDebut != null) 'date_debut': dateDebut,
        if (dateFin   != null) 'date_fin':   dateFin,
        if (caissier  != null) 'caissier':   caissier,
      });

  /// Rapport journalier caisse.
  Future<Map<String, dynamic>> getJournalier({String? date}) =>
      _api.get('/rapports/journalier',
          params: {if (date != null) 'date': date});

  /// Students with outstanding balance.
  Future<Map<String, dynamic>> getImpayes({int? idAnnee}) =>
      _api.get('/rapports/impayes',
          params: {if (idAnnee != null) 'annee': idAnnee});

  /// Statistiques par filière.
  Future<Map<String, dynamic>> getFilieres({int? idAnnee}) =>
      _api.get('/rapports/filieres',
          params: {if (idAnnee != null) 'annee': idAnnee});

  /// Récapitulatif financier.
  Future<Map<String, dynamic>> getFinancier({int? idAnnee}) =>
      _api.get('/rapports/financier',
          params: {if (idAnnee != null) 'annee': idAnnee});

  /// Situation financière d'un étudiant.
  Future<Map<String, dynamic>> getSituationEtudiant(int idEtudiant,
          {int? idAnnee}) =>
      _api.get('/rapports/etudiant/$idEtudiant',
          params: {if (idAnnee != null) 'annee': idAnnee});

  /// Export PDF.
  Future<Map<String, dynamic>> exportPDF({
    required String type,
    String? dateDebut,
    String? dateFin,
  }) =>
      _api.get('/rapports/export/pdf', params: {
        'type': type,
        if (dateDebut != null) 'date_debut': dateDebut,
        if (dateFin   != null) 'date_fin':   dateFin,
      });

  /// Export CSV.
  Future<Map<String, dynamic>> exportCSV({
    required String type,
    String? dateDebut,
    String? dateFin,
  }) =>
      _api.get('/rapports/export/csv', params: {
        'type': type,
        if (dateDebut != null) 'date_debut': dateDebut,
        if (dateFin   != null) 'date_fin':   dateFin,
      });

  /// Logs d'activité.
  Future<Map<String, dynamic>> getLogs({
    int page = 1,
    String? module,
    String? dateDebut,
    String? dateFin,
  }) =>
      _api.get('/rapports/logs', params: {
        'page': page,
        if (module    != null) 'module':     module,
        if (dateDebut != null) 'date_debut': dateDebut,
        if (dateFin   != null) 'date_fin':   dateFin,
      });
}
