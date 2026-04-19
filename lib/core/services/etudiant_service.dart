import 'dart:io';
import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class EtudiantService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  /// Liste paginée des étudiants.
  Future<Map<String, dynamic>> getEtudiants({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? statut,
    String? sexe,
  }) async {
    return _api.get('/etudiants', params: {
      'page':      page,
      'page_size': pageSize,
      if (search != null && search.isNotEmpty) 'search': search,
      if (statut != null) 'statut': statut,
      if (sexe   != null) 'sexe':   sexe,
    });
  }

  /// Détail d'un étudiant.
  Future<Map<String, dynamic>> getEtudiant(int id) async {
    return _api.get('/etudiants/$id');
  }

  /// Profil de l'étudiant connecté.
  Future<Map<String, dynamic>> getMe() async {
    return _api.get('/etudiants/me');
  }

  /// Créer un étudiant (multipart/form-data avec photo).
  Future<Map<String, dynamic>> createEtudiant(
    Map<String, dynamic> data, {
    String? photoProfilPath,
    String? photoIdentitePath,
  }) async {
    if (photoProfilPath != null || photoIdentitePath != null) {
      final files = <String, File>{};
      if (photoProfilPath  != null) files['photo_profil']  = File(photoProfilPath);
      if (photoIdentitePath != null) files['photo_identite'] = File(photoIdentitePath);
      return _api.upload('/etudiants', data, files: files);
    }
    return _api.post('/etudiants', data: data);
  }

  /// Modifier un étudiant.
  Future<Map<String, dynamic>> updateEtudiant(
    int id,
    Map<String, dynamic> data,
  ) async {
    return _api.put('/etudiants/$id', data: data);
  }

  /// Modifier le statut d'un étudiant.
  Future<Map<String, dynamic>> updateStatut(int id, String statut) async {
    return _api.patch('/etudiants/$id/statut', data: {'statut': statut});
  }
}
