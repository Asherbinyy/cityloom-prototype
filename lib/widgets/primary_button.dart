import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isFullWidth;
  final IconData? icon;
  final double height;
  final double fontSize;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 54.0,
    this.fontSize = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    final child = SizedBox(
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSecondary
              ? Colors.white
              : (isEnabled ? AppColors.coral : AppColors.coral.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSecondary
                ? AppColors.coral.withValues(alpha: 0.4)
                : (isEnabled ? AppColors.coral : Colors.transparent),
            width: 1.5,
          ),
          boxShadow: isEnabled && !isSecondary
              ? [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: isSecondary ? AppColors.coral : Colors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: isSecondary ? AppColors.coral : Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: child,
      );
    }
    return child;
  }
}
