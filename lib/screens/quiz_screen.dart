import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/quiz_data.dart';
import '../models/quiz_model.dart';
import '../services/analytics_service.dart';
import '../services/sound_service.dart';
import '../services/tts_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_reveal_dialog.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/congratulations_dialog.dart';
import '../widgets/fly_to_library_animation.dart';
import '../widgets/learn_more_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/quit_quiz_dialog.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQIndex = 0;
  int _score = 0;

  // Question Response States
  int? _selectedSingleIndex;
  bool? _selectedTF;
  final Set<int> _selectedMultiIndices = {};
  String? _selectedFillGapOption;

  // Matching state (left index -> right index)
  final Map<int, int> _selectedPairs = {};
  int? _activeMatchLeftIndex;

  // Ordering state
  List<int> _currentOrderIndices = [];

  bool _isAnswered = false;
  bool _isLastAnswerCorrect = false;
  bool _unlockDialogsProcessed = false;

  // TTS & Audio Narration States
  bool _isAudioBarVisible = false;
  bool _isAutoNarrateEnabled = false;
  bool _isAudioPlaying = false;
  bool _isAudioPaused = false;
  double _currentSpeechRate = 1.0;
  bool _isListeningSpeech = false;
  String? _speechFeedbackText;
  bool _hasTriggeredCongratsSound = false;

  static const List<Color> matchBorderColors = [
    Color(0xFF9B59B6), // Purple
    Color(0xFFE6A817), // Gold/Amber
    Color(0xFF3498DB), // Blue
    Color(0xFF27AE60), // Green
    Color(0xFFE74C3C), // Red
  ];

  static const List<Color> matchBgColors = [
    Color(0x1F9B59B6),
    Color(0x1FE6A817),
    Color(0x1F3498DB),
    Color(0x1F27AE60),
    Color(0x1FE74C3C),
  ];

  bool _initializedFromState = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedFromState) {
      final appState = context.read<AppState>();
      _currentQIndex = appState.activeQuizQIndex;
      _score = appState.activeQuizScore;
      _selectedSingleIndex = appState.activeQuizSingleIndex;
      _selectedTF = appState.activeQuizTF;
      _selectedMultiIndices.clear();
      _selectedMultiIndices.addAll(appState.activeQuizMultiIndices);
      _selectedFillGapOption = appState.activeQuizFillGapOption;
      _selectedPairs.clear();
      _selectedPairs.addAll(appState.activeQuizPairs);
      _currentOrderIndices = List.from(appState.activeQuizOrderIndices);
      _isAnswered = appState.activeQuizIsAnswered;
      _isLastAnswerCorrect = appState.activeQuizIsLastAnswerCorrect;
      _initializedFromState = true;
    }
  }

  void _syncToAppState(AppState appState) {
    appState.updateActiveQuizProgress(
      qIndex: _currentQIndex,
      score: _score,
      singleIndex: _selectedSingleIndex,
      tfVal: _selectedTF,
      multiIndices: _selectedMultiIndices,
      fillGapOption: _selectedFillGapOption,
      pairs: _selectedPairs,
      orderIndices: _currentOrderIndices,
      isAnswered: _isAnswered,
      isLastAnswerCorrect: _isLastAnswerCorrect,
    );
  }

  void _resetQuestionState({bool advanceQuestion = false, AppState? appState}) {
    _selectedSingleIndex = null;
    _selectedTF = null;
    _selectedMultiIndices.clear();
    _selectedFillGapOption = null;
    _selectedPairs.clear();
    _activeMatchLeftIndex = null;
    _currentOrderIndices.clear();
    _isAnswered = false;
    _isLastAnswerCorrect = false;
    _speechFeedbackText = null;
    _isListeningSpeech = false;
    _unlockDialogsProcessed = false;

    if (_isAutoNarrateEnabled && advanceQuestion) {
      _isAudioPlaying = true;
      _isAudioPaused = false;
      _isAudioBarVisible = true;
    } else if (!advanceQuestion) {
      _isAudioPlaying = false;
      _isAudioPaused = false;
      _isAudioBarVisible = false;
      _isAutoNarrateEnabled = false;
      _hasTriggeredCongratsSound = false;
      TtsService.stop();
    }

    if (appState != null) {
      _syncToAppState(appState);
    }
  }

  void _playQuestionAudio(QuizQuestion q) {
    setState(() {
      _isAudioBarVisible = true;
      _isAutoNarrateEnabled = true;
      _isAudioPlaying = true;
      _isAudioPaused = false;
    });
    TtsService.readQuestion(q, speed: _currentSpeechRate);
  }

  void _cycleSpeechSpeed(QuizQuestion q) {
    setState(() {
      if (_currentSpeechRate == 1.0) {
        _currentSpeechRate = 1.25;
      } else if (_currentSpeechRate == 1.25) {
        _currentSpeechRate = 1.5;
      } else {
        _currentSpeechRate = 1.0;
      }
    });
    TtsService.setSpeed(_currentSpeechRate);
  }

  void _closeAudioNarration() {
    setState(() {
      _isAudioBarVisible = false;
      _isAutoNarrateEnabled = false;
      _isAudioPlaying = false;
      _isAudioPaused = false;
      _speechFeedbackText = null;
    });
    TtsService.stop();
  }

  void _handleVoiceAnswerInput(QuizQuestion q, AppState appState) {
    if (_isAnswered) return;
    setState(() {
      _isListeningSpeech = true;
      _speechFeedbackText = 'Listening... Speak your answer';
    });

    final success = TtsService.startListening((transcript) {
      if (mounted) {
        _parseAndSelectAnswer(transcript, q, appState);
      }
    });

    if (!success) {
      setState(() {
        _isListeningSpeech = false;
        _speechFeedbackText = 'Voice input not supported in this browser.';
      });
    }
  }

  void _parseAndSelectAnswer(
      String rawTranscript, QuizQuestion q, AppState appState) {
    final text = rawTranscript.trim().toLowerCase();
    setState(() {
      _isListeningSpeech = false;
      _speechFeedbackText = 'Recognized: "$rawTranscript"';
    });

    if (q.type == QuestionType.single || q.type == QuestionType.oddOneOut) {
      int? foundIndex;
      if (text.contains('one') || text.contains('1') || text.contains('first')) {
        foundIndex = 0;
      } else if (text.contains('two') || text.contains('2') || text.contains('second')) {
        foundIndex = 1;
      } else if (text.contains('three') || text.contains('3') || text.contains('third')) {
        foundIndex = 2;
      } else if (text.contains('four') || text.contains('4') || text.contains('fourth')) {
        foundIndex = 3;
      } else {
        for (int i = 0; i < q.options.length; i++) {
          if (text.contains(q.options[i].toLowerCase()) ||
              q.options[i].toLowerCase().contains(text)) {
            foundIndex = i;
            break;
          }
        }
      }
      if (foundIndex != null && foundIndex < q.options.length) {
        setState(() => _selectedSingleIndex = foundIndex);
      }
    } else if (q.type == QuestionType.trueFalse) {
      if (text.contains('true') || text.contains('yes') || text.contains('correct') || text.contains('1')) {
        setState(() => _selectedTF = true);
      } else if (text.contains('false') || text.contains('no') || text.contains('wrong') || text.contains('2')) {
        setState(() => _selectedTF = false);
      }
    } else if (q.type == QuestionType.fillGapSingle) {
      String? foundOpt;
      for (final opt in q.options) {
        if (text.contains(opt.toLowerCase())) {
          foundOpt = opt;
          break;
        }
      }
      if (foundOpt != null) {
        setState(() => _selectedFillGapOption = foundOpt);
      }
    } else if (q.type == QuestionType.multiSelect) {
      for (int i = 0; i < q.options.length; i++) {
        if (text.contains(q.options[i].toLowerCase()) ||
            q.options[i].toLowerCase().contains(text)) {
          setState(() {
            if (_selectedMultiIndices.contains(i)) {
              _selectedMultiIndices.remove(i);
            } else {
              _selectedMultiIndices.add(i);
            }
          });
        }
      }
    }
  }

  void _initOrderIndices(QuizQuestion q) {
    if (_currentOrderIndices.isEmpty && q.orderItems != null) {
      _currentOrderIndices =
          List.generate(q.orderItems!.length, (index) => index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    switch (appState.currentScreen) {
      case AppScreen.quizSelect:
        return _buildDifficultySelectView(context, appState);
      case AppScreen.quizRunner:
        return _buildQuestionRunnerView(context, appState);
      case AppScreen.quizResult:
        return _buildResultsView(context, appState);
      default:
        return _buildDifficultySelectView(context, appState);
    }
  }

  // ================= 1. DIFFICULTY SELECT VIEW =================
  Widget _buildDifficultySelectView(BuildContext context, AppState appState) {
    return AppScaffold(
      topBarTitle: 'Select Difficulty',
      onBack: () {
        SoundService.playTap();
        appState.goBack();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          Text(
            'CHOOSE YOUR CHALLENGE',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.coral,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          Text(
            'Kirkyard Quiz',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Choose your challenge level. Higher tiers unlock rarer historical cards!',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.muted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Difficulty Cards
          ...QuizDifficulty.values.map((diff) {
            final level = QuizData.levels[diff]!;
            final best = appState.bestScores[diff.id];
            final totalQ = level.questions.length;
            final isPerfect = best != null && best == totalQ;

            Color accentColor;
            switch (diff) {
              case QuizDifficulty.explorer:
                accentColor = const Color(0xFF2A2A2A);
                break;
              case QuizDifficulty.apprentice:
                accentColor = const Color(0xFF2563EB);
                break;
              case QuizDifficulty.historian:
                accentColor = AppColors.coral;
                break;
              case QuizDifficulty.scholar:
                accentColor = const Color(0xFFD97706);
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isPerfect ? accentColor : AppColors.blush,
                  width: isPerfect ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.1),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    SoundService.playTap();
                    setState(() {
                      _currentQIndex = 0;
                      _score = 0;
                      _resetQuestionState();
                    });
                    appState.selectQuizDifficulty(diff);
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.label,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      diff.index + 1,
                                      (sIdx) => const Padding(
                                        padding: EdgeInsets.only(right: 2),
                                        child: Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFE5A93B),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '•  $totalQ questions',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (best != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isPerfect
                                  ? const Color(0xFFE8F8EA)
                                  : const Color(0xFFFDEADA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isPerfect
                                    ? const Color(0xFF6BCB77)
                                    : AppColors.coral.withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Best: $best/$totalQ',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isPerfect
                                        ? const Color(0xFF2D7A36)
                                        : AppColors.dark,
                                  ),
                                ),
                                if (isPerfect) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Color(0xFFE5A93B),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),

          // Skip Quiz Button (as in HTML: <button onclick="goTo('screen-survey')">Skip Quiz</button>)
          PrimaryButton(
            text: 'Skip Quiz',
            isSecondary: true,
            onPressed: () {
              SoundService.playTap();
              appState.navigateTo(AppScreen.survey);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ================= 2. QUESTION RUNNER VIEW =================
  Widget _buildQuestionRunnerView(BuildContext context, AppState appState) {
    final level = QuizData.levels[appState.selectedDifficulty]!;
    final questions = level.questions;
    final q = questions[_currentQIndex];

    if (q.type == QuestionType.order) {
      _initOrderIndices(q);
    }

    return AppScaffold(
      topBarTitle: '${level.label} Quiz',
      onBack: () => _promptQuitQuiz(context, appState),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Progress Indicator & Audio TTS Read-Aloud
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUESTION ${_currentQIndex + 1} OF ${questions.length}',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.coral,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        SoundService.playTap();
                        if (_isAudioBarVisible) {
                          _closeAudioNarration();
                        } else {
                          _playQuestionAudio(q);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _isAudioBarVisible
                              ? const Color(0xFFFFF0E6)
                              : AppColors.cream,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isAudioBarVisible
                                ? AppColors.coral
                                : AppColors.blush,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isAudioBarVisible
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_up_outlined,
                              size: 14,
                              color: _isAudioBarVisible
                                  ? AppColors.coral
                                  : AppColors.dark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isAudioBarVisible ? 'Active' : 'Listen',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isAudioBarVisible
                                    ? AppColors.coral
                                    : AppColors.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.coral.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Score: $_score',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentQIndex + 1) / questions.length,
              backgroundColor: AppColors.blush,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.coral),
              minHeight: 6,
            ),
          ),

          // Dedicated Interactive Audio Overlay Bar (Underneath Question Bar)
          if (_isAudioBarVisible) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.coral.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 1. Play / Pause Button
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(
                            _isAudioPlaying && !_isAudioPaused
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            color: AppColors.coral,
                            size: 28,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            SoundService.playTap();
                            if (_isAudioPlaying && !_isAudioPaused) {
                              TtsService.pause();
                              setState(() => _isAudioPaused = true);
                            } else if (_isAudioPaused) {
                              TtsService.resume();
                              setState(() => _isAudioPaused = false);
                            } else {
                              _playQuestionAudio(q);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 2. Restart Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            SoundService.playTap();
                            _playQuestionAudio(q);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.replay_rounded,
                                    size: 16, color: AppColors.dark),
                                const SizedBox(width: 3),
                                Text(
                                  'Restart',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 3. Speed Button (1.0x, 1.25x, 1.5x)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _cycleSpeechSpeed(q),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.blush),
                            ),
                            child: Text(
                              '${_currentSpeechRate.toStringAsFixed(_currentSpeechRate == 1.0 ? 0 : 2)}x',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),

                      // 4. Voice Answer Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _handleVoiceAnswerInput(q, appState),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isListeningSpeech
                                  ? const Color(0xFFFFD1D1)
                                  : AppColors.coral,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isListeningSpeech
                                      ? Icons.mic_rounded
                                      : Icons.mic_none_rounded,
                                  size: 13,
                                  color: _isListeningSpeech
                                      ? const Color(0xFFA33333)
                                      : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isListeningSpeech ? 'Listening...' : 'Voice',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _isListeningSpeech
                                        ? const Color(0xFFA33333)
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // 5. Close Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            SoundService.playTap();
                            _closeAudioNarration();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close_rounded,
                                size: 16, color: AppColors.muted),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_speechFeedbackText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _speechFeedbackText!,
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),
          ],
          const SizedBox(height: 20),

          // Question Prompt
          Text(
            q.question,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
              height: 1.35,
            ),
          ),
          if (q.instruction != null) ...[
            const SizedBox(height: 6),
            Text(
              q.instruction!,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.coral,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Interactive Question Component
          _buildQuestionBody(q, appState),

          const SizedBox(height: 20),

          // Feedback Box (Styled exactly as HTML)
          if (_isAnswered) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLastAnswerCorrect
                    ? const Color(0xFFE8F8EA)
                    : const Color(0xFFFCE8E8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isLastAnswerCorrect
                      ? const Color(0xFF6BCB77)
                      : const Color(0xFFE74C3C),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isLastAnswerCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _isLastAnswerCorrect
                        ? const Color(0xFF2D7A36)
                        : const Color(0xFFA33333),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isLastAnswerCorrect
                          ? 'Correct! ${q.explanation}'
                          : 'Incorrect. ${q.explanation}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        height: 1.45,
                        color: _isLastAnswerCorrect
                            ? const Color(0xFF2D7A36)
                            : const Color(0xFFA33333),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 20),

            // Next / Finish Button
            PrimaryButton(
              text: _currentQIndex + 1 < questions.length
                  ? 'Next Question'
                  : 'See Results',
              onPressed: () {
                SoundService.playTap();
                if (_currentQIndex + 1 < questions.length) {
                  setState(() {
                    _currentQIndex++;
                    _resetQuestionState(
                        advanceQuestion: true, appState: appState);
                  });
                  if (_isAutoNarrateEnabled) {
                    final nextQ = questions[_currentQIndex];
                    _playQuestionAudio(nextQ);
                  }
                } else {
                  appState.finishQuiz(appState.selectedDifficulty, _score);
                }
              },
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _promptQuitQuiz(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (_) => QuitQuizDialog(
        onConfirmQuit: () {
          TtsService.stop();
          _resetQuestionState(appState: appState);
          appState.navigateTo(AppScreen.quizSelect);
        },
      ),
    );
  }

  // ================= 3. QUESTION BODIES =================
  Widget _buildQuestionBody(QuizQuestion q, AppState appState) {
    switch (q.type) {
      case QuestionType.single:
      case QuestionType.oddOneOut:
        return _buildSingleChoice(q, appState);
      case QuestionType.trueFalse:
        return _buildTrueFalse(q, appState);
      case QuestionType.multiSelect:
        return _buildMultiSelect(q, appState);
      case QuestionType.fillGapSingle:
        return _buildFillGapSingle(q, appState);
      case QuestionType.match:
        return _buildMatch(q, appState);
      case QuestionType.order:
        return _buildOrder(q, appState);
    }
  }

  // --- Single Choice & Odd One Out with Deselect and Confirm ---
  Widget _buildSingleChoice(QuizQuestion q, AppState appState) {
    return Column(
      children: [
        ...List.generate(q.options.length, (idx) {
          final option = q.options[idx];
          final isSelected = _selectedSingleIndex == idx;
          final isCorrectOption = idx == q.correct;
          final hasLearnMore = q.learnMoreMap?.containsKey(option) ?? false;

          Color bgColor = const Color(0xFFFEFAF6);
          Color borderColor = AppColors.blush;
          Color textColor = AppColors.dark;

          if (_isAnswered) {
            if (isCorrectOption) {
              bgColor = const Color(0xFFE8F8EA);
              borderColor = const Color(0xFF6BCB77);
              textColor = const Color(0xFF2D7A36);
            } else if (isSelected) {
              bgColor = const Color(0xFFFCE8E8);
              borderColor = const Color(0xFFE74C3C);
              textColor = const Color(0xFFA33333);
            }
          } else if (isSelected) {
            bgColor = AppColors.cream;
            borderColor = AppColors.coral;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: isSelected || (_isAnswered && isCorrectOption) ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isAnswered
                    ? (hasLearnMore
                        ? () => _showLearnMore(context, q, option)
                        : null)
                    : () {
                        SoundService.playTap();
                        setState(() {
                          // Allow tapping again to deselect
                          if (_selectedSingleIndex == idx) {
                            _selectedSingleIndex = null;
                          } else {
                            _selectedSingleIndex = idx;
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (hasLearnMore && _isAnswered) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.sky.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Learn more',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        if (!_isAnswered)
          PrimaryButton(
            text: 'Confirm',
            onPressed: _selectedSingleIndex == null
                ? null
                : () {
                    final isCorrect = _selectedSingleIndex == q.correct;
                    if (isCorrect) {
                      SoundService.playCorrect();
                    } else {
                      SoundService.playIncorrect();
                    }
                    setState(() {
                      _isAnswered = true;
                      _isLastAnswerCorrect = isCorrect;
                      if (isCorrect) _score++;
                    });
                    appState.recordQuestionResult(q.id, isCorrect);
                    _onAnswerRecorded(context, appState);
                  },
          ),
      ],
    );
  }

  // --- True / False with Deselect and Confirm ---
  Widget _buildTrueFalse(QuizQuestion q, AppState appState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTFButton(true, 'True', q, appState)),
            const SizedBox(width: 14),
            Expanded(child: _buildTFButton(false, 'False', q, appState)),
          ],
        ),
        const SizedBox(height: 16),
        if (!_isAnswered)
          PrimaryButton(
            text: 'Confirm',
            onPressed: _selectedTF == null
                ? null
                : () {
                    final isCorrect = _selectedTF == q.correct;
                    if (isCorrect) {
                      SoundService.playCorrect();
                    } else {
                      SoundService.playIncorrect();
                    }
                    setState(() {
                      _isAnswered = true;
                      _isLastAnswerCorrect = isCorrect;
                      if (isCorrect) _score++;
                    });
                    appState.recordQuestionResult(q.id, isCorrect);
                    _onAnswerRecorded(context, appState);
                  },
          ),
      ],
    );
  }

  Widget _buildTFButton(
      bool val, String label, QuizQuestion q, AppState appState) {
    final isSelected = _selectedTF == val;
    final isCorrectOption = val == q.correct;

    Color bgColor = const Color(0xFFFEFAF6);
    Color borderColor = AppColors.blush;
    Color textColor = AppColors.dark;

    if (_isAnswered) {
      if (isCorrectOption) {
        bgColor = const Color(0xFFE8F8EA);
        borderColor = const Color(0xFF6BCB77);
        textColor = const Color(0xFF2D7A36);
      } else if (isSelected) {
        bgColor = const Color(0xFFFCE8E8);
        borderColor = const Color(0xFFE74C3C);
        textColor = const Color(0xFFA33333);
      }
    } else if (isSelected) {
      bgColor = AppColors.cream;
      borderColor = AppColors.coral;
    }

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isSelected || (_isAnswered && isCorrectOption) ? 2 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAnswered
              ? null
              : () {
                  SoundService.playTap();
                  setState(() {
                    if (_selectedTF == val) {
                      _selectedTF = null;
                    } else {
                      _selectedTF = val;
                    }
                  });
                },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Multi Select with Toggle and Confirm ---
  Widget _buildMultiSelect(QuizQuestion q, AppState appState) {
    final List<int> correctList =
        (q.correct as List<dynamic>).map((e) => e as int).toList();

    return Column(
      children: [
        ...List.generate(q.options.length, (idx) {
          final option = q.options[idx];
          final isChecked = _selectedMultiIndices.contains(idx);
          final isCorrectOption = correctList.contains(idx);
          final hasLearnMore = q.learnMoreMap?.containsKey(option) ?? false;

          Color bgColor = isChecked ? AppColors.cream : const Color(0xFFFEFAF6);
          Color borderColor = isChecked ? AppColors.coral : AppColors.blush;
          Color textColor = AppColors.dark;

          if (_isAnswered) {
            if (isCorrectOption) {
              bgColor = const Color(0xFFE8F8EA);
              borderColor = const Color(0xFF6BCB77);
              textColor = const Color(0xFF2D7A36);
            } else if (isChecked) {
              bgColor = const Color(0xFFFCE8E8);
              borderColor = const Color(0xFFE74C3C);
              textColor = const Color(0xFFA33333);
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: isChecked || (_isAnswered && isCorrectOption) ? 2 : 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isAnswered
                    ? (hasLearnMore
                        ? () => _showLearnMore(context, q, option)
                        : null)
                    : () {
                        SoundService.playTap();
                        setState(() {
                          if (_selectedMultiIndices.contains(idx)) {
                            _selectedMultiIndices.remove(idx);
                          } else {
                            _selectedMultiIndices.add(idx);
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isChecked ? AppColors.coral : const Color(0xFFFEFAF6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                isChecked ? AppColors.coral : AppColors.muted,
                            width: 1.5,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.dmSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (hasLearnMore && _isAnswered)
                        Text(
                          'Learn more',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        if (!_isAnswered)
          PrimaryButton(
            text: 'Confirm',
            onPressed: _selectedMultiIndices.isEmpty
                ? null
                : () {
                    final setA = _selectedMultiIndices;
                    final setB = correctList.toSet();
                    final isCorrect =
                        setA.length == setB.length && setA.containsAll(setB);

                    if (isCorrect) {
                      SoundService.playCorrect();
                    } else {
                      SoundService.playIncorrect();
                    }

                    setState(() {
                      _isAnswered = true;
                      _isLastAnswerCorrect = isCorrect;
                      if (isCorrect) _score++;
                    });
                    appState.recordQuestionResult(q.id, isCorrect);
                    _onAnswerRecorded(context, appState);
                  },
          ),
      ],
    );
  }

  // --- Fill Gap Single with Deselect and Confirm ---
  Widget _buildFillGapSingle(QuizQuestion q, AppState appState) {
    final blankText = _selectedFillGapOption ?? '[_____]';
    final correctStr = (q.correct is int)
        ? q.options[q.correct as int]
        : q.correct.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.blush),
          ),
          child: Text(
            q.question.contains('___')
                ? q.question.replaceAll('___', blankText)
                : 'Select the missing word: $blankText',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: q.options.map((opt) {
            final isSelected = _selectedFillGapOption == opt;
            final isCorrectOption = opt == correctStr;

            Color bgColor = isSelected ? AppColors.cream : const Color(0xFFFEFAF6);
            Color borderColor = isSelected ? AppColors.coral : AppColors.blush;
            Color textColor = AppColors.dark;

            if (_isAnswered) {
              if (isCorrectOption) {
                bgColor = const Color(0xFFE8F8EA);
                borderColor = const Color(0xFF6BCB77);
                textColor = const Color(0xFF2D7A36);
              } else if (isSelected) {
                bgColor = const Color(0xFFFCE8E8);
                borderColor = const Color(0xFFE74C3C);
                textColor = const Color(0xFFA33333);
              }
            }

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isAnswered
                    ? null
                    : () {
                        SoundService.playTap();
                        setState(() {
                          if (_selectedFillGapOption == opt) {
                            _selectedFillGapOption = null;
                          } else {
                            _selectedFillGapOption = opt;
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Text(
                    opt,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (!_isAnswered)
          PrimaryButton(
            text: 'Confirm',
            onPressed: _selectedFillGapOption == null
                ? null
                : () {
                    final isCorrect = _selectedFillGapOption == correctStr;
                    if (isCorrect) {
                      SoundService.playCorrect();
                    } else {
                      SoundService.playIncorrect();
                    }
                    setState(() {
                      _isAnswered = true;
                      _isLastAnswerCorrect = isCorrect;
                      if (isCorrect) _score++;
                    });
                    appState.recordQuestionResult(q.id, isCorrect);
                    _onAnswerRecorded(context, appState);
                  },
          ),
      ],
    );
  }

  // --- Match Pairs with Deselect and HTML Colors ---
  Widget _buildMatch(QuizQuestion q, AppState appState) {
    final leftList = q.leftMatch ?? [];
    final rightList = q.rightMatch ?? [];
    final correctMap = q.correctPairs ?? {};

    // Get color index for each paired pair
    final Map<int, int> leftPairColorIdx = {};
    final Map<int, int> rightPairColorIdx = {};
    int colorCounter = 0;
    _selectedPairs.forEach((lIdx, rIdx) {
      final cIdx = colorCounter % matchBorderColors.length;
      leftPairColorIdx[lIdx] = cIdx;
      rightPairColorIdx[rIdx] = cIdx;
      colorCounter++;
    });

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: List.generate(leftList.length, (lIdx) {
                  final isPaired = _selectedPairs.containsKey(lIdx);
                  final isActive = _activeMatchLeftIndex == lIdx;

                  Color bgColor = const Color(0xFFFEFAF6);
                  Color borderColor = AppColors.blush;

                  if (_isAnswered) {
                    final expectedRight = correctMap[lIdx];
                    final userRight = _selectedPairs[lIdx];
                    final isCorrectPair =
                        userRight != null && userRight == expectedRight;
                    bgColor = isCorrectPair
                        ? const Color(0xFFE8F8EA)
                        : const Color(0xFFFCE8E8);
                    borderColor = isCorrectPair
                        ? const Color(0xFF6BCB77)
                        : const Color(0xFFE74C3C);
                  } else if (isPaired) {
                    final cIdx = leftPairColorIdx[lIdx]!;
                    bgColor = matchBgColors[cIdx];
                    borderColor = matchBorderColors[cIdx];
                  } else if (isActive) {
                    bgColor = AppColors.cream;
                    borderColor = AppColors.coral;
                  }

                  return GestureDetector(
                    onTap: _isAnswered
                        ? null
                        : () {
                            SoundService.playTap();
                            setState(() {
                              // If already paired, unpair it!
                              if (_selectedPairs.containsKey(lIdx)) {
                                _selectedPairs.remove(lIdx);
                                if (_activeMatchLeftIndex == lIdx) {
                                  _activeMatchLeftIndex = null;
                                }
                              } else if (_activeMatchLeftIndex == lIdx) {
                                _activeMatchLeftIndex = null;
                              } else {
                                _activeMatchLeftIndex = lIdx;
                              }
                            });
                          },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor,
                          width: (isActive || isPaired) ? 2 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          leftList[lIdx],
                          style: GoogleFonts.dmSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),

            // Right column
            Expanded(
              child: Column(
                children: List.generate(rightList.length, (rIdx) {
                  final isPaired = _selectedPairs.values.contains(rIdx);

                  Color bgColor = const Color(0xFFFEFAF6);
                  Color borderColor = AppColors.blush;

                  if (_isAnswered) {
                    int? matchedLeft;
                    _selectedPairs.forEach((l, r) {
                      if (r == rIdx) matchedLeft = l;
                    });
                    final isCorrectPair = matchedLeft != null &&
                        correctMap[matchedLeft!] == rIdx;
                    bgColor = isCorrectPair
                        ? const Color(0xFFE8F8EA)
                        : const Color(0xFFFCE8E8);
                    borderColor = isCorrectPair
                        ? const Color(0xFF6BCB77)
                        : const Color(0xFFE74C3C);
                  } else if (isPaired) {
                    final cIdx = rightPairColorIdx[rIdx]!;
                    bgColor = matchBgColors[cIdx];
                    borderColor = matchBorderColors[cIdx];
                  }

                  return GestureDetector(
                    onTap: _isAnswered
                        ? null
                        : () {
                            SoundService.playTap();
                            setState(() {
                              // If already paired, unpair it!
                              if (isPaired) {
                                _selectedPairs.removeWhere((_, r) => r == rIdx);
                              } else if (_activeMatchLeftIndex != null) {
                                _selectedPairs[_activeMatchLeftIndex!] = rIdx;
                                _activeMatchLeftIndex = null;
                              }
                            });
                          },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor,
                          width: isPaired ? 2 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          rightList[rIdx],
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a card on the left, then tap its match on the right. Tap again to unpair.',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.muted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        if (!_isAnswered)
          PrimaryButton(
            text: 'Confirm',
            onPressed: _selectedPairs.length < leftList.length
                ? null
                : () {
                    bool isCorrect = true;
                    _selectedPairs.forEach((lIdx, rIdx) {
                      if (correctMap[lIdx] != rIdx) {
                        isCorrect = false;
                      }
                    });

                    if (isCorrect) {
                      SoundService.playCorrect();
                    } else {
                      SoundService.playIncorrect();
                    }

                    setState(() {
                      _isAnswered = true;
                      _isLastAnswerCorrect = isCorrect;
                      if (isCorrect) _score++;
                    });
                    appState.recordQuestionResult(q.id, isCorrect);
                    _onAnswerRecorded(context, appState);
                  },
          ),
      ],
    );
  }

  // --- Order Sequence ---
  Widget _buildOrder(QuizQuestion q, AppState appState) {
    final items = q.orderItems ?? [];

    if (_currentOrderIndices.length != items.length) {
      _currentOrderIndices =
          List.generate(items.length, (index) => index);
    }

    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          proxyDecorator: (Widget child, int index, Animation<double> animation) {
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: child,
              ),
            );
          },
          itemCount: _currentOrderIndices.length,
          onReorder: _isAnswered
              ? (_, _) {}
              : (oldIdx, newIdx) {
                  SoundService.playTap();
                  setState(() {
                    if (newIdx > oldIdx) newIdx--;
                    final item = _currentOrderIndices.removeAt(oldIdx);
                    _currentOrderIndices.insert(newIdx, item);
                  });
                },
          itemBuilder: (context, idx) {
            final itemIdx = _currentOrderIndices[idx];
            return Container(
              key: ValueKey(itemIdx),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEFAF6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.blush),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.coral.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coral,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[itemIdx],
                      style: GoogleFonts.dmSans(
                          fontSize: 13.5, color: AppColors.dark),
                    ),
                  ),
                  const Icon(
                    Icons.unfold_more_rounded,
                    size: 24,
                    color: AppColors.muted,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        if (!_isAnswered)
          PrimaryButton(
            text: 'Confirm',
            onPressed: () {
              final correctOrder = q.correctOrder ?? [];
              bool isCorrect = true;
              for (int i = 0; i < correctOrder.length; i++) {
                if (_currentOrderIndices[i] != correctOrder[i]) {
                  isCorrect = false;
                  break;
                }
              }

              if (isCorrect) {
                SoundService.playCorrect();
              } else {
                SoundService.playIncorrect();
              }

              setState(() {
                _isAnswered = true;
                _isLastAnswerCorrect = isCorrect;
                if (isCorrect) _score++;
              });
              appState.recordQuestionResult(q.id, isCorrect);
              _onAnswerRecorded(context, appState);
            },
          ),
      ],
    );
  }

  void _onAnswerRecorded(BuildContext context, AppState appState) {
    _syncToAppState(appState);
    if (appState.hasPendingUnlocks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNextPendingUnlock(context, appState);
      });
    }
  }

  void _showLearnMore(BuildContext context, QuizQuestion q, String option) {
    SoundService.playTap();
    final info = q.learnMoreMap?[option];
    if (info == null) return;

    showDialog(
      context: context,
      builder: (_) => LearnMoreDialog(info: info),
    );
  }

  // ================= 3. RESULTS VIEW =================
  Widget _buildResultsView(BuildContext context, AppState appState) {
    final diff = appState.selectedDifficulty;
    final level = QuizData.levels[diff]!;
    final totalQ = level.questions.length;
    final isPerfect = _score == totalQ;

    // Trigger celebration sound on 100% perfect score
    if (isPerfect && !_hasTriggeredCongratsSound) {
      _hasTriggeredCongratsSound = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SoundService.playCongrats();
      });
    }

    // Check & trigger card unlock modals
    _checkCardUnlocks(context, appState);

    return AppScaffold(
      topBarTitle: 'Quiz Results',
      backgroundGradient: AppColors.warmBackground,
      onBack: () {
        SoundService.playTap();
        appState.navigateTo(AppScreen.quizSelect);
      },
      body: ConfettiOverlay(
        isPlaying: isPerfect,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isPerfect ? const Color(0xFFFFF3CD) : const Color(0xFFFEFAF6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                isPerfect
                    ? Icons.military_tech_rounded
                    : Icons.emoji_events_rounded,
                size: 54,
                color: isPerfect ? const Color(0xFFD97706) : AppColors.coral,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),

            Text(
              isPerfect ? 'Flawless Knowledge!' : 'Quiz Completed!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            Text(
              '${level.label} Level',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.coral,
              ),
            ),
            const SizedBox(height: 18),

            // Score card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEFAF6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.blush),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '$_score / $totalQ',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPerfect
                        ? '100% Score! You have mastered this tier.'
                        : 'Great job! Play again to improve your score and unlock rare cards.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // POST-QUIZ FEEDBACK SURVEY CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF4EB), Color(0xFFFDEADA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.coral.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rate_review_rounded,
                          color: AppColors.coral, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "We'd love your feedback!",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We're currently developing CityLoom and would love your thoughts to help shape the tour! (Takes only 2 min)",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Give Feedback (Google Form)',
                    onPressed: () async {
                      SoundService.playTap();
                      AnalyticsService.instance
                          .logSurveyClick('post_quiz_results_card');
                      final uri =
                          Uri.parse('https://forms.gle/2iMZ6P9CGV3iMUja7');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: 24),

            // Primary Action: Try Another Tier
            PrimaryButton(
              text: 'Try Another Tier',
              onPressed: () {
                SoundService.playTap();
                appState.navigateTo(AppScreen.quizSelect);
              },
            ),
            const SizedBox(height: 12),

            // Secondary Row: View Collection & Home (No icons)
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'View Library',
                    isSecondary: true,
                    onPressed: () {
                      SoundService.playTap();
                      appState.navigateTo(AppScreen.library);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Home',
                    isSecondary: true,
                    onPressed: () {
                      SoundService.playTap();
                      appState.navigateTo(AppScreen.home);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _checkCardUnlocks(BuildContext context, AppState appState) {
    if (_unlockDialogsProcessed) return;
    _unlockDialogsProcessed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNextPendingUnlock(context, appState);
    });
  }

  void _showNextPendingUnlock(BuildContext context, AppState appState) {
    final nextCard = appState.popNextCardToReveal();
    if (nextCard != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => CardRevealDialog(
          cardId: nextCard,
          onDismiss: () {
            Navigator.of(context).pop();
            FlyToLibraryAnimation.fly(
              context,
              cardId: nextCard,
              onComplete: () => _showNextPendingUnlock(context, appState),
            );
          },
          onViewLibrary: () {
            Navigator.of(context).pop();
            appState.navigateTo(AppScreen.library);
          },
        ),
      );
    } else if (appState.unlockedCardsCount == appState.totalCardsCount &&
        !appState.congratsShown) {
      appState.markCongratsShown();
      showDialog(
        context: context,
        builder: (_) => CongratulationsDialog(
          onViewLibrary: () => appState.navigateTo(AppScreen.library),
          onGiveFeedback: () => appState.navigateTo(AppScreen.survey),
        ),
      );
    }
  }
}
