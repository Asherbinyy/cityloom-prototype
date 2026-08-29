import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tour_model.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class AudioPlayerCard extends StatefulWidget {
  final String audioAsset;
  final String? storyScript;
  final List<TourSubtitle> subtitles;

  const AudioPlayerCard({
    super.key,
    required this.audioAsset,
    this.storyScript,
    this.subtitles = const [],
  });

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  final AudioPlayer _player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;

  bool _isSeeking = false;
  bool _showScript = false;

  StreamSubscription? _stateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });

    _durationSub = _player.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });

    _positionSub = _player.onPositionChanged.listen((pos) {
      if (mounted && !_isSeeking) {
        setState(() => _position = pos);
      }
    });

    try {
      final cleanPath = widget.audioAsset.replaceFirst('assets/', '');
      await _player.setSource(AssetSource(cleanPath));
    } catch (e) {
      debugPrint('Audio source setup error: $e');
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    SoundService.playTap();
    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  void _cycleSpeed() async {
    SoundService.playTap();
    double nextSpeed;
    if (_playbackSpeed == 1.0) {
      nextSpeed = 1.5;
    } else if (_playbackSpeed == 1.5) {
      nextSpeed = 2.0;
    } else {
      nextSpeed = 1.0;
    }
    setState(() => _playbackSpeed = nextSpeed);
    await _player.setPlaybackRate(nextSpeed);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;
    final progress = (_duration.inMilliseconds > 0)
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cream,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Row (Clean, no dark dots!)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AUDIO STORY',
                style: GoogleFonts.dmSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.coral,
                ),
              ),

              // Minimalist Speed Pill
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _cycleSpeed,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.coral.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${_playbackSpeed.toStringAsFixed(1)}x',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Play / Pause Button (Clean Coral Circle)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _togglePlayPause,
              borderRadius: BorderRadius.circular(35),
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coral.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Audio Progress Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: AppColors.coral,
              inactiveTrackColor: AppColors.blush,
              thumbColor: AppColors.coral,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: progress,
              onChangeStart: (_) => _isSeeking = true,
              onChanged: (val) {
                setState(() {
                  _position = Duration(
                    milliseconds: (val * _duration.inMilliseconds).toInt(),
                  );
                });
              },
              onChangeEnd: (val) async {
                _isSeeking = false;
                final target = Duration(
                  milliseconds: (val * _duration.inMilliseconds).toInt(),
                );
                await _player.seek(target);
              },
            ),
          ),

          // Time Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          // Script Toggle Button ("Show Script" / "Hide Script")
          if (widget.storyScript != null) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.blush, height: 1),
            const SizedBox(height: 8),

            TextButton.icon(
              onPressed: () {
                SoundService.playTap();
                setState(() => _showScript = !_showScript);
              },
              icon: Icon(
                _showScript
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.subtitles_rounded,
                size: 18,
                color: AppColors.coral,
              ),
              label: Text(
                _showScript ? 'Hide Script' : 'Show Script',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.coral,
                ),
              ),
            ),

            // Live Highlighted Script Box
            if (_showScript) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.coral.withValues(alpha: 0.3),
                  ),
                ),
                child: _buildLiveScriptContent(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLiveScriptContent() {
    final currentSec = _position.inMilliseconds / 1000.0;

    if (widget.subtitles.isEmpty) {
      return Text(
        widget.storyScript ?? '',
        style: GoogleFonts.dmSans(
          fontSize: 14,
          height: 1.5,
          color: AppColors.dark,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.subtitles.map((sub) {
        final isActive = currentSec >= sub.startSeconds && currentSec < sub.endSeconds;
        final isPast = currentSec >= sub.endSeconds;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            sub.text,
            style: GoogleFonts.dmSans(
              fontSize: isActive ? 15 : 13.5,
              fontWeight: isActive ? FontWeight.w800 : (isPast ? FontWeight.w500 : FontWeight.w400),
              color: isActive
                  ? AppColors.dark
                  : (isPast
                      ? AppColors.dark.withValues(alpha: 0.75)
                      : AppColors.muted.withValues(alpha: 0.6)),
              height: 1.45,
            ),
          ),
        );
      }).toList(),
    );
  }
}
