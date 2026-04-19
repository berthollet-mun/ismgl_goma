import 'package:get/get.dart';
import 'package:ismgl/core/services/api_service.dart';

class FiliereService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  /// Liste de toutes les filières.
  Future<Map<String, dynamic>> getFilieres() async {
    return _api.get('/filieres');
  }

  /// Créer une filière.
  Future<Map<String, dynamic>> createFiliere(Map<String, dynamic> data) async {
    return _api.post('/filieres', data: data);
  }
}
