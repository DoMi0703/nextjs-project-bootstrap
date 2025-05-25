import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
  error,
  success,
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final double? width;
  final double height;
  final IconData? icon;
  final bool iconRight;
  final bool animated;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.width,
    this.height = 48,
    this.icon,
    this.iconRight = false,
    this.animated = true,
    this.padding,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.animated || widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.animated || widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.animated || widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  ButtonStyle _getButtonStyle() {
    final baseStyle = ButtonStyle(
      padding: MaterialStateProperty.all(
        widget.padding ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
      elevation: MaterialStateProperty.all(0),
    );

    switch (widget.variant) {
      case ButtonVariant.primary:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return AppTheme.primaryColor.withOpacity(0.5);
            }
            return widget.backgroundColor ?? AppTheme.primaryColor;
          }),
          foregroundColor: MaterialStateProperty.all(
            widget.textColor ?? Colors.white,
          ),
        );

      case ButtonVariant.secondary:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return AppTheme.secondaryColor.withOpacity(0.5);
            }
            return widget.backgroundColor ?? AppTheme.secondaryColor;
          }),
          foregroundColor: MaterialStateProperty.all(
            widget.textColor ?? Colors.white,
          ),
        );

      case ButtonVariant.outline:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          foregroundColor: MaterialStateProperty.all(
            widget.textColor ?? AppTheme.primaryColor,
          ),
          side: MaterialStateProperty.all(
            BorderSide(
              color: widget.backgroundColor ?? AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
        );

      case ButtonVariant.text:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          foregroundColor: MaterialStateProperty.all(
            widget.textColor ?? AppTheme.primaryColor,
          ),
          overlayColor: MaterialStateProperty.all(
            AppTheme.primaryColor.withOpacity(0.1),
          ),
        );

      case ButtonVariant.error:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return AppTheme.errorColor.withOpacity(0.5);
            }
            return widget.backgroundColor ?? AppTheme.errorColor;
          }),
          foregroundColor: MaterialStateProperty.all(
            widget.textColor ?? Colors.white,
          ),
        );

      case ButtonVariant.success:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return AppTheme.successColor.withOpacity(0.5);
            }
            return widget.backgroundColor ?? AppTheme.successColor;
          }),
          foregroundColor: MaterialStateProperty.all(
            widget.textColor ?? Colors.white,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null && !widget.iconRight) ...[
          Icon(widget.icon, size: 20),
          const SizedBox(width: 8),
        ],
        if (widget.isLoading)
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else
          Text(
            widget.text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        if (widget.icon != null && widget.iconRight) ...[
          const SizedBox(width: 8),
          Icon(widget.icon, size: 20),
        ],
      ],
    );

    if (widget.animated) {
      buttonContent = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: buttonContent,
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : widget.width,
        height: widget.height,
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: _getButtonStyle(),
          child: buttonContent,
        ),
      ),
    );
  }
}
