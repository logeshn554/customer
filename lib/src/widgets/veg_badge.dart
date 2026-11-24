import 'package:flutter/material.dart';

class VegNonVegBadge extends StatelessWidget {
  final bool isVeg;
  final double size;

  const VegNonVegBadge({
    super.key,
    required this.isVeg,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? const Color(0xFF008000) : const Color(0xFF8B0000);

    return Semantics(
      label: isVeg ? 'Vegetarian' : 'Non-Vegetarian',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: isVeg
              ? Container(
                  width: size * 0.45,
                  height: size * 0.45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                )
              : CustomPaint(
                  size: Size(size * 0.45, size * 0.45),
                  painter: _TrianglePainter(color),
                ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
