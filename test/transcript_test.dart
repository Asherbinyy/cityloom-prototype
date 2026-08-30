import 'package:flutter_test/flutter_test.dart';
import 'package:cityloom_prototype/widgets/synced_transcript.dart';

void main() {
  group('Transcript Model & Timing Tests', () {
    final sampleJson = {
      "language": "en",
      "text": "The National Covenant was signed here in 1638.",
      "segments": [
        {
          "start": 0.0,
          "end": 4.28,
          "text": "The National Covenant was signed here in 1638.",
          "words": [
            {"word": "The", "start": 0.02, "end": 0.18, "probability": 0.99},
            {"word": "National", "start": 0.18, "end": 0.61, "probability": 0.98},
            {"word": "Covenant", "start": 0.61, "end": 1.09, "probability": 0.99},
            {"word": "was", "start": 1.15, "end": 1.30, "probability": 0.95},
            {"word": "signed", "start": 1.32, "end": 1.80, "probability": 0.99},
            {"word": "here", "start": 1.82, "end": 2.10, "probability": 0.99},
            {"word": "in", "start": 2.12, "end": 2.25, "probability": 0.98},
            {"word": "1638.", "start": 2.28, "end": 3.10, "probability": 0.97}
          ]
        }
      ]
    };

    test('Transcript parses WhisperX JSON correctly into lines and words', () {
      final transcript = Transcript.fromWhisperXJson(sampleJson);

      expect(transcript.lines.length, equals(1));
      expect(transcript.lines.first.text, equals("The National Covenant was signed here in 1638."));
      expect(transcript.words.length, equals(8));
      expect(transcript.words[0].text, equals("The"));
      expect(transcript.words[0].startMs, equals(20));
      expect(transcript.words[0].endMs, equals(180));
      expect(transcript.words[2].text, equals("Covenant"));
      expect(transcript.words[2].startMs, equals(610));
      expect(transcript.words[2].endMs, equals(1090));
    });

    test('Transcript wordIndexAt returns correct index via binary search', () {
      final transcript = Transcript.fromWhisperXJson(sampleJson);

      // Before first word
      expect(transcript.wordIndexAt(10), equals(-1));

      // In "The" (20ms - 180ms)
      expect(transcript.wordIndexAt(25), equals(0));
      expect(transcript.wordIndexAt(100), equals(0));

      // In "National" (180ms - 610ms)
      expect(transcript.wordIndexAt(180), equals(1));
      expect(transcript.wordIndexAt(500), equals(1));

      // In "Covenant" (610ms - 1090ms)
      expect(transcript.wordIndexAt(700), equals(2));

      // In gap between "Covenant" (end 1090ms) and "was" (start 1150ms)
      expect(transcript.wordIndexAt(1100), equals(2));

      // In "was" (1150ms)
      expect(transcript.wordIndexAt(1160), equals(3));

      // At the end
      expect(transcript.wordIndexAt(3000), equals(7));
      expect(transcript.wordIndexAt(5000), equals(7));
    });
  });
}
