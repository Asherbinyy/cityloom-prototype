import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/tour_data.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

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
  late AnimationController _animController;
  late Animation<double> _walkAnimation;

  final List<FootstepPrint> _footsteps = [];
  Timer? _footstepSoundTimer;
  bool _hasArrived = false;

  late List<Offset> _currentPath;

  @override
  void initState() {
    super.initState();
    _currentPath = TourData.stops[widget.currentStopIndex].walkPath;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    _walkAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutSine,
    );

    _animController.addListener(_updateFootstepsOnWalk);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasArrived) {
        _hasArrived = true;
        _footstepSoundTimer?.cancel();
        SoundService.playCorrect();
        // Give time for zoom-out to settle before triggering arrival callback
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) widget.onArrived();
        });
      }
    });

    if (widget.isWalking) {
      _startWalking();
    }
  }

  @override
  void didUpdateWidget(MapInteractiveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWalking && !oldWidget.isWalking && !_animController.isAnimating) {
      _startWalking();
    }
  }

  void _startWalking() {
    _footsteps.clear();
    _hasArrived = false;
    _animController.reset();

    // Rhythmic footstep audio taps
    _footstepSoundTimer?.cancel();
    _footstepSoundTimer =
        Timer.periodic(const Duration(milliseconds: 320), (timer) {
      if (!_animController.isAnimating) {
        timer.cancel();
      } else {
        SoundService.playFootstep();
      }
    });

    _animController.forward();
  }

  void _updateFootstepsOnWalk() {
    if (!widget.isWalking || _currentPath.length < 2) return;

    final progress = _walkAnimation.value;
    final currentPos = _calculatePositionOnPath(_currentPath, progress);

    if (_footsteps.isEmpty) {
      _footsteps.add(
        FootstepPrint(
          position: currentPos,
          angle: _calculateAngleOnPath(_currentPath, progress),
          isLeft: true,
        ),
      );
      setState(() {});
      return;
    }

    final lastPos = _footsteps.last.position;
    final dist = (currentPos - lastPos).distance;

    // Place a new footstep every ~0.045 distance units along path
    if (dist >= 0.045 && progress < 0.98) {
      final angle = _calculateAngleOnPath(_currentPath, progress);
      final isNextLeft = !_footsteps.last.isLeft;

      // Natural footstep lateral offset perpendicular to walking trajectory
      final perpAngle = angle + (isNextLeft ? math.pi / 2 : -math.pi / 2);
      const lateralOffset = 0.012;
      final adjustedPos = Offset(
        currentPos.dx + lateralOffset * math.cos(perpAngle),
        currentPos.dy + lateralOffset * math.sin(perpAngle),
      );

      _footsteps.add(
        FootstepPrint(
          position: adjustedPos,
          angle: angle,
          isLeft: isNextLeft,
        ),
      );
      setState(() {});
    }
  }

  Offset _calculatePositionOnPath(List<Offset> path, double t) {
    if (path.isEmpty) return TourData.entranceCoordinate;
    if (path.length == 1 || t <= 0.0) return path.first;
    if (t >= 1.0) return path.last;

    final totalSegments = path.length - 1;
    final scaledT = t * totalSegments;
    final index = scaledT.floor().clamp(0, totalSegments - 1);
    final localT = scaledT - index;

    final p0 = path[index];
    final p1 = path[index + 1];

    return Offset(
      p0.dx + (p1.dx - p0.dx) * localT,
      p0.dy + (p1.dy - p0.dy) * localT,
    );
  }

  double _calculateAngleOnPath(List<Offset> path, double t) {
    if (path.length < 2) return 0.0;
    final totalSegments = path.length - 1;
    final scaledT = t * totalSegments;
    final index = scaledT.floor().clamp(0, totalSegments - 1);

    final p0 = path[index];
    final p1 = path[index + 1];
    return math.atan2(p1.dy - p0.dy, p1.dx - p0.dx);
  }

  @override
  void dispose() {
    _animController.dispose();
    _footstepSoundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPos = widget.isWalking
        ? _calculatePositionOnPath(_currentPath, _walkAnimation.value)
        : _currentPath.first;

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              children: [
                // Map Background Image — map with A, B, C built-in
                Image.asset(
                  'assets/images/map.png',
                  width: w,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, _, _) => Container(
                    height: w * 0.75,
                    color: const Color(0xFFE5ECC8),
                    child: const Center(
                      child: Icon(Icons.map_rounded,
                          size: 48, color: AppColors.muted),
                    ),
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
