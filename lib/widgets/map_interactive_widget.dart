import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/tour_data.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class MapInteractiveWidget extends StatefulWidget {
  final int currentStopIndex; // 1: Stop A, 2: Stop B, 3: Stop C
  final VoidCallback? onArrival;

  const MapInteractiveWidget({
    super.key,
    required this.currentStopIndex,
    this.onArrival,
  });

  @override
  State<MapInteractiveWidget> createState() => MapInteractiveWidgetState();
}

class MapInteractiveWidgetState extends State<MapInteractiveWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _walkController;
  Timer? _footstepTimer;
  bool _isWalking = false;

  late List<Offset> _currentPath;
  late Offset _startPos;
  late Offset _targetPos;

  // Normalized stop positions (x, y)
  final Map<int, Offset> stopPositions = {
    0: const Offset(0.50, 0.90), // Entrance
    1: const Offset(0.60, 0.58), // Stop A: Mortsafes
    2: const Offset(0.35, 0.32), // Stop B: Covenanters' Prison
    3: const Offset(0.32, 0.48), // Stop C: Black Mausoleum
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _initPath();
  }

  void _initPath() {
    final stop = TourData.stops[widget.currentStopIndex];
    _currentPath = stop.walkPath.isNotEmpty
        ? stop.walkPath
        : [
            stopPositions[widget.currentStopIndex - 1] ?? const Offset(0.50, 0.90),
            stopPositions[widget.currentStopIndex] ?? const Offset(0.50, 0.50),
          ];
    _startPos = _currentPath.first;
    _targetPos = _currentPath.last;
  }

  @override
  void didUpdateWidget(covariant MapInteractiveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStopIndex != widget.currentStopIndex) {
      _walkController.reset();
      _isWalking = false;
      _footstepTimer?.cancel();
      _initPath();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _walkController.dispose();
    _footstepTimer?.cancel();
    super.dispose();
  }

  void startWalk({VoidCallback? onComplete}) {
    if (_isWalking) return;
    setState(() {
      _isWalking = true;
    });

    // Start footstep rhythmic sound
    SoundService.playFootstep();
    _footstepTimer?.cancel();
    _footstepTimer = Timer.periodic(const Duration(milliseconds: 260), (_) {
      if (_isWalking) {
        SoundService.playFootstep();
      }
    });

    _walkController.forward(from: 0.0).then((_) {
      _footstepTimer?.cancel();
      SoundService.playCorrect(); // Arrival chime
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          onComplete?.call();
          widget.onArrival?.call();
        }
      });
    });
  }

  Offset _interpolatePath(double t) {
    if (_currentPath.length < 2) return _targetPos;

    // t is 0.0 to 1.0
    final segmentCount = _currentPath.length - 1;
    final scaledT = t * segmentCount;
    final segmentIndex = scaledT.floor().clamp(0, segmentCount - 1);
    final segmentFraction = scaledT - segmentIndex;

    final p0 = _currentPath[segmentIndex];
    final p1 = _currentPath[segmentIndex + 1];

    return Offset(
      p0.dx + (p1.dx - p0.dx) * segmentFraction,
      p0.dy + (p1.dy - p0.dy) * segmentFraction,
    );
  }

  List<Offset> _getFootstepsUpTo(double t) {
    final List<Offset> points = [];
    if (_currentPath.length < 2) return points;

    // Place footsteps every step of progress
    const int totalFootsteps = 14;
    final int currentCount = (t * totalFootsteps).floor();

    for (int i = 1; i <= currentCount; i++) {
      final stepT = i / totalFootsteps;
      points.add(_interpolatePath(stepT));
    }
    return points;
  }

  List<Offset> _getPreviousCompletedPaths() {
    final List<Offset> pastPoints = [];
    // If at Stop B, show path from Entrance to Stop A
    if (widget.currentStopIndex >= 2) {
      final stopAPath = TourData.stops[1].walkPath;
      for (int i = 0; i < 12; i++) {
        final t = (i + 1) / 12.0;
        final segmentCount = stopAPath.length - 1;
        final scaledT = t * segmentCount;
        final idx = scaledT.floor().clamp(0, segmentCount - 1);
        final frac = scaledT - idx;
        final p0 = stopAPath[idx];
        final p1 = stopAPath[idx + 1];
        pastPoints.add(Offset(
          p0.dx + (p1.dx - p0.dx) * frac,
          p0.dy + (p1.dy - p0.dy) * frac,
        ));
      }
    }
    // If at Stop C, also show path from Stop A to Stop B
    if (widget.currentStopIndex >= 3) {
      final stopBPath = TourData.stops[2].walkPath;
      for (int i = 0; i < 12; i++) {
        final t = (i + 1) / 12.0;
        final segmentCount = stopBPath.length - 1;
        final scaledT = t * segmentCount;
        final idx = scaledT.floor().clamp(0, segmentCount - 1);
        final frac = scaledT - idx;
        final p0 = stopBPath[idx];
        final p1 = stopBPath[idx + 1];
        pastPoints.add(Offset(
          p0.dx + (p1.dx - p0.dx) * frac,
          p0.dy + (p1.dy - p0.dy) * frac,
        ));
      }
    }
    return pastPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blush, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.coral.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 1.15,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return AnimatedBuilder(
                animation: Listenable.merge([_pulseAnimation, _walkController]),
                builder: (context, child) {
                  final walkProgress = _walkController.value;
                  final currentAvatarPos = _isWalking
                      ? _interpolatePath(walkProgress)
                      : _startPos;
                  final currentFootsteps = _isWalking
                      ? _getFootstepsUpTo(walkProgress)
                      : <Offset>[];
                  final pastFootsteps = _getPreviousCompletedPaths();

                  return Stack(
                    children: [
                      // Map Background Image
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/map.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: const Color(0xFFE8F1F5),
                            child: const Center(
                              child: Icon(Icons.map_rounded,
                                  size: 60, color: AppColors.sky),
                            ),
                          ),
                        ),
                      ),

                      // Entrance Pin
                      _buildEntranceMarker(w, h),

                      // Stop Pins (A, B, C)
                      _buildStopMarker(
                          1, 'A', 'Mortsafes', stopPositions[1]!, w, h),
                      _buildStopMarker(
                          2, 'B', "Covenanters'", stopPositions[2]!, w, h),
                      _buildStopMarker(
                          3, 'C', 'Mausoleum', stopPositions[3]!, w, h),

                      // Past Footsteps
                      ...pastFootsteps.map((pt) {
                        return Positioned(
                          left: pt.dx * w - 3,
                          top: pt.dy * h - 3,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.coral.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),

                      // Current Walking Footsteps Trail
                      ...currentFootsteps.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final pt = entry.value;
                        final isEven = idx % 2 == 0;
                        return Positioned(
                          left: pt.dx * w + (isEven ? -3 : 3) - 4,
                          top: pt.dy * h + (isEven ? 2 : -2) - 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.coral,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.coral.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Moving Walking Avatar Character
                      Positioned(
                        left: currentAvatarPos.dx * w - 24,
                        top: currentAvatarPos.dy * h -
                            44 -
                            (_isWalking
                                ? math.sin(walkProgress * math.pi * 12).abs() *
                                    6
                                : 0),
                        child: _buildAvatar(isWalking: _isWalking),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar({required bool isWalking}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.coral, AppColors.sky],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isWalking
                  ? Icons.directions_walk_rounded
                  : Icons.person_pin_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.dark.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isWalking ? 'Walking...' : 'You',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntranceMarker(double w, double h) {
    final pos = stopPositions[0]!;
    return Positioned(
      left: pos.dx * w - 16,
      top: pos.dy * h - 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.sky, width: 1.5),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.login_rounded, size: 12, color: AppColors.sky),
            const SizedBox(width: 3),
            Text(
              'Entrance',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopMarker(
      int stopNum, String letter, String title, Offset pos, double w, double h) {
    final isCurrent = widget.currentStopIndex == stopNum;
    final isDone = widget.currentStopIndex > stopNum;

    return Positioned(
      left: pos.dx * w - 20,
      top: pos.dy * h - 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: isCurrent ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? const Color(0xFF6BCB77)
                    : isCurrent
                        ? AppColors.coral
                        : Colors.white,
                border: Border.all(
                  color: isCurrent
                      ? Colors.white
                      : isDone
                          ? Colors.white
                          : AppColors.coral,
                  width: isCurrent ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCurrent
                        ? AppColors.coral.withValues(alpha: 0.5)
                        : Colors.black12,
                    blurRadius: isCurrent ? 14 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        letter,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? Colors.white : AppColors.dark,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? AppColors.coral : AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
