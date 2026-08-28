import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/tour_model.dart';
import '../services/sound_service.dart';
import '../state/audio_controller.dart';
import '../theme/app_theme.dart';

class AudioPlayerCard extends StatefulWidget {
  final String audioAsset;
  final String? scriptText;
  final List<TourSubtitle> subtitles;
  final String? title;

  const AudioPlayerCard({
    super.key,
    required this.audioAsset,
    this.scriptText,
    this.subtitles = const [],
    this.title,
  });

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  bool _showFullTranscript = false;

  TourSubtitle? _getActiveSubtitle(double currentSec) {
    if (widget.subtitles.isEmpty) return null;
    for (final sub in widget.subtitles) {
      if (currentSec >= sub.startSeconds && currentSec < sub.endSeconds) {
        return sub;
      }
    }
    // If before start or after end
    if (currentSec < widget.subtitles.first.startSeconds) {
      return widget.subtitles.first;
    }
    return widget.subtitles.last;
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioController>();
    final isCurrentTrack = audio.currentAsset != null &&
        widget.audioAsset.contains(audio.currentAsset!);
    final isPlaying = isCurrentTrack && audio.isPlaying;

    final currentPos = isCurrentTrack ? audio.position : Duration.zero;
    final totalDur = isCurrentTrack ? audio.duration : Duration.zero;
    final currentSec = currentPos.inMilliseconds / 1000.0;

    final progress = (totalDur.inMilliseconds > 0)
        ? (currentPos.inMilliseconds / totalDur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final activeSubtitle = _getActiveSubtitle(currentSec);

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
            color: AppColors.coral.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Player Controls Row
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    // Play / Pause Circle Button
                    GestureDetector(
                      onTap: () {
                        SoundService.playTap();
                        audio.togglePlay(widget.audioAsset);
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Progress slider & timestamps
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.coral,
                              inactiveTrackColor: AppColors.blush,
                              thumbColor: AppColors.coral,
                              trackHeight: 5,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
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
                                    milliseconds:
                                        (val * totalDur.inMilliseconds).toInt(),
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
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  audio.formatDuration(totalDur),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
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

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.blush),
                const SizedBox(height: 12),

                // Control Actions: Minimalist Speed Toggle & Transcript
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Speed Toggle Button (NO icon, clean minimalist pill)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          SoundService.playTap();
                          audio.toggleSpeed();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.coral.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '${audio.playbackSpeed}x',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.coral,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Full Script / Lyrics toggle
                    if (widget.scriptText != null &&
                        widget.scriptText!.isNotEmpty)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            SoundService.playTap();
                            setState(() {
                              _showFullTranscript = !_showFullTranscript;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _showFullTranscript
                                  ? AppColors.coral.withValues(alpha: 0.12)
                                  : AppColors.cream,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.coral.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showFullTranscript
                                      ? Icons.subtitles_off_rounded
                                      : Icons.subtitles_rounded,
                                  size: 15,
                                  color: AppColors.coral,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _showFullTranscript
                                      ? 'Live Lyrics'
                                      : 'Full Script',
                                  style: GoogleFonts.dmSans(
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

          // SPOTIFY-STYLE LIVE SYNCED LYRICS OR FULL TRANSCRIPT
          if (!_showFullTranscript && activeSubtitle != null) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.cream,
                    AppColors.blush.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.coral.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isPlaying ? AppColors.coral : AppColors.muted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPlaying ? 'NOW SPEAKING' : 'AUDIO NARRATION',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.coral,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      activeSubtitle.text,
                      key: ValueKey(activeSubtitle.text),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_showFullTranscript &&
              widget.scriptText != null &&
              widget.scriptText!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.coral.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                widget.scriptText!,
                style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  height: 1.6,
                  color: AppColors.dark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
