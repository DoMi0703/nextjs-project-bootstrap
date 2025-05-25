import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';

class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final double displacement;
  final bool showProgress;
  final String? refreshText;
  final String? completeText;
  final Duration refreshDuration;
  final Duration completeDuration;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.displacement = 40.0,
    this.showProgress = true,
    this.refreshText,
    this.completeText,
    this.refreshDuration = const Duration(milliseconds: 200),
    this.completeDuration = const Duration(milliseconds: 200),
  });

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isRefreshing = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _isComplete = false;
    });
    _controller.forward();

    try {
      await widget.onRefresh();
      setState(() => _isComplete = true);
      await Future.delayed(widget.completeDuration);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      displacement: widget.displacement,
      color: widget.color ?? AppTheme.primaryColor,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      child: Stack(
        children: [
          widget.child,
          if (_isRefreshing || _isComplete)
            Positioned(
              top: widget.displacement,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isRefreshing && widget.showProgress) ...[
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.color ?? AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (_isComplete)
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppTheme.successColor,
                            size: 16,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _isComplete
                              ? (widget.completeText ?? 'Refresh Complete')
                              : (widget.refreshText ?? 'Refreshing...'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom Sliver Refresh Indicator
class CustomSliverRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final double displacement;
  final bool showProgress;
  final String? refreshText;
  final String? completeText;

  const CustomSliverRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.displacement = 40.0,
    this.showProgress = true,
    this.refreshText,
    this.completeText,
  });

  @override
  State<CustomSliverRefreshIndicator> createState() =>
      _CustomSliverRefreshIndicatorState();
}

class _CustomSliverRefreshIndicatorState
    extends State<CustomSliverRefreshIndicator> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: widget.onRefresh,
          builder: (
            BuildContext context,
            RefreshIndicatorMode refreshState,
            double pulledExtent,
            double refreshTriggerPullDistance,
            double refreshIndicatorExtent,
          ) {
            final double percentageComplete =
                (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);

            return Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: widget.displacement,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          value: refreshState == RefreshIndicatorMode.armed
                              ? null
                              : percentageComplete,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.color ?? AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}
