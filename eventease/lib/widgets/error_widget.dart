import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';
import 'package:eventease/widgets/custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showHomeButton;
  final ErrorType type;
  final double? imageSize;
  final bool animated;

  const CustomErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.showHomeButton = false,
    this.type = ErrorType.general,
    this.imageSize = 180,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: animated
          ? AnimatedWidget(
              fadeIn: true,
              scale: true,
              child: _buildContent(context),
            )
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildErrorIcon(),
        const SizedBox(height: 32),
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        _buildButtons(context),
      ],
    );
  }

  Widget _buildErrorIcon() {
    final IconData icon;
    final Color color;

    switch (type) {
      case ErrorType.network:
        icon = Icons.wifi_off_rounded;
        color = AppTheme.warningColor;
        break;
      case ErrorType.notFound:
        icon = Icons.search_off_rounded;
        color = AppTheme.primaryColor;
        break;
      case ErrorType.permission:
        icon = Icons.no_accounts_rounded;
        color = AppTheme.errorColor;
        break;
      case ErrorType.empty:
        icon = Icons.inbox_rounded;
        color = AppTheme.secondaryColor;
        break;
      case ErrorType.maintenance:
        icon = Icons.engineering_rounded;
        color = AppTheme.warningColor;
        break;
      default:
        icon = Icons.error_outline_rounded;
        color = AppTheme.errorColor;
    }

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: imageSize! * 0.5,
        color: color,
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null)
            CustomButton(
              text: buttonText ?? 'Try Again',
              onPressed: onRetry,
              icon: Icons.refresh_rounded,
              fullWidth: true,
            ),
          if (showHomeButton) ...[
            const SizedBox(height: 16),
            CustomButton(
              text: 'Go Home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              variant: ButtonVariant.outline,
              icon: Icons.home_rounded,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  // Factory constructors for common error scenarios
  factory CustomErrorWidget.network({
    VoidCallback? onRetry,
    bool showHomeButton = false,
  }) {
    return CustomErrorWidget(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      onRetry: onRetry,
      showHomeButton: showHomeButton,
      type: ErrorType.network,
    );
  }

  factory CustomErrorWidget.notFound({
    String? message,
    VoidCallback? onRetry,
    bool showHomeButton = true,
  }) {
    return CustomErrorWidget(
      title: 'Not Found',
      message: message ?? 'The requested resource could not be found.',
      onRetry: onRetry,
      showHomeButton: showHomeButton,
      type: ErrorType.notFound,
    );
  }

  factory CustomErrorWidget.permission({
    String? message,
    VoidCallback? onRetry,
    bool showHomeButton = true,
  }) {
    return CustomErrorWidget(
      title: 'Access Denied',
      message: message ?? 'You don\'t have permission to access this resource.',
      onRetry: onRetry,
      showHomeButton: showHomeButton,
      type: ErrorType.permission,
    );
  }

  factory CustomErrorWidget.empty({
    String? message,
    VoidCallback? onRetry,
    String? buttonText,
  }) {
    return CustomErrorWidget(
      title: 'Nothing Here',
      message: message ?? 'No items found.',
      onRetry: onRetry,
      buttonText: buttonText,
      type: ErrorType.empty,
    );
  }

  factory CustomErrorWidget.maintenance({
    String? message,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Under Maintenance',
      message: message ?? 'We\'re performing some maintenance. Please try again later.',
      onRetry: onRetry,
      type: ErrorType.maintenance,
    );
  }
}

enum ErrorType {
  general,
  network,
  notFound,
  permission,
  empty,
  maintenance,
}

// Error Handler Mixin
mixin ErrorHandler {
  Widget handleError(Object error, {VoidCallback? onRetry}) {
    if (error.toString().contains('connection')) {
      return CustomErrorWidget.network(onRetry: onRetry);
    } else if (error.toString().contains('permission')) {
      return CustomErrorWidget.permission(onRetry: onRetry);
    } else if (error.toString().contains('not found')) {
      return CustomErrorWidget.notFound(onRetry: onRetry);
    } else {
      return CustomErrorWidget(
        title: 'Oops!',
        message: 'Something went wrong. Please try again.',
        onRetry: onRetry,
      );
    }
  }
}

// Error Boundary Widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          CustomErrorWidget(
            message: 'An unexpected error occurred.',
            onRetry: () => setState(() => _error = null),
          );
    }

    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _error = null;
  }

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child) {
      _error = null;
    }
  }
}
