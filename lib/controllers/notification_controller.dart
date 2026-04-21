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

  List<dynamic> _extractNotifications(dynamic resultData, Map<String, dynamic> fullResult) {
    if (resultData is List) return resultData;

    Map<String, dynamic>? mapData;
    if (resultData is Map<String, dynamic>) {
      mapData = resultData;
    } else if (fullResult['data'] is Map<String, dynamic>) {
      mapData = fullResult['data'] as Map<String, dynamic>;
    } else {
      mapData = fullResult;
    }

    final possibleLists = <dynamic>[
      mapData['notifications'],
      mapData['items'],
      mapData['results'],
      mapData['rows'],
      mapData['data'],
    ];

    for (final candidate in possibleLists) {
      if (candidate is List) return candidate;
    }
    return <dynamic>[];
  }

  int _extractUnreadCount(Map<String, dynamic> source) {
    return _asInt(
      source['total_non_lues'] ??
          source['non_lues'] ??
          source['count_non_lues'] ??
          source['count'] ??
          source['unread_count'],
    );
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final result = await _service.getNotifications();
      if (result['success'] == true) {
        final raw = result['data'];
        final list = _extractNotifications(raw, result);
        var unread = 0;
        if (raw is Map<String, dynamic>) {
          unread = _extractUnreadCount(raw);
        }
        if (unread == 0) {
          unread = _extractUnreadCount(result);
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
          unreadCount.value = _extractUnreadCount(d);
        } else if (d is int) {
          unreadCount.value = d;
        } else {
          unreadCount.value = _extractUnreadCount(result);
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