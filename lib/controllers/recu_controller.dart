import 'package:get/get.dart';
import 'package:ismgl/core/services/recu_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/recu_model.dart';

class RecuController extends GetxController {
  final RecuService _service = Get.find<RecuService>();

  final isLoading   = false.obs;
  final isGenerating = false.obs;
  final selectedRecu = Rxn<RecuModel>();
  final pdfUrl       = Rxn<String>();

  Future<void> loadRecu(int id) async {
    isLoading.value = true;
    try {
      final result = await _service.getRecu(id);
      if (result['success'] == true) {
        selectedRecu.value =
            RecuModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        AppHelpers.showError(result['message'] ?? 'Reçu introuvable');
      }
    } catch (e) {
      AppHelpers.showError('Erreur réseau: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generatePDF(int id) async {
    isGenerating.value = true;
    try {
      final result = await _service.generateRecu(id);
      if (result['success'] == true) {
        pdfUrl.value = result['data']?['pdf_url'] as String?;
        AppHelpers.showSuccess('Reçu généré: ${result['data']?['numero_recu']}');
      } else {
        AppHelpers.showError(result['message'] ?? 'Erreur génération PDF');
      }
    } finally {
      isGenerating.value = false;
    }
  }

  String getDownloadUrl(int id) => _service.getDownloadUrl(id);
}
