import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MapInteractiveWidget extends StatefulWidget {
  final int currentStopIndex; // 1: Stop A, 2: Stop B, 3: Stop C
  final VoidCallback? onStopTap;

  const MapInteractiveWidget({
    super.key,
    required this.currentStopIndex,
    this.onStopTap,
  });

  @override
  State<MapInteractiveWidget> createState() => _MapInteractiveWidgetState();
}

class _MapInteractiveWidgetState extends State<MapInteractiveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnim;
  late Animation<double> _walkAnim;

  // Normalized stop positions (x, y) on the map image
  final Map<int, Offset> stopPositions = {
    0: const Offset(0.50, 0.90), // Entrance
    1: const Offset(0.56, 0.60), // Stop A: Mortsafes
    2: const Offset(0.28, 0.30), // Stop B: Covenanters' Prison
    3: const Offset(0.25, 0.46), // Stop C: Black Mausoleum
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _walkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
            color: AppColors.coral.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 1.2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: [
                  // Map Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/map.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE8F1F5),
                        child: const Center(
                          child: Icon(Icons.map_rounded, size: 60, color: AppColors.sky),
                        ),
                      ),
                    ),
                  ),

                  // Stop Markers (A, B, C)
                  _buildStopMarker(1, 'A', 'Mortsafes', stopPositions[1]!, w, h),
                  _buildStopMarker(2, 'B', "Covenanters'", stopPositions[2]!, w, h),
                  _buildStopMarker(3, 'C', 'Mausoleum', stopPositions[3]!, w, h),

                  // Walking Explorer Avatar & Destination Flag
                  _buildWalkingCharacter(w, h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStopMarker(
    int stopNum,
    String letter,
    String label,
    Offset normPos,
    double w,
    double h,
  ) {
    final isTarget = widget.currentStopIndex == stopNum;
    final isPassed = widget.currentStopIndex > stopNum;
    final x = normPos.dx * w;
    final y = normPos.dy * h;

    return Positioned(
      left: x - 18,
      top: y - 18,
      child: GestureDetector(
        onTap: widget.onStopTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: isTarget ? _pulseAnim.value : 1.0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isTarget
                          ? AppColors.coral
                          : (isPassed ? AppColors.dark : Colors.white),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isTarget ? Colors.white : AppColors.coral,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isTarget ? AppColors.coral : Colors.black)
                              .withValues(alpha: 0.3),
                          blurRadius: isTarget ? 10 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: (isTarget || isPassed) ? Colors.white : AppColors.dark,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkingCharacter(double w, double h) {
    final targetPos = stopPositions[widget.currentStopIndex] ?? const Offset(0.5, 0.5);
    final targetX = targetPos.dx * w;
    final targetY = targetPos.dy * h;

    return Positioned(
      left: targetX + 10,
      top: targetY - 32,
      child: AnimatedBuilder(
        animation: _walkAnim,
        builder: (context, child) {
          final bobOffset = (_walkAnim.value * 4) - 2;
          return Transform.translate(
            offset: Offset(0, bobOffset),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.coral, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_pin_circle_rounded,
                color: AppColors.coral,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}
