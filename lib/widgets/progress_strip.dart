import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressStrip extends StatelessWidget {
  final int currentStep; // 0: intro, 1: stopA, 2: stopB, 3: stopC, 4: complete
  final int totalSteps;

  const ProgressStrip({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isDone = index < currentStep;
          final isCurrent = index == currentStep;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isCurrent ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.coral
                  : (isDone ? AppColors.coral.withValues(alpha: 0.7) : AppColors.blush),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.coral.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
