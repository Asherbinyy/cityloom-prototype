import 'package:flutter/material.dart';

class OrderDragIcon extends StatelessWidget {
  final Color color;
  final double size;

  const OrderDragIcon({
    super.key,
    this.color = const Color(0xFF555555),
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OrderDragIconPainter(color: color),
      ),
    );
  }
}

class _OrderDragIconPainter extends CustomPainter {
  final Color color;

  _OrderDragIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Top chevron (Upward Arrow: ^)
    final pathUp = Path();
    pathUp.moveTo(w * 0.16, h * 0.28);
    pathUp.lineTo(w * 0.36, h * 0.12);
    pathUp.lineTo(w * 0.56, h * 0.28);
    canvas.drawPath(pathUp, strokePaint);

    // Bottom chevron (Downward Arrow: v)
    final pathDown = Path();
    pathDown.moveTo(w * 0.16, h * 0.56);
    pathDown.lineTo(w * 0.36, h * 0.72);
    pathDown.lineTo(w * 0.56, h * 0.56);
    canvas.drawPath(pathDown, strokePaint);

    // Top horizontal bar (right side)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.62, w * 0.62, 2.5),
        const Radius.circular(1.2),
      ),
      fillPaint,
    );

    // Bottom horizontal bar (right side)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.76, w * 0.62, 2.5),
        const Radius.circular(1.2),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrderDragIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
