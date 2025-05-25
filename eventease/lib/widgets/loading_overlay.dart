import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool dismissible;
  final LoadingIndicatorType indicatorType;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
    this.progressColor,
    this.dismissible = false,
    this.indicatorType = LoadingIndicatorType.circular,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AnimatedWidget(
            fadeIn: true,
            child: ModalBarrier(
              dismissible: dismissible,
              color: backgroundColor?.withOpacity(0.7) ??
                  Colors.black.withOpacity(0.5),
            ),
          ),
        if (isLoading)
          AnimatedWidget(
            fadeIn: true,
            scale: true,
            child: Center(
              child: _LoadingIndicator(
                message: message,
                progressColor: progressColor,
                type: indicatorType,
              ),
            ),
          ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    String? message,
    Color? backgroundColor,
    Color? progressColor,
    bool dismissible = false,
    LoadingIndicatorType type = LoadingIndicatorType.circular,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: backgroundColor?.withOpacity(0.7) ??
          Colors.black.withOpacity(0.5),
      builder: (context) => WillPopScope(
        onWillPop: () async => dismissible,
        child: Center(
          child: _LoadingIndicator(
            message: message,
            progressColor: progressColor,
            type: type,
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

enum LoadingIndicatorType {
  circular,
  linear,
  dots,
  pulse,
}

class _LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? progressColor;
  final LoadingIndicatorType type;

  const _LoadingIndicator({
    this.message,
    this.progressColor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    final color = progressColor ?? AppTheme.primaryColor;

    switch (type) {
      case LoadingIndicatorType.circular:
        return SizedBox(
          height: 48,
          width: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );

      case LoadingIndicatorType.linear:
        return SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withOpacity(0.2),
          ),
        );

      case LoadingIndicatorType.dots:
        return _DotsLoadingIndicator(color: color);

      case LoadingIndicatorType.pulse:
        return _PulseLoadingIndicator(color: color);
    }
  }
}

class _DotsLoadingIndicator extends StatefulWidget {
  final Color color;

  const _DotsLoadingIndicator({required this.color});

  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_animations[index].value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;

  const _PulseLoadingIndicator({required this.color});

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.3),
          ),
          child: Center(
            child: Container(
              width: 24 + (24 * _animation.value),
              height: 24 + (24 * _animation.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(1 - _animation.value),
              ),
            ),
          ),
        );
      },
    );
  }
}
