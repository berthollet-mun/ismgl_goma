import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ismgl/app/themes/app_theme.dart';

class AppHelpers {
  // Formater montant
  static String formatMontant(double montant, {String devise = 'FC'}) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(montant)} $devise';
  }

  /// Alias de [formatMontant] pour compatibilité avec les nouvelles vues.
  static String formatCurrency(double montant, {String devise = 'FC'}) =>
      formatMontant(montant, devise: devise);

  // Formater date
  static String formatDate(String? date, {String format = 'dd/MM/yyyy'}) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final d = DateTime.parse(date);
      return DateFormat(format, 'fr_FR').format(d);
    } catch (_) {
      return date;
    }
  }

  static String formatDateTime(String? date) =>
      formatDate(date, format: 'dd/MM/yyyy HH:mm');

  // Notifications Snackbar
  static void showSuccess(String message) {
    Get.snackbar(
      '✅ Succès',
      message,
      backgroundColor: AppTheme.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      '❌ Erreur',
      message,
      backgroundColor: AppTheme.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      '⚠️ Attention',
      message,
      backgroundColor: AppTheme.warning,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  static void showInfo(String message) {
    Get.snackbar(
      'ℹ️ Information',
      message,
      backgroundColor: AppTheme.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  // Dialog confirmation
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText  = 'Annuler',
    Color? confirmColor,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppTheme.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Couleur statut inscription
  static Color getStatutInscriptionColor(String statut) {
    switch (statut) {
      case 'Validée':    return AppTheme.success;
      case 'En attente': return AppTheme.warning;
      case 'Rejetée':    return AppTheme.error;
      case 'Annulée':    return Colors.grey;
      default:           return AppTheme.info;
    }
  }

  // Couleur statut paiement
  static Color getStatutPaiementColor(String statut) {
    switch (statut) {
      case 'Validé':    return AppTheme.success;
      case 'En attente': return AppTheme.warning;
      case 'Annulé':    return AppTheme.error;
      case 'Remboursé': return AppTheme.info;
      default:          return Colors.grey;
    }
  }

  // Initiales
  static String getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}