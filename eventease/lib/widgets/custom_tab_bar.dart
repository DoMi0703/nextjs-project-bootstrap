import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomTabBar extends StatefulWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final TabStyle style;
  final double height;
  final bool showIndicator;
  final bool animated;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onTabSelected,
    this.style = TabStyle.fixed,
    this.height = 48,
    this.showIndicator = true,
    this.animated = true,
    this.physics,
    this.padding,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  double _indicatorPosition = 0;
  double _indicatorWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicatorPosition();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _updateIndicatorPosition();
    }
  }

  void _updateIndicatorPosition() {
    if (!mounted) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double tabWidth = renderBox.size.width / widget.tabs.length;
    final double newPosition = tabWidth * widget.selectedIndex;

    setState(() {
      _indicatorPosition = newPosition;
      _indicatorWidth = tabWidth;
    });

    if (widget.style == TabStyle.scrollable) {
      _scrollController.animateTo(
        newPosition - (renderBox.size.width - tabWidth) / 2,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: widget.backgroundColor ?? Colors.white,
      child: Stack(
        children: [
          if (widget.style == TabStyle.scrollable)
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: widget.physics ?? const BouncingScrollPhysics(),
              padding: widget.padding,
              child: _buildTabs(),
            )
          else
            _buildTabs(),
          if (widget.showIndicator)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: _indicatorPosition,
              bottom: 0,
              child: Container(
                width: _indicatorWidth,
                height: 3,
                decoration: BoxDecoration(
                  color: widget.selectedColor ?? AppTheme.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: List.generate(
        widget.tabs.length,
        (index) => _buildTab(index),
      ),
    );
  }

  Widget _buildTab(int index) {
    final tab = widget.tabs[index];
    final isSelected = index == widget.selectedIndex;

    Widget tabContent = Container(
      width: widget.style == TabStyle.fixed
          ? null
          : tab.width ?? _indicatorWidth,
      padding: EdgeInsets.symmetric(
        horizontal: widget.style == TabStyle.fixed ? 16 : 24,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (tab.icon != null) ...[
            Icon(
              tab.icon,
              size: 20,
              color: isSelected
                  ? (widget.selectedColor ?? AppTheme.primaryColor)
                  : (widget.unselectedColor ?? Colors.grey[600]),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            tab.label,
            style: TextStyle(
              color: isSelected
                  ? (widget.selectedColor ?? AppTheme.primaryColor)
                  : (widget.unselectedColor ?? Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          if (tab.badge != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tab.badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (widget.animated) {
      tabContent = AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: tabContent,
      );
    }

    return Expanded(
      flex: widget.style == TabStyle.fixed ? 1 : 0,
      child: InkWell(
        onTap: () => widget.onTabSelected?.call(index),
        child: tabContent,
      ),
    );
  }
}

class TabItem {
  final String label;
  final IconData? icon;
  final String? badge;
  final double? width;

  const TabItem({
    required this.label,
    this.icon,
    this.badge,
    this.width,
  });
}

enum TabStyle {
  fixed,
  scrollable,
}

// Custom Tab Bar View
class CustomTabBarView extends StatefulWidget {
  final List<Widget> children;
  final int selectedIndex;
  final bool keepAlive;
  final Duration duration;
  final Curve curve;

  const CustomTabBarView({
    super.key,
    required this.children,
    required this.selectedIndex,
    this.keepAlive = true,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<CustomTabBarView> createState() => _CustomTabBarViewState();
}

class _CustomTabBarViewState extends State<CustomTabBarView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _pageController.animateToPage(
        widget.selectedIndex,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return widget.keepAlive
            ? KeepAliveWidget(child: widget.children[index])
            : widget.children[index];
      },
    );
  }
}

class KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const KeepAliveWidget({
    super.key,
    required this.child,
  });

  @override
  State<KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
