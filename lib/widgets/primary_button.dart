import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isFullWidth;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double fontSize;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isFullWidth = true,
    this.isLoading = false,
    this.icon,
    this.height = 54.0,
    this.fontSize = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    final child = SizedBox(
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSecondary
              ? Colors.white
              : (isEnabled
                  ? AppColors.coral
                  : AppColors.coral.withValues(alpha: 0.5)),
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
                    color: AppColors.coral.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled
                ? () {
                    SoundService.playTap();
                    onPressed!();
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSecondary ? AppColors.coral : Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: 18,
                              color: isSecondary
                                  ? AppColors.coral
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            text,
                            style: GoogleFonts.dmSans(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w700,
                              color: isSecondary
                                  ? AppColors.dark
                                  : (isEnabled
                                      ? Colors.white
                                      : Colors.white
                                          .withValues(alpha: 0.8)),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
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
