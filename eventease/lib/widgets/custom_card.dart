import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final Color? backgroundColor;
  final double borderRadius;
  final double elevation;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool animated;
  final BorderSide? border;
  final List<Widget>? actions;
  final Widget? header;
  final Widget? footer;
  final bool showShadow;
  final CardStyle style;
  final Gradient? gradient;

  const CustomCard({
    super.key,
    this.child,
    this.backgroundColor,
    this.borderRadius = 12,
    this.elevation = 1,
    this.padding,
    this.margin,
    this.onTap,
    this.animated = true,
    this.border,
    this.actions,
    this.header,
    this.footer,
    this.showShadow = true,
    this.style = CardStyle.elevated,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: _getDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null) header!,
              if (child != null)
                Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child!,
                ),
              if (actions != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!
                        .map((action) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: action,
                            ))
                        .toList(),
                  ),
                ),
              if (footer != null) footer!,
            ],
          ),
        ),
      ),
    );

    if (animated) {
      card = AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _getDecoration() {
    switch (style) {
      case CardStyle.elevated:
        return BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          gradient: gradient,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: elevation * 4,
                    offset: Offset(0, elevation * 2),
                  ),
                ]
              : null,
        );
      case CardStyle.outlined:
        return BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ??
              Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
          gradient: gradient,
        );
      case CardStyle.filled:
        return BoxDecoration(
          color: backgroundColor ?? Colors.grey[100],
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          gradient: gradient,
        );
    }
  }
}

enum CardStyle {
  elevated,
  outlined,
  filled,
}

// Expandable Card
class ExpandableCard extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool initiallyExpanded;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final CardStyle style;
  final Color? backgroundColor;
  final double borderRadius;
  final bool animated;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.padding,
    this.margin,
    this.style = CardStyle.elevated,
    this.backgroundColor,
    this.borderRadius = 12,
    this.animated = true,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      style: widget.style,
      backgroundColor: widget.backgroundColor,
      borderRadius: widget.borderRadius,
      padding: EdgeInsets.zero,
      margin: widget.margin,
      animated: widget.animated,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggleExpand,
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: widget.title),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Status Card
class StatusCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool animated;

  const StatusCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      animated: animated,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
            ),
        ],
      ),
    );
  }
}
