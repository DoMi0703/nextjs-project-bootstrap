import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';
import 'package:eventease/widgets/custom_button.dart';

class CustomDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool showCloseButton;
  final DialogType type;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.actions,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.showCloseButton = true,
    this.type = DialogType.custom,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              _buildContent(),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          if (type != DialogType.custom) ...[
            _getDialogIcon(),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              title ?? _getDefaultTitle(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: content ??
          Text(
            message ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (actions != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions!,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          if (cancelText != null || onCancel != null)
            Expanded(
              child: CustomButton(
                text: cancelText ?? 'Cancel',
                onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                variant: ButtonVariant.outline,
              ),
            ),
          if (cancelText != null || onCancel != null)
            const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: confirmText ?? 'OK',
              onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
              variant: isDestructive ? ButtonVariant.error : ButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDialogIcon() {
    switch (type) {
      case DialogType.success:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline_rounded,
            color: AppTheme.successColor,
            size: 24,
          ),
        );
      case DialogType.error:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: AppTheme.errorColor,
            size: 24,
          ),
        );
      case DialogType.warning:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warningColor,
            size: 24,
          ),
        );
      case DialogType.info:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case DialogType.success:
        return 'Success';
      case DialogType.error:
        return 'Error';
      case DialogType.warning:
        return 'Warning';
      case DialogType.info:
        return 'Information';
      default:
        return '';
    }
  }

  // Static methods for easy dialog creation
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    bool showCloseButton = true,
    DialogType type = DialogType.custom,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
        showCloseButton: showCloseButton,
        type: type,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
      type: DialogType.warning,
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String message,
    String? title,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: DialogType.success,
      cancelText: null,
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String message,
    String? title,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: DialogType.error,
      cancelText: null,
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String message,
    String? title,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: DialogType.info,
      cancelText: null,
    );
  }
}

enum DialogType {
  custom,
  success,
  error,
  warning,
  info,
}
