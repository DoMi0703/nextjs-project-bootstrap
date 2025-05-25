import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomRating extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final int itemCount;
  final double itemSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowHalfRating;
  final bool animated;
  final RatingStyle style;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final String? label;
  final bool showLabel;
  final bool readOnly;

  const CustomRating({
    super.key,
    required this.value,
    this.onChanged,
    this.itemCount = 5,
    this.itemSize = 24,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = true,
    this.animated = true,
    this.style = RatingStyle.star,
    this.activeIcon,
    this.inactiveIcon,
    this.label,
    this.showLabel = true,
    this.readOnly = false,
  });

  @override
  State<CustomRating> createState() => _CustomRatingState();
}

class _CustomRatingState extends State<CustomRating>
    with SingleTickerProviderStateMixin {
  late double _rating;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rating = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
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

  void _updateRating(double value) {
    if (widget.readOnly) return;
    final newRating = widget.allowHalfRating
        ? (value * 2).round() / 2
        : value.round().toDouble();
    if (newRating != _rating) {
      setState(() => _rating = newRating);
      widget.onChanged?.call(newRating);
      if (widget.animated) {
        _controller.forward().then((_) => _controller.reverse());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.itemCount,
            (index) => GestureDetector(
              onTapDown: (details) => _updateRating(index + 1.0),
              onHorizontalDragUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final rating = localPosition.dx / widget.itemSize;
                _updateRating(rating.clamp(0, widget.itemCount.toDouble()));
              },
              child: _buildRatingItem(index + 1),
            ),
          ),
        ),
        if (widget.showLabel && widget.label != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingItem(int index) {
    final isActive = index <= _rating;
    final isHalf = widget.allowHalfRating && (index - 0.5) == _rating;
    Widget item = _buildIcon(isActive, isHalf);

    if (widget.animated) {
      item = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: index == _rating.ceil() ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: item,
      );
    }

    return SizedBox(
      width: widget.itemSize,
      height: widget.itemSize,
      child: item,
    );
  }

  Widget _buildIcon(bool isActive, bool isHalf) {
    final activeColor = widget.activeColor ?? AppTheme.primaryColor;
    final inactiveColor = widget.inactiveColor ?? Colors.grey[300];

    switch (widget.style) {
      case RatingStyle.star:
        return Icon(
          isActive
              ? (widget.activeIcon ?? Icons.star_rounded)
              : (widget.inactiveIcon ?? Icons.star_border_rounded),
          color: isActive ? activeColor : inactiveColor,
          size: widget.itemSize,
        );
      case RatingStyle.heart:
        return Icon(
          isActive
              ? (widget.activeIcon ?? Icons.favorite_rounded)
              : (widget.inactiveIcon ?? Icons.favorite_border_rounded),
          color: isActive ? activeColor : inactiveColor,
          size: widget.itemSize,
        );
      case RatingStyle.thumb:
        return Icon(
          isActive
              ? (widget.activeIcon ?? Icons.thumb_up_rounded)
              : (widget.inactiveIcon ?? Icons.thumb_up_outlined),
          color: isActive ? activeColor : inactiveColor,
          size: widget.itemSize,
        );
      case RatingStyle.custom:
        if (widget.activeIcon == null || widget.inactiveIcon == null) {
          throw ArgumentError(
            'activeIcon and inactiveIcon must be provided for custom style',
          );
        }
        return Icon(
          isActive ? widget.activeIcon : widget.inactiveIcon,
          color: isActive ? activeColor : inactiveColor,
          size: widget.itemSize,
        );
    }
  }
}

enum RatingStyle {
  star,
  heart,
  thumb,
  custom,
}

// Rating Bar
class RatingBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final bool animated;
  final String? label;
  final TextStyle? labelStyle;

  const RatingBar({
    super.key,
    required this.value,
    this.maxValue = 5.0,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 8,
    this.animated = true,
    this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: labelStyle ??
                TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[200],
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            widthFactor: (value / maxValue).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: foregroundColor ?? AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Rating Summary
class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution;
  final Color? barColor;
  final double barHeight;
  final bool animated;

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    this.barColor,
    this.barHeight = 8,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CustomRating(
                value: averageRating,
                readOnly: true,
                itemSize: 20,
                showLabel: false,
              ),
              const SizedBox(height: 4),
              Text(
                '$totalRatings ratings',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: List.generate(5, (index) {
              final rating = 5 - index;
              final count = ratingDistribution[rating] ?? 0;
              final percentage = totalRatings > 0
                  ? count / totalRatings
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '$rating',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RatingBar(
                        value: percentage,
                        maxValue: 1.0,
                        height: barHeight,
                        foregroundColor: barColor,
                        animated: animated,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${(percentage * 100).round()}%',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
