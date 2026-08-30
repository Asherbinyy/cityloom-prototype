import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double? aspectRatio;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    Widget box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.blush.withValues(alpha: 0.65),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.7),
        );

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: box,
      );
    }
    return box;
  }
}

class AppImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Alignment alignment;

  const AppImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return ShimmerPlaceholder(
          width: width,
          height: height,
          borderRadius: borderRadius,
          aspectRatio: aspectRatio,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: Border.all(color: AppColors.blush),
          ),
          child: const Center(
            child: Icon(Icons.image_not_supported_rounded,
                color: AppColors.muted, size: 28),
          ),
        );
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: image,
      );
    }

    return image;
  }
}
