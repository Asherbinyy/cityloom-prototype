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
    this.height = 52.0,
    this.fontSize = 15.5,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    final buttonWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      decoration: BoxDecoration(
        color: isSecondary
            ? const Color(0xFFFFF1E8)
            : (isEnabled
                ? AppColors.coral
                : AppColors.coral.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isSecondary
              ? const Color(0xFFFDA692)
              : (isEnabled ? AppColors.coral : Colors.transparent),
          width: 1.6,
        ),
        boxShadow: (isEnabled && !isSecondary)
            ? [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.38),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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
          borderRadius: BorderRadius.circular(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
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
                                ? AppColors.dark
                                : Colors.white,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: GoogleFonts.dmSans(
                            fontSize: fontSize,
                            fontWeight:
                                isSecondary ? FontWeight.w500 : FontWeight.w600,
                            color: isSecondary
                                ? AppColors.dark
                                : Colors.white,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
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
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
