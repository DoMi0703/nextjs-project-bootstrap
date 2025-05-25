import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eventease/theme/app_theme.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final ShimmerDirection direction;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      period: duration,
      direction: direction,
      child: child,
    );
  }

  static Widget rectangle({
    required double width,
    required double height,
    double borderRadius = 8,
    EdgeInsets? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static Widget circular({
    required double size,
    EdgeInsets? margin,
  }) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ShimmerLoading.rectangle(
              width: double.infinity,
              height: 160,
              borderRadius: 16,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  ShimmerLoading.rectangle(
                    width: 200,
                    height: 24,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  // Date and location placeholders
                  Row(
                    children: [
                      ShimmerLoading.rectangle(
                        width: 100,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const SizedBox(width: 16),
                      ShimmerLoading.rectangle(
                        width: 120,
                        height: 16,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskItemShimmer extends StatelessWidget {
  const TaskItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status indicator
            ShimmerLoading.circular(size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  ShimmerLoading.rectangle(
                    width: 150,
                    height: 20,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  // Assignee placeholder
                  ShimmerLoading.rectangle(
                    width: 100,
                    height: 16,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
            // Status badge placeholder
            ShimmerLoading.rectangle(
              width: 80,
              height: 24,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: [
          // Avatar placeholder
          ShimmerLoading.circular(
            size: 120,
            margin: const EdgeInsets.only(bottom: 24),
          ),
          // Name placeholder
          ShimmerLoading.rectangle(
            width: 200,
            height: 24,
            borderRadius: 4,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          // Email placeholder
          ShimmerLoading.rectangle(
            width: 160,
            height: 16,
            borderRadius: 4,
            margin: const EdgeInsets.only(bottom: 24),
          ),
          // Stats placeholders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) => _buildStatItem()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem() {
    return Column(
      children: [
        ShimmerLoading.rectangle(
          width: 40,
          height: 40,
          borderRadius: 8,
          margin: const EdgeInsets.only(bottom: 8),
        ),
        ShimmerLoading.rectangle(
          width: 60,
          height: 16,
          borderRadius: 4,
        ),
      ],
    );
  }
}

class CommentShimmer extends StatelessWidget {
  const CommentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar placeholder
            ShimmerLoading.circular(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time placeholders
                  Row(
                    children: [
                      ShimmerLoading.rectangle(
                        width: 100,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const SizedBox(width: 8),
                      ShimmerLoading.rectangle(
                        width: 60,
                        height: 16,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Comment text placeholder
                  ShimmerLoading.rectangle(
                    width: double.infinity,
                    height: 32,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
