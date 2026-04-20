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

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final result = await _service.getNotifications();
      if (result['success'] == true) {
        final raw = result['data'];
        List<dynamic> list = [];
        var unread = 0;

        if (raw is List) {
          list = raw;
        } else if (raw is Map<String, dynamic>) {
          list = (raw['notifications'] as List<dynamic>?) ?? [];
          unread = _asInt(
            raw['total_non_lues'] ?? raw['non_lues'] ?? raw['count_non_lues'],
          );
        }

        notifications.value = list
            .map((n) => NotificationModel.fromJson(
                  Map<String, dynamic>.from(n as Map),
                ))
            .toList();

        if (unread == 0 && notifications.isNotEmpty) {
          unread = notifications
              .where((n) => !n.estLu)
              .length;
        }
        unreadCount.value = unread;
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
        final d = result['data'];
        if (d is Map<String, dynamic>) {
          unreadCount.value = _asInt(
            d['count'] ?? d['non_lues'] ?? d['total_non_lues'],
          );
        } else if (d is int) {
          unreadCount.value = d;
        }
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