import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'synced_transcript.dart';

class AudioPlayerCard extends StatefulWidget {
  final String audioAsset;

  const AudioPlayerCard({
    super.key,
    required this.audioAsset,
  });

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;
  bool _isPlaying = false;
  bool _isSeeking = false;

  Transcript? _transcript;
  bool _isLoadingTranscript = true;
  bool _showTranscript = false;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;

  static const Map<String, Duration> _knownDurations = {
    'assets/audio/intro.mp3': Duration(seconds: 62),
    'assets/audio/mortsafes.mp3': Duration(minutes: 4, seconds: 33),
    'assets/audio/covenanters.mp3': Duration(minutes: 2, seconds: 33),
    'assets/audio/black_mausoleum.mp3': Duration(minutes: 3, seconds: 35),
  };

  @override
  void initState() {
    super.initState();
    _duration = _knownDurations[widget.audioAsset] ?? Duration.zero;
    _initAudioAndTranscript();
  }

  void _initAudioAndTranscript() {
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && state.processingState != ProcessingState.completed;
          if (state.processingState == ProcessingState.completed) {
            _position = Duration.zero;
          }
        });
      }
    });

    _durationSub = _player.durationStream.listen((dur) {
      if (mounted && dur != null && dur > Duration.zero) {
        setState(() => _duration = dur);
      }
    });

    _positionSub = _player.positionStream.listen((pos) {
      if (mounted && !_isSeeking) {
        setState(() => _position = pos);
      }
    });

    // 1. Load Transcript concurrently (fastest, sets exact millisecond duration)
    _loadTranscript();

    // 2. Load Audio in parallel
    _loadAudio();
  }

  Future<void> _loadTranscript() async {
    try {
      final transcriptPath = widget.audioAsset
          .replaceAll('assets/audio/', 'assets/transcripts/')
          .replaceAll('.mp3', '.json');
      final t = await Transcript.fromAsset(transcriptPath);
      if (mounted) {
        setState(() {
          _transcript = t;
          _isLoadingTranscript = false;
          if (t.durationMs > 0) {
            _duration = Duration(milliseconds: t.durationMs);
          }
        });
      }
    } catch (e) {
      debugPrint('No transcript found for ${widget.audioAsset}: $e');
      if (mounted) {
        setState(() {
          _transcript = null;
          _isLoadingTranscript = false;
        });
      }
    }
  }

  Future<void> _loadAudio() async {
    try {
      await _player.setAsset(widget.audioAsset);
    } catch (e) {
      debugPrint('Audio asset loading error for ${widget.audioAsset}: $e');
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    SoundService.playTap();
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  void _cycleSpeed() async {
    SoundService.playTap();
    double nextSpeed;
    if (_playbackSpeed == 1.0) {
      nextSpeed = 1.5;
    } else if (_playbackSpeed == 1.5) {
      nextSpeed = 2.0;
    } else if (_playbackSpeed == 2.0) {
      nextSpeed = 3.0;
    } else {
      nextSpeed = 1.0;
    }
    setState(() => _playbackSpeed = nextSpeed);
    try {
      await _player.setSpeed(nextSpeed);
    } catch (e) {
      debugPrint('Set speed error: $e');
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
          // Header Row
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

          // Main Play / Pause Button
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
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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

          // Synced Transcript Section
          const SizedBox(height: 14),
          const Divider(color: AppColors.blush, height: 1),
          const SizedBox(height: 8),

          // Toggle Show/Hide Transcript Button (Always visible immediately)
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  SoundService.playTap();
                  setState(() => _showTranscript = !_showTranscript);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showTranscript
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.subtitles_outlined,
                        size: 18,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _showTranscript ? 'Hide transcript' : 'Show transcript',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.coral,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Expanded Content Area
          if (_showTranscript) ...[
            const SizedBox(height: 8),
            if (_isLoadingTranscript)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.coral,
                    ),
                  ),
                ),
              )
            else if (_transcript != null)
              SyncedTranscriptView(
                player: _player,
                transcript: _transcript!,
                windowSize: 4,
                tapToSeek: true,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Transcript not available for this recording.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
