import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomBottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double height;
  final bool showLabels;
  final bool animated;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.height = 65,
    this.showLabels = true,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final navBar = Container(
      height: height + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) => _NavItem(
              item: items[index],
              isSelected: currentIndex == index,
              onTap: () => onTap(index),
              selectedColor: selectedItemColor ?? AppTheme.primaryColor,
              unselectedColor:
                  unselectedColor ?? Colors.grey[600] ?? Colors.grey,
              showLabel: showLabels,
              animated: animated,
            ),
          ),
        ),
      ),
    );

    return animated
        ? AnimatedWidget(
            child: navBar,
            fadeIn: true,
            slide: true,
            slideOffset: const Offset(0, 1),
          )
        : navBar;
  }
}

class CustomBottomNavItem {
  final IconData icon;
  final String label;
  final bool showBadge;
  final String? badgeText;

  const CustomBottomNavItem({
    required this.icon,
    required this.label,
    this.showBadge = false,
    this.badgeText,
  });
}

class _NavItem extends StatefulWidget {
  final CustomBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;
  final bool animated;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
    required this.animated,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _labelOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _labelOpacityAnimation = Tween<double>(
      begin: widget.isSelected ? 1.0 : 0.0,
      end: widget.isSelected ? 1.0 : 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      _labelOpacityAnimation = Tween<double>(
        begin: _labelOpacityAnimation.value,
        end: widget.isSelected ? 1.0 : 0.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.animated) _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.animated) _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.animated) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget itemContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              widget.item.icon,
              color: widget.isSelected
                  ? widget.selectedColor
                  : widget.unselectedColor,
              size: 24,
            ),
            if (widget.item.showBadge)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: EdgeInsets.all(
                    widget.item.badgeText != null ? 4 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: widget.item.badgeText != null
                        ? BoxShape.rectangle
                        : BoxShape.circle,
                    borderRadius: widget.item.badgeText != null
                        ? BorderRadius.circular(8)
                        : null,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: widget.item.badgeText != null
                      ? Text(
                          widget.item.badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
          ],
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: widget.isSelected
                  ? widget.selectedColor
                  : widget.unselectedColor,
              fontSize: 12,
              fontWeight:
                  widget.isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            child: Text(widget.item.label),
          ),
        ],
      ],
    );

    if (widget.animated) {
      itemContent = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: itemContent,
      );
    }

    return Expanded(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: itemContent,
        ),
      ),
    );
  }
}

// Bottom Navigation Items
class BottomNavItems {
  static const home = CustomBottomNavItem(
    icon: Icons.home_rounded,
    label: 'Home',
  );

  static const calendar = CustomBottomNavItem(
    icon: Icons.calendar_today_rounded,
    label: 'Calendar',
  );

  static const tasks = CustomBottomNavItem(
    icon: Icons.check_circle_outline_rounded,
    label: 'Tasks',
  );

  static const dashboard = CustomBottomNavItem(
    icon: Icons.dashboard_rounded,
    label: 'Dashboard',
  );

  static const profile = CustomBottomNavItem(
    icon: Icons.person_rounded,
    label: 'Profile',
  );

  static const List<CustomBottomNavItem> items = [
    home,
    calendar,
    tasks,
    dashboard,
    profile,
  ];
}
