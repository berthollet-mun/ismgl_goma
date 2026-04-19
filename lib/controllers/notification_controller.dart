import 'package:get/get.dart';
import 'package:ismgl/core/services/notification_service.dart';
import 'package:ismgl/core/utils/helpers.dart';
import 'package:ismgl/data/models/notification_model.dart';

class NotificationController extends GetxController {
  final NotificationService _service = Get.find<NotificationService>();

  final notifications  = <NotificationModel>[].obs;
  final unreadCount    = 0.obs;
  final isLoading      = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final result = await _service.getNotifications();
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        notifications.value = (data['notifications'] as List<dynamic>)
            .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
            .toList();
        unreadCount.value = data['total_non_lues'] as int? ?? 0;
      }
    } catch (e) {
      AppHelpers.showError('Erreur chargement notifications');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final result = await _service.getCount();
      if (result['success'] == true) {
        unreadCount.value = result['data']['count'] as int? ?? 0;
      }
    } catch (_) {}
  }

  Future<void> marquerLu(int id) async {
    await _service.markAsRead(id);
    await loadNotifications();
  }

  Future<void> marquerToutLu() async {
    await _service.markAllAsRead();
    notifications.refresh();
    unreadCount.value = 0;
  }

  Future<void> supprimer(int id) async {
    await _service.deleteNotification(id);
    notifications.removeWhere((n) => n.idNotification == id);
  }

  /// Envoyer une notification à tous les utilisateurs (admin).
  Future<bool> broadcast({
    required String titre,
    required String message,
    String type = 'Info',
    String? lien,
  }) async {
    isLoading.value = true;
    try {
      final result = await _service.broadcast(
        titre:   titre,
        message: message,
        type:    type,
        lien:    lien,
      );
      if (result['success'] == true) {
        final count = result['data']?['destinataires'] as int? ?? 0;
        AppHelpers.showSuccess('Notification envoyée à $count destinataires');
        return true;
      } else {
        AppHelpers.showError(result['message'] ?? 'Erreur envoi');
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }
}