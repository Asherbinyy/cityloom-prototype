import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/audio_controller.dart';
import '../theme/app_theme.dart';

class AudioPlayerCard extends StatelessWidget {
  final String audioAsset;
  final String? scriptText;
  final String? title;

  const AudioPlayerCard({
    super.key,
    required this.audioAsset,
    this.scriptText,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioController>();
    final isCurrentTrack = audio.currentAsset != null &&
        audioAsset.contains(audio.currentAsset!);
    final isPlaying = isCurrentTrack && audio.isPlaying;
    
    final currentPos = isCurrentTrack ? audio.position : Duration.zero;
    final totalDur = isCurrentTrack ? audio.duration : Duration.zero;
    final progress = (totalDur.inMilliseconds > 0)
        ? (currentPos.inMilliseconds / totalDur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.blush,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coral.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Player Controls Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    // Play / Pause Circle
                    GestureDetector(
                      onTap: () => audio.togglePlay(audioAsset),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Progress slider & timers
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.coral,
                              inactiveTrackColor: AppColors.blush,
                              thumbColor: AppColors.coral,
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                            ),
                            child: Slider(
                              value: progress,
                              onChanged: (val) {
                                if (totalDur.inMilliseconds > 0) {
                                  final newPos = Duration(
                                    milliseconds: (val * totalDur.inMilliseconds).toInt(),
                                  );
                                  audio.seek(newPos);
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  audio.formatDuration(currentPos),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  audio.formatDuration(totalDur),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.blush),
                const SizedBox(height: 10),

                // Control Actions: Speed Toggle & Show Script
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Speed Toggle Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => audio.toggleSpeed(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.coral.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.speed_rounded,
                                size: 14,
                                color: AppColors.coral,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${audio.playbackSpeed}x',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Show Script Button
                    if (scriptText != null && scriptText!.isNotEmpty)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => audio.toggleScript(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: audio.isScriptExpanded
                                  ? AppColors.coral.withValues(alpha: 0.12)
                                  : AppColors.cream,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.coral.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  audio.isScriptExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: AppColors.coral,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  audio.isScriptExpanded
                                      ? 'Hide Script'
                                      : 'Show Script',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.coral,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable Script Section
          if (scriptText != null && scriptText!.isNotEmpty)
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF9F5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 16, color: AppColors.blush),
                    const Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'STORY SCRIPT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scriptText!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.6,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: audio.isScriptExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
        ],
      ),
    );
  }
}
