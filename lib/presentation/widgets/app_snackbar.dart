import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Utilitário para SnackBars padronizados no app
class AppSnackBar {
  AppSnackBar._();

  /// SnackBar de sucesso (verde)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.successColor,
      icon: Icons.check_circle_outline,
      iconColor: Colors.white,
      duration: duration,
      action: action,
    );
  }

  /// SnackBar de erro (vermelho)
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.errorColor,
      icon: Icons.error_outline,
      iconColor: Colors.white,
      duration: duration,
      action: action,
    );
  }

  /// SnackBar de aviso (laranja)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.warningColor,
      icon: Icons.warning_outlined,
      iconColor: Colors.white,
      duration: duration,
      action: action,
    );
  }

  /// SnackBar informativo (azul)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.infoColor,
      icon: Icons.info_outline,
      iconColor: Colors.white,
      duration: duration,
      action: action,
    );
  }

  /// SnackBar personalizado
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Color? iconColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      iconColor: iconColor,
      duration: duration,
      action: action,
    );
  }

  /// Método interno para mostrar o SnackBar
  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Color? iconColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    // Remove qualquer SnackBar ativo antes de mostrar o novo
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  /// SnackBar específico para o sistema inteligente
  static void showAISuccess(BuildContext context, String message) {
    showCustom(
      context,
      message: message,
      backgroundColor: AppTheme.aiColor,
      icon: Icons.psychology,
      iconColor: Colors.white,
    );
  }

  /// SnackBar específico para notificações
  static void showNotificationSuccess(BuildContext context, String message) {
    showCustom(
      context,
      message: message,
      backgroundColor: AppTheme.notificationColor,
      icon: Icons.notifications_active,
      iconColor: Colors.white,
    );
  }

  /// SnackBar específico para mood entries
  static void showMoodSuccess(BuildContext context, String message) {
    showCustom(
      context,
      message: message,
      backgroundColor: AppTheme.secondaryColor,
      icon: Icons.emoji_emotions,
      iconColor: Colors.white,
    );
  }
}
