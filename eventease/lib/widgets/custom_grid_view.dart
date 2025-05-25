import 'package:flutter/material.dart';
import 'package:eventease/utils/animations.dart';

class CustomGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool animated;
  final Axis scrollDirection;
  final bool reverse;
  final bool primary;
  final GridStyle style;
  final double? maxCrossAxisExtent;
  final double childAspectRatio;
  final double? maxWidth;
  final bool staggered;

  const CustomGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.animated = true,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary = false,
    this.style = GridStyle.fixed,
    this.maxCrossAxisExtent,
    this.childAspectRatio = 1.0,
    this.maxWidth,
    this.staggered = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = maxWidth ?? constraints.maxWidth;
        final effectiveCrossAxisCount = _calculateCrossAxisCount(availableWidth);

        return _buildGrid(effectiveCrossAxisCount);
      },
    );
  }

  int _calculateCrossAxisCount(double availableWidth) {
    if (style == GridStyle.adaptive && maxCrossAxisExtent != null) {
      return (availableWidth / maxCrossAxisExtent!).floor();
    }
    return crossAxisCount;
  }

  Widget _buildGrid(int effectiveCrossAxisCount) {
    final gridDelegate = style == GridStyle.adaptive
        ? SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent!,
            mainAxisSpacing: runSpacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          )
        : SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: effectiveCrossAxisCount,
            mainAxisSpacing: runSpacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          );

    return GridView.builder(
      gridDelegate: gridDelegate,
      itemCount: children.length,
      itemBuilder: (context, index) {
        Widget child = children[index];

        if (animated) {
          child = AnimatedWidget(
            fadeIn: true,
            scale: true,
            delay: staggered
                ? Duration(milliseconds: index * 100)
                : const Duration(milliseconds: 0),
            child: child,
          );
        }

        return child;
      },
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      scrollDirection: scrollDirection,
      reverse: reverse,
      primary: primary,
    );
  }
}

enum GridStyle {
  fixed,
  adaptive,
}

// Responsive Grid View
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final Map<Breakpoint, int> breakpoints;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool animated;
  final double childAspectRatio;
  final bool staggered;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.breakpoints = const {
      Breakpoint.xs: 1,
      Breakpoint.sm: 2,
      Breakpoint.md: 3,
      Breakpoint.lg: 4,
      Breakpoint.xl: 5,
    },
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.animated = true,
    this.childAspectRatio = 1.0,
    this.staggered = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return CustomGridView(
          children: children,
          crossAxisCount: crossAxisCount,
          spacing: spacing,
          runSpacing: runSpacing,
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          controller: controller,
          animated: animated,
          childAspectRatio: childAspectRatio,
          staggered: staggered,
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width <= Breakpoint.xs.width) {
      return breakpoints[Breakpoint.xs] ?? 1;
    } else if (width <= Breakpoint.sm.width) {
      return breakpoints[Breakpoint.sm] ?? 2;
    } else if (width <= Breakpoint.md.width) {
      return breakpoints[Breakpoint.md] ?? 3;
    } else if (width <= Breakpoint.lg.width) {
      return breakpoints[Breakpoint.lg] ?? 4;
    } else {
      return breakpoints[Breakpoint.xl] ?? 5;
    }
  }
}

enum Breakpoint {
  xs(width: 600),
  sm(width: 900),
  md(width: 1200),
  lg(width: 1536),
  xl(width: double.infinity);

  final double width;
  const Breakpoint({required this.width});
}

// Masonry Grid View
class MasonryGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool animated;
  final bool staggered;

  const MasonryGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.animated = true,
    this.staggered = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = List.generate(crossAxisCount, (index) => <Widget>[]);
        final heights = List.filled(crossAxisCount, 0.0);

        for (var i = 0; i < children.length; i++) {
          final minHeight = heights.reduce(
            (curr, next) => curr < next ? curr : next,
          );
          final columnIndex = heights.indexOf(minHeight);

          Widget child = children[i];
          if (animated) {
            child = AnimatedWidget(
              fadeIn: true,
              scale: true,
              delay: staggered
                  ? Duration(milliseconds: i * 100)
                  : const Duration(milliseconds: 0),
              child: child,
            );
          }

          columns[columnIndex].add(child);
          heights[columnIndex] += 1; // This should be the actual height
        }

        return SingleChildScrollView(
          physics: physics,
          controller: controller,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(crossAxisCount, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index > 0 ? spacing / 2 : 0,
                      right: index < crossAxisCount - 1 ? spacing / 2 : 0,
                    ),
                    child: Column(
                      children: List.generate(
                        columns[index].length,
                        (itemIndex) => Padding(
                          padding: EdgeInsets.only(
                            bottom: itemIndex < columns[index].length - 1
                                ? runSpacing
                                : 0,
                          ),
                          child: columns[index][itemIndex],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
