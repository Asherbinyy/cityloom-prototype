// synced_transcript.dart
//
// Karaoke-style synced transcript for CityLoom recordings.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_theme.dart';

// ============================== MODEL ==============================

class TranscriptWord {
  final String text;
  final int startMs;
  final int endMs;
  final int lineIndex;

  const TranscriptWord({
    required this.text,
    required this.startMs,
    required this.endMs,
    required this.lineIndex,
  });
}

class TranscriptLine {
  final String text;
  final int startMs;
  final int endMs;
  final int firstWordIndex;
  final int lastWordIndex;

  const TranscriptLine({
    required this.text,
    required this.startMs,
    required this.endMs,
    required this.firstWordIndex,
    required this.lastWordIndex,
  });
}

class Transcript {
  final List<TranscriptWord> words; // flat, sorted by startMs
  final List<TranscriptLine> lines;

  const Transcript({required this.words, required this.lines});

  int get durationMs => words.isNotEmpty ? words.last.endMs : 0;

  static Future<Transcript> fromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return Transcript.fromWhisperXJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  factory Transcript.fromWhisperXJson(Map<String, dynamic> json) {
    final words = <TranscriptWord>[];
    final lines = <TranscriptLine>[];

    final segments = (json['segments'] as List<dynamic>? ?? []);

    for (final rawSeg in segments) {
      final seg = rawSeg as Map<String, dynamic>;
      final rawWords = (seg['words'] as List<dynamic>? ?? []);
      if (rawWords.isEmpty) continue;

      final lineIndex = lines.length;
      final firstWordIndex = words.length;

      int? lastKnownEndMs;

      for (final rawWord in rawWords) {
        final w = rawWord as Map<String, dynamic>;
        final text = (w['word'] as String? ?? '').trim();
        if (text.isEmpty) continue;

        // WhisperX occasionally omits start/end on a token (numerals,
        // symbols). Fall back to the previous word's end so the list
        // stays monotonic — a non-monotonic list breaks binary search.
        final startSec = (w['start'] as num?)?.toDouble();
        final endSec = (w['end'] as num?)?.toDouble();

        final startMs = startSec != null
            ? (startSec * 1000).round()
            : (lastKnownEndMs ?? 0);
        final endMs = endSec != null
            ? (endSec * 1000).round()
            : startMs;

        words.add(TranscriptWord(
          text: text,
          startMs: startMs,
          endMs: endMs < startMs ? startMs : endMs,
          lineIndex: lineIndex,
        ));
        lastKnownEndMs = words.last.endMs;
      }

      if (words.length == firstWordIndex) continue; // segment produced nothing

      lines.add(TranscriptLine(
        text: (seg['text'] as String? ?? '').trim(),
        startMs: words[firstWordIndex].startMs,
        endMs: words.last.endMs,
        firstWordIndex: firstWordIndex,
        lastWordIndex: words.length - 1,
      ));
    }

    return Transcript(words: words, lines: lines);
  }

  /// Index of the word active at [positionMs], or the most recent one if we
  /// are sitting in a gap between words. Returns -1 before the first word.
  ///
  /// O(log n) — this is what makes scrubbing instant no matter how long
  /// the recording is.
  int wordIndexAt(int positionMs) {
    int lo = 0;
    int hi = words.length - 1;
    int result = -1;

    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (words[mid].startMs <= positionMs) {
        result = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return result;
  }
}

// ============================== WIDGET ==============================

class SyncedTranscriptView extends StatefulWidget {
  final AudioPlayer player;
  final Transcript transcript;

  /// How many lines to keep on screen at once.
  final int windowSize;

  /// Tapping a line seeks the player to it.
  final bool tapToSeek;

  const SyncedTranscriptView({
    super.key,
    required this.player,
    required this.transcript,
    this.windowSize = 4,
    this.tapToSeek = true,
  });

  @override
  State<SyncedTranscriptView> createState() => _SyncedTranscriptViewState();
}

class _SyncedTranscriptViewState extends State<SyncedTranscriptView>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  // ValueNotifier rather than setState: only the text repaints each frame,
  // not the whole subtree. This is the difference between smooth and janky.
  final ValueNotifier<int> _wordIndex = ValueNotifier<int>(-1);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration _) {
    // player.position is interpolated by just_audio from the last playback
    // event and already accounts for the current speed, so 2x/3x needs no
    // special handling here, and a seek is reflected on the very next frame.
    final posMs = widget.player.position.inMilliseconds;
    final idx = widget.transcript.wordIndexAt(posMs);
    if (idx != _wordIndex.value) {
      _wordIndex.value = idx;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _wordIndex.dispose();
    super.dispose();
  }

  /// Window of lines to render, keeping the active line one from the top so
  /// the reader can see what's coming.
  ({int start, int end}) _visibleRange(int activeLine) {
    final total = widget.transcript.lines.length;
    final size = widget.windowSize.clamp(1, total == 0 ? 1 : total);
    var start = activeLine - 1;
    if (start < 0) start = 0;
    if (start + size > total) start = total - size;
    if (start < 0) start = 0;
    return (start: start, end: (start + size).clamp(0, total));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transcript.lines.isEmpty) return const SizedBox.shrink();

    return ValueListenableBuilder<int>(
      valueListenable: _wordIndex,
      builder: (context, wordIdx, _) {
        final words = widget.transcript.words;
        final lines = widget.transcript.lines;

        final activeLine = wordIdx < 0 ? 0 : words[wordIdx].lineIndex;
        final range = _visibleRange(activeLine);

        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = range.start; i < range.end; i++)
                _LineView(
                  key: ValueKey(i),
                  line: lines[i],
                  words: words,
                  activeWordIndex: wordIdx,
                  isActiveLine: i == activeLine,
                  onTap: widget.tapToSeek
                      ? () => widget.player.seek(
                            Duration(milliseconds: lines[i].startMs),
                          )
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LineView extends StatelessWidget {
  final TranscriptLine line;
  final List<TranscriptWord> words;
  final int activeWordIndex;
  final bool isActiveLine;
  final VoidCallback? onTap;

  const _LineView({
    super.key,
    required this.line,
    required this.words,
    required this.activeWordIndex,
    required this.isActiveLine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.coral;
    const spokenColor = AppColors.dark;
    const upcomingColor = AppColors.muted;

    final spans = <TextSpan>[];
    for (int i = line.firstWordIndex; i <= line.lastWordIndex; i++) {
      final isCurrent = i == activeWordIndex;
      final isSpoken = i < activeWordIndex;

      spans.add(TextSpan(
        text: '${words[i].text} ',
        style: GoogleFonts.dmSans(
          color: isCurrent
              ? activeColor
              : (isSpoken ? spokenColor : upcomingColor),
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
        ),
      ));
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isActiveLine ? 1.0 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.dmSans(fontSize: 16, height: 1.45),
              children: spans,
            ),
          ),
        ),
      ),
    );
  }
}
