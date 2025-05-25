import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';
import 'package:eventease/widgets/custom_button.dart';

class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final bool showDragHandle;
  final double? maxHeight;
  final bool isDismissible;
  final EdgeInsets padding;
  final bool animated;

  const CustomBottomSheet({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.onClose,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.maxHeight,
    this.isDismissible = true,
    this.padding = const EdgeInsets.all(24),
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight = maxHeight ?? MediaQuery.of(context).size.height * 0.85;

    Widget sheet = Container(
      constraints: BoxConstraints(
        maxHeight: maxSheetHeight,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) _buildDragHandle(),
          _buildHeader(context),
          if (content != null)
            Flexible(
              child: SingleChildScrollView(
                padding: padding,
                child: content!,
              ),
            ),
          if (actions != null) _buildActions(),
          SizedBox(height: bottomPadding),
        ],
      ),
    );

    if (animated) {
      sheet = AnimatedWidget(
        fadeIn: true,
        slide: true,
        slideOffset: const Offset(0, 1),
        child: sheet,
      );
    }

    return sheet;
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (title == null && !showCloseButton) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
        padding.left,
        0,
        padding.right,
        padding.top,
      ),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: padding,
      child: Row(
        children: actions!
            .map((action) => Expanded(child: action))
            .expand((widget) => [widget, const SizedBox(width: 16)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  // Static methods for showing bottom sheets
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    List<Widget>? actions,
    VoidCallback? onClose,
    bool showCloseButton = true,
    bool showDragHandle = true,
    double? maxHeight,
    bool isDismissible = true,
    EdgeInsets? padding,
    bool animated = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      builder: (context) => CustomBottomSheet(
        title: title,
        content: content,
        actions: actions,
        onClose: onClose,
        showCloseButton: showCloseButton,
        showDragHandle: showDragHandle,
        maxHeight: maxHeight,
        isDismissible: isDismissible,
        padding: padding ?? const EdgeInsets.all(24),
        animated: animated,
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
    return show<bool>(
      context: context,
      title: title,
      content: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
      actions: [
        CustomButton(
          text: cancelText ?? 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
          variant: ButtonVariant.outline,
        ),
        CustomButton(
          text: confirmText ?? 'Confirm',
          onPressed: () => Navigator.of(context).pop(true),
          variant: isDestructive ? ButtonVariant.error : ButtonVariant.primary,
        ),
      ],
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String message,
    String? title,
    VoidCallback? onClose,
  }) {
    return show(
      context: context,
      title: title ?? 'Success',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: AppTheme.successColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        CustomButton(
          text: 'OK',
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
        ),
      ],
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String message,
    String? title,
    VoidCallback? onRetry,
  }) {
    return show(
      context: context,
      title: title ?? 'Error',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: AppTheme.errorColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        if (onRetry != null)
          CustomButton(
            text: 'Try Again',
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
          )
        else
          CustomButton(
            text: 'OK',
            onPressed: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }
}
