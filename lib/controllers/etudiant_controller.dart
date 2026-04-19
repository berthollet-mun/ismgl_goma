import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/core/services/etudiant_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/etudiant_model.dart';
import 'package:ismgl/data/responses/paginated_response.dart';

class EtudiantController extends GetxController {
  final EtudiantService _service = Get.find<EtudiantService>();

  final isLoading     = false.obs;
  final isSubmitting  = false.obs;
  final etudiants     = <EtudiantModel>[].obs;
  final selectedEtudiant = Rxn<EtudiantModel>();
  final totalItems    = 0.obs;
  final currentPage   = 1.obs;
  final totalPages    = 1.obs;

  final search        = ''.obs;
  final filterStatut  = Rxn<String>();
  final filterSexe    = Rxn<String>();

  // Profil étudiant connecté (rôle Etudiant)
  final monProfil     = Rxn<EtudiantModel>();

  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadEtudiants();
  }

  Future<void> loadEtudiants({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      etudiants.clear();
    }
    isLoading.value = true;
    try {
      final result = await _service.getEtudiants(
        page:     currentPage.value,
        pageSize: _pageSize,
        search:   search.value.isEmpty ? null : search.value,
        statut:   filterStatut.value,
        sexe:     filterSexe.value,
      );
      if (result['success'] == true) {
        final resp = PaginatedResponse.fromJson(
          result['data'] as Map<String, dynamic>,
          (j) => EtudiantModel.fromJson(j),
        );
        if (reset || currentPage.value == 1) {
          etudiants.assignAll(resp.items);
        } else {
          etudiants.addAll(resp.items);
        }
        totalItems.value = resp.totalItems;
        totalPages.value = resp.totalPages;
      }
    } catch (e) {
      AppHelpers.showError('Erreur réseau: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMonProfil() async {
    isLoading.value = true;
    try {
      final result = await _service.getMe();
      if (result['success'] == true) {
        monProfil.value = EtudiantModel.fromJson(
            result['data'] as Map<String, dynamic>);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDetail(int id) async {
    isLoading.value = true;
    try {
      final result = await _service.getEtudiant(id);
      if (result['success'] == true) {
        selectedEtudiant.value = EtudiantModel.fromJson(
            result['data'] as Map<String, dynamic>);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createEtudiant(
    Map<String, dynamic> data, {
    String? photoProfilPath,
    String? photoIdentitePath,
  }) async {
    isSubmitting.value = true;
    try {
      final result = await _service.createEtudiant(
        data,
        photoProfilPath:   photoProfilPath,
        photoIdentitePath: photoIdentitePath,
      );
      if (result['success'] == true) {
        AppHelpers.showSuccess('Étudiant créé avec succès');
        await loadEtudiants(reset: true);
        return true;
      } else {
        AppHelpers.showError(result['message'] ?? 'Erreur création');
        return false;
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateStatut(EtudiantModel etudiant, String statut) async {
    final result = await _service.updateStatut(etudiant.idEtudiant, statut);
    if (result['success'] == true) {
      AppHelpers.showSuccess('Statut mis à jour');
      await loadEtudiants(reset: true);
    } else {
      AppHelpers.showError(result['message'] ?? 'Erreur');
    }
  }

  void onSearch(String value) {
    search.value = value;
    if (value.length >= 3 || value.isEmpty) loadEtudiants(reset: true);
  }

  void setFilterStatut(String? statut) {
    filterStatut.value = statut;
    loadEtudiants(reset: true);
  }

  void setFilterSexe(String? sexe) {
    filterSexe.value = sexe;
    loadEtudiants(reset: true);
  }

  void loadMore() {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      currentPage.value++;
      loadEtudiants();
    }
  }
}
