import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/card_data.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class FlyToLibraryAnimation {
  static void fly(
    BuildContext context, {
    required String cardId,
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _FlyCardWidget(
        cardId: cardId,
        onFinished: () {
          entry.remove();
          SoundService.playTap();
          onComplete?.call();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _FlyCardWidget extends StatefulWidget {
  final String cardId;
  final VoidCallback onFinished;

  const _FlyCardWidget({
    required this.cardId,
    required this.onFinished,
  });

  @override
  State<_FlyCardWidget> createState() => _FlyCardWidgetState();
}

class _FlyCardWidgetState extends State<_FlyCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward().then((_) {
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final card = CardData.cards[widget.cardId];

    // Origin: Screen Center
    final startX = size.width / 2;
    final startY = size.height / 2;

    // Target: Top-right library icon position (centered inside 480px AppScaffold max width)
    final contentWidth = math.min(size.width, 480.0);
    final targetX = (size.width + contentWidth) / 2 - 48.0;
    final targetY = MediaQuery.of(context).padding.top + 24.0;

    // Control point for a high curved arc trajectory
    final controlX = (startX + targetX) / 2 + 20.0;
    final controlY = math.max(10.0, targetY - 20.0);

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final t = _progress.value;

        // Quadratic Bezier Formula: B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
        final oneMinusT = 1.0 - t;
        final currentX = oneMinusT * oneMinusT * startX +
            2 * oneMinusT * t * controlX +
            t * t * targetX;
        final currentY = oneMinusT * oneMinusT * startY +
            2 * oneMinusT * t * controlY +
            t * t * targetY;

        final currentScale = (1.0 - (t * 0.82)).clamp(0.08, 1.0);
        final currentOpacity = (1.0 - (t * 0.85)).clamp(0.0, 1.0);
        final currentRotation = math.sin(t * math.pi) * 0.25;

        return Positioned(
          left: currentX - (55 * currentScale),
          top: currentY - (75 * currentScale),
          child: IgnorePointer(
            child: Opacity(
              opacity: currentOpacity,
              child: Transform.rotate(
                angle: currentRotation,
                child: Transform.scale(
                  scale: currentScale,
                  child: Container(
                    width: 110,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE5A93B),
                        width: 3.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE5A93B).withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: AppColors.coral.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: card != null
                          ? Image.asset(
                              card.imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.cream,
                                child: const Icon(
                                  Icons.auto_stories_rounded,
                                  color: AppColors.coral,
                                  size: 40,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.coral,
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
