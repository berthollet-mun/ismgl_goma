import 'package:get/get.dart';
import 'package:ismgl/controllers/theme_controller.dart';
import 'package:ismgl/controllers/notification_controller.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:ismgl/core/services/api_service.dart';
import 'package:ismgl/core/services/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Ces services sont déjà initialisés dans AppInitialization
    // Ici on s'assure qu'ils sont disponibles globalement
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
  }
}