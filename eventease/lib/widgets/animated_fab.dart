import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';

class AnimatedFab extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const AnimatedFab({
    super.key,
    required this.visible,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: visible ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: visible ? 1.0 : 0.0,
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: AppTheme.primaryColor,
          elevation: 4,
          highlightElevation: 8,
          icon: const Icon(
            Icons.add_rounded,
            color: Colors.white,
          ),
          label: const Text(
            'New Event',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for FAB background
class FabPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.1,
        0,
        size.width * 0.5,
        0,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        0,
        size.width,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height,
        size.width * 0.5,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height,
        0,
        size.height * 0.5,
      )
      ..close();

    canvas.drawShadow(path, Colors.black26, 8, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
