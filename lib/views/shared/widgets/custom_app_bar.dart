import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/app/themes/app_theme.dart';
import 'package:ismgl/controllers/notification_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String  title;
  final bool    showBack;
  final bool    showNotification;
  final bool    showProfile;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack         = false,
    this.showNotification = true,
    this.showProfile      = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final notifController = Get.find<NotificationController>();

    return AppBar(
      title: Text(title),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: Get.back,
            )
          : null,
      automaticallyImplyLeading: showBack,
      actions: [
        if (showNotification)
          Obx(() => Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Get.toNamed(AppRoutes.notifications),
              ),
              if (notifController.unreadCount.value > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notifController.unreadCount.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          )),
        if (showProfile)
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}