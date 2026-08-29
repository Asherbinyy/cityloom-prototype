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
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isDone = index < currentStep;
          final isCurrent = index == currentStep;

          Color barColor;
          if (isDone) {
            barColor = AppColors.coral;
          } else if (isCurrent) {
            barColor = AppColors.sky;
          } else {
            barColor = AppColors.blush;
          }

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 3,
                right: index == totalSteps - 1 ? 0 : 3,
              ),
              height: 4.5,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2.5),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.sky.withValues(alpha: 0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : (isDone
                        ? [
                            BoxShadow(
                              color: AppColors.coral.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null),
              ),
            ),
          );
        }),
      ),
    );
  }
}
