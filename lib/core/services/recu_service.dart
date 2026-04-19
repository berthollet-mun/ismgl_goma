import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class RecuService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  /// Détail d'un reçu.
  Future<Map<String, dynamic>> getRecu(int id) async {
    return _api.get('/recus/$id');
  }

  /// Générer un reçu PDF et retourner l'URL.
  Future<Map<String, dynamic>> generateRecu(int id) async {
    return _api.get('/recus/$id/generate');
  }

  /// URL de téléchargement du reçu PDF.
  String getDownloadUrl(int id) {
    return '${ApiService.baseUrl}/recus/$id/download';
  }
}
