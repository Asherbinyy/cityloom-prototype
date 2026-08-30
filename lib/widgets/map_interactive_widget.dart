import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/tour_data.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

class FootstepPrint {
  final Offset position;
  final double angle;
  final bool isLeft;

  const FootstepPrint({
    required this.position,
    required this.angle,
    required this.isLeft,
  });
}

class MapInteractiveWidget extends StatefulWidget {
  final int currentStopIndex; // 1 for Stop A, 2 for Stop B, 3 for Stop C
  final VoidCallback onArrived;
  final bool isWalking;

  const MapInteractiveWidget({
    super.key,
    required this.currentStopIndex,
    required this.onArrived,
    this.isWalking = false,
  });

  @override
  State<MapInteractiveWidget> createState() => _MapInteractiveWidgetState();
}

class _MapInteractiveWidgetState extends State<MapInteractiveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _walkController;
  late Animation<double> _walkAnimation;
  final List<FootstepPrint> _footsteps = [];
  Timer? _stepSoundTimer;
  int _lastStepIndex = 0;

  List<Offset> get _currentPath =>
      TourData.stops[widget.currentStopIndex].walkPath;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _walkAnimation = CurvedAnimation(
      parent: _walkController,
      curve: Curves.easeInOutCubic,
    );

    _walkController.addListener(_onWalkTick);
    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stepSoundTimer?.cancel();
        SoundService.playCorrect();
        widget.onArrived();
      }
    });

    if (widget.isWalking) {
      _startWalk();
    }
  }

  @override
  void didUpdateWidget(MapInteractiveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWalking && !oldWidget.isWalking) {
      _startWalk();
    }
  }

  void _startWalk() {
    _footsteps.clear();
    _lastStepIndex = 0;
    _walkController.forward(from: 0.0);

    _stepSoundTimer?.cancel();
    _stepSoundTimer =
        Timer.periodic(const Duration(milliseconds: 280), (timer) {
      if (!_walkController.isAnimating) {
        timer.cancel();
      } else {
        SoundService.playTap();
      }
    });
  }

  void _onWalkTick() {
    if (!mounted) return;
    setState(() {
      final t = _walkAnimation.value;
      final currentPos = _calculatePositionOnPath(_currentPath, t);

      final int currentStepCount = (t * 22).floor();
      if (currentStepCount > _lastStepIndex && t < 0.96) {
        _lastStepIndex = currentStepCount;
        final nextPos =
            _calculatePositionOnPath(_currentPath, (t + 0.03).clamp(0.0, 1.0));
        final angle = math.atan2(
          nextPos.dy - currentPos.dy,
          nextPos.dx - currentPos.dx,
        );

        final isLeft = currentStepCount % 2 == 0;
        final perpAngle = angle + math.pi / 2;
        final lateralOffset = Offset(
          math.cos(perpAngle) * 0.012 * (isLeft ? -1 : 1),
          math.sin(perpAngle) * 0.012 * (isLeft ? -1 : 1),
        );

        _footsteps.add(FootstepPrint(
          position: currentPos + lateralOffset,
          angle: angle,
          isLeft: isLeft,
        ));
      }
    });
  }

  Offset _calculatePositionOnPath(List<Offset> path, double t) {
    if (path.isEmpty) return const Offset(0.5, 0.95);
    if (path.length == 1 || t <= 0.0) return path.first;
    if (t >= 1.0) return path.last;

    final totalSegments = path.length - 1;
    final segmentLength = 1.0 / totalSegments;
    final segmentIndex = (t / segmentLength).floor().clamp(0, totalSegments - 1);
    final segmentT = (t - (segmentIndex * segmentLength)) / segmentLength;

    final p0 = path[segmentIndex];
    final p1 = path[segmentIndex + 1];

    return Offset(
      p0.dx + (p1.dx - p0.dx) * segmentT,
      p0.dy + (p1.dy - p0.dy) * segmentT,
    );
  }

  @override
  void dispose() {
    _stepSoundTimer?.cancel();
    _walkController.removeListener(_onWalkTick);
    _walkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPos = _calculatePositionOnPath(_currentPath, _walkAnimation.value);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1448 / 1086,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              return Stack(
                children: [
                  // Map Background Image with Shimmer placeholder and fixed aspect ratio
                  Positioned.fill(
                    child: AppImage(
                      assetPath: 'assets/images/map.png',
                      width: w,
                      height: h,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Footsteps Trail & Explorer Avatar
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, innerConstraints) {
                        final iw = innerConstraints.maxWidth;
                        final ih = innerConstraints.maxHeight;
                        return Stack(
                          children: [
                            ..._footsteps.map((step) {
                              final px = step.position.dx * iw;
                              final py = step.position.dy * ih;
                              return Positioned(
                                left: px - 5,
                                top: py - 7,
                                child: Transform.rotate(
                                  angle: step.angle + math.pi / 2,
                                  child: CustomPaint(
                                    size: const Size(10, 14),
                                    painter:
                                        _FootprintPainter(isLeft: step.isLeft),
                                  ),
                                ),
                              );
                            }),

                            // Explorer Avatar Marker
                            Positioned(
                              left: (currentPos.dx * iw) - 20,
                              top: (currentPos.dy * ih) - 40,
                              child: _buildExplorerAvatar(widget.isWalking),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExplorerAvatar(bool walking) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.coral,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withValues(alpha: 0.5),
                blurRadius: 14,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_pin_circle_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            walking ? 'Walking...' : 'You',
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _FootprintPainter extends CustomPainter {
  final bool isLeft;

  const _FootprintPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.coral.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    // Heel
    final heelRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.75),
      width: size.width * 0.6,
      height: size.height * 0.35,
    );
    canvas.drawOval(heelRect, paint);

    // Sole
    final soleRect = Rect.fromCenter(
      center: Offset(
        size.width / 2 + (isLeft ? -1.0 : 1.0),
        size.height * 0.3,
      ),
      width: size.width * 0.75,
      height: size.height * 0.5,
    );
    canvas.drawOval(soleRect, paint);
  }

  @override
  bool shouldRepaint(covariant _FootprintPainter oldDelegate) =>
      oldDelegate.isLeft != isLeft;
}
