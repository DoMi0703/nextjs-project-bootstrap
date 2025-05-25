import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomListTile extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool enabled;
  final bool showDivider;
  final EdgeInsets? contentPadding;
  final double? height;
  final bool animated;
  final ListTileStyle style;
  final Color? backgroundColor;
  final Color? selectedColor;
  final bool dense;
  final bool threeLine;
  final ListTileShape shape;
  final double borderRadius;

  const CustomListTile({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.enabled = true,
    this.showDivider = false,
    this.contentPadding,
    this.height,
    this.animated = true,
    this.style = ListTileStyle.standard,
    this.backgroundColor,
    this.selectedColor,
    this.dense = false,
    this.threeLine = false,
    this.shape = ListTileShape.rectangle,
    this.borderRadius = 12,
  });

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile>
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
      end: 0.98,
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
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget listTile = Container(
      height: widget.height,
      decoration: _getDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          onLongPress: widget.enabled ? widget.onLongPress : null,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: _getBorderRadius(),
          child: Padding(
            padding: widget.contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.title != null)
                        Text(
                          widget.title!,
                          style: TextStyle(
                            fontSize: widget.dense ? 14 : 16,
                            fontWeight:
                                widget.selected ? FontWeight.w600 : FontWeight.w500,
                            color: _getTextColor(),
                          ),
                        ),
                      if (widget.subtitle != null) ...[
                        SizedBox(height: widget.dense ? 2 : 4),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: widget.dense ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: widget.threeLine ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 16),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.animated) {
      listTile = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: listTile,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        listTile,
        if (widget.showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  BorderRadius _getBorderRadius() {
    switch (widget.shape) {
      case ListTileShape.rectangle:
        return BorderRadius.circular(widget.borderRadius);
      case ListTileShape.circle:
        return BorderRadius.circular(100);
      case ListTileShape.stadium:
        return BorderRadius.circular(50);
    }
  }

  BoxDecoration _getDecoration() {
    Color? backgroundColor;
    switch (widget.style) {
      case ListTileStyle.standard:
        backgroundColor = widget.selected
            ? (widget.selectedColor ?? AppTheme.primaryColor.withOpacity(0.1))
            : widget.backgroundColor;
        break;
      case ListTileStyle.elevated:
        backgroundColor = widget.selected
            ? (widget.selectedColor ?? AppTheme.primaryColor.withOpacity(0.1))
            : (widget.backgroundColor ?? Colors.white);
        break;
      case ListTileStyle.outlined:
        backgroundColor = widget.selected
            ? (widget.selectedColor ?? AppTheme.primaryColor.withOpacity(0.1))
            : (widget.backgroundColor ?? Colors.white);
        break;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: _getBorderRadius(),
      border: widget.style == ListTileStyle.outlined
          ? Border.all(
              color: widget.selected
                  ? AppTheme.primaryColor
                  : Colors.grey.withOpacity(0.2),
              width: 1.5,
            )
          : null,
      boxShadow: widget.style == ListTileStyle.elevated
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  Color _getTextColor() {
    if (!widget.enabled) return Colors.grey;
    if (widget.selected) return AppTheme.primaryColor;
    return Colors.black87;
  }
}

enum ListTileStyle {
  standard,
  elevated,
  outlined,
}

enum ListTileShape {
  rectangle,
  circle,
  stadium,
}

// Swipeable List Tile
class SwipeableListTile extends StatefulWidget {
  final Widget child;
  final List<SwipeAction> actions;
  final double actionWidth;
  final bool enabled;
  final VoidCallback? onDismissed;

  const SwipeableListTile({
    super.key,
    required this.child,
    required this.actions,
    this.actionWidth = 80,
    this.enabled = true,
    this.onDismissed,
  });

  @override
  State<SwipeableListTile> createState() => _SwipeableListTileState();
}

class _SwipeableListTileState extends State<SwipeableListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _dragExtent = 0;
  bool _dragUnderway = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    _dragUnderway = true;
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || !_dragUnderway) return;
    final delta = details.primaryDelta!;
    _dragExtent += delta;
    final totalActionsWidth = widget.actionWidth * widget.actions.length;
    _dragExtent = _dragExtent.clamp(-totalActionsWidth, 0);
    _animation = Tween<Offset>(
      begin: Offset(_dragExtent / context.size!.width, 0),
      end: Offset(_dragExtent / context.size!.width, 0),
    ).animate(_controller);
    _controller.value = 1.0;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.enabled || !_dragUnderway) return;
    _dragUnderway = false;
    final velocity = details.primaryVelocity ?? 0;
    final totalActionsWidth = widget.actionWidth * widget.actions.length;
    final isOpen = _dragExtent.abs() > totalActionsWidth / 2;
    final willOpen = isOpen || velocity < -500;
    final willClose = !isOpen || velocity > 500;

    if (willOpen && !willClose) {
      _animation = Tween<Offset>(
        begin: Offset(_dragExtent / context.size!.width, 0),
        end: Offset(-totalActionsWidth / context.size!.width, 0),
      ).animate(_controller);
      _dragExtent = -totalActionsWidth;
    } else {
      _animation = Tween<Offset>(
        begin: Offset(_dragExtent / context.size!.width, 0),
        end: Offset.zero,
      ).animate(_controller);
      _dragExtent = 0;
    }

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final actionsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.actions.map((action) {
        return Container(
          width: widget.actionWidth,
          height: double.infinity,
          color: action.backgroundColor,
          child: InkWell(
            onTap: action.onPressed,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (action.icon != null)
                  Icon(
                    action.icon,
                    color: action.iconColor ?? Colors.white,
                  ),
                if (action.label != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    action.label!,
                    style: TextStyle(
                      color: action.iconColor ?? Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [actionsRow],
            ),
          ),
          SlideTransition(
            position: _animation,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class SwipeAction {
  final IconData? icon;
  final String? label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? iconColor;

  const SwipeAction({
    this.icon,
    this.label,
    required this.onPressed,
    required this.backgroundColor,
    this.iconColor,
  }) : assert(icon != null || label != null);
}
