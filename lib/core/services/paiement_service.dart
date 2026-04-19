import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class PaiementService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  /// Liste paginée des paiements.
  Future<Map<String, dynamic>> getPaiements({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? statut,
    String? dateDebut,
    String? dateFin,
    int? caissier,
    int? modePaiement,
  }) async {
    return _api.get('/paiements', params: {
      'page':      page,
      'page_size': pageSize,
      if (search       != null && search.isNotEmpty) 'search': search,
      if (statut       != null) 'statut':        statut,
      if (dateDebut    != null) 'date_debut':    dateDebut,
      if (dateFin      != null) 'date_fin':      dateFin,
      if (caissier     != null) 'caissier':      caissier,
      if (modePaiement != null) 'mode_paiement': modePaiement,
    });
  }

  /// Enregistrer un paiement.
  Future<Map<String, dynamic>> createPaiement(Map<String, dynamic> data) async {
    return _api.post('/paiements', data: data);
  }

  /// Annuler un paiement.
  Future<Map<String, dynamic>> annuler(int id, String motif) async {
    return _api.patch('/paiements/$id/annuler', data: {'motif': motif});
  }

  /// Rapport journalier de la caisse.
  Future<Map<String, dynamic>> getRapportJournalier({
    String? date,
    int? caissier,
  }) async {
    return _api.get('/paiements/journalier', params: {
      if (date     != null) 'date':     date,
      if (caissier != null) 'caissier': caissier,
    });
  }
}
