import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.isPlaying,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  static const List<Color> _confettiColors = [
    Color(0xFFFDA692), // Coral
    Color(0xFFE5A93B), // Gold
    Color(0xFF6BCB77), // Mint green
    Color(0xFF4D96FF), // Sky blue
    Color(0xFF9B59B6), // Purple
    Color(0xFFFF6B6B), // Rose
    Color(0xFFFFD93D), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    if (widget.isPlaying) {
      _startCelebration();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    _particles.clear();
    for (int i = 0; i < 75; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: -0.1 - (_random.nextDouble() * 0.3),
          speedY: 0.002 + (_random.nextDouble() * 0.004),
          speedX: (_random.nextDouble() - 0.5) * 0.003,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
          size: 6.0 + (_random.nextDouble() * 8.0),
          color: _confettiColors[_random.nextInt(_confettiColors.length)],
          isStar: _random.nextBool(),
        ),
      );
    }
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double speedY;
  double speedX;
  double rotation;
  double rotationSpeed;
  double size;
  Color color;
  bool isStar;

  _Particle({
    required this.x,
    required this.y,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.isStar,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final currentY = (p.y + (p.speedY * progress * 800)) * size.height;
      final currentX =
          (p.x + (p.speedX * progress * 600) + math.sin(progress * 10 + p.x * 10) * 0.03) *
              size.width;
      final currentRotation = p.rotation + (p.rotationSpeed * progress * 40);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      if (p.isStar) {
        // Draw small diamond/star
        final path = Path()
          ..moveTo(0, -p.size)
          ..lineTo(p.size * 0.5, 0)
          ..lineTo(0, p.size)
          ..lineTo(-p.size * 0.5, 0)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        // Draw rectangle ribbon
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.5,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
