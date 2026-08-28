import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/quiz_data.dart';
import '../models/quiz_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_reveal_dialog.dart';
import '../widgets/congratulations_dialog.dart';
import '../widgets/learn_more_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/quit_quiz_dialog.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Runner State
  int _currentQIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  bool _isLastAnswerCorrect = false;

  // Question-specific state
  int? _selectedSingleIndex;
  bool? _selectedTF;
  final Set<int> _selectedMultiIndices = {};
  int? _selectedGapIndex;
  
  // Matching state
  int? _activeMatchLeftIndex;
  final Map<int, int> _userMatchPairs = {}; // leftIdx -> rightIdx
  
  // Ordering state
  late List<int> _currentOrderIndices;

  @override
  void initState() {
    super.initState();
    _resetQuestionState();
  }

  void _resetQuestionState() {
    _isAnswered = false;
    _isLastAnswerCorrect = false;
    _selectedSingleIndex = null;
    _selectedTF = null;
    _selectedMultiIndices.clear();
    _selectedGapIndex = null;
    _activeMatchLeftIndex = null;
    _userMatchPairs.clear();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.currentScreen == AppScreen.quizSelect) {
      return _buildDifficultySelector(context, appState);
    } else if (appState.currentScreen == AppScreen.quizResult) {
      return _buildResultsView(context, appState);
    }

    return _buildQuestionRunner(context, appState);
  }

  // ================= 1. DIFFICULTY SELECTOR =================
  Widget _buildDifficultySelector(BuildContext context, AppState appState) {
    return AppScaffold(
      onBack: () => appState.navigateTo(AppScreen.complete),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            'KIRKYARD QUIZ',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Choose Your Level',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Answer questions correctly to test your knowledge and unlock rare character cards for your library!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          ...QuizDifficulty.values.map((diff) {
            final level = QuizData.levels[diff]!;
            final bestScore = appState.bestScores[diff.id];
            final totalQuestions = level.questions.length;
            final isPerfect = bestScore != null && bestScore == totalQuestions;

            Color accentColor;
            switch (diff) {
              case QuizDifficulty.explorer:
                accentColor = const Color(0xFF2E7D32);
                break;
              case QuizDifficulty.apprentice:
                accentColor = const Color(0xFF1976D2);
                break;
              case QuizDifficulty.historian:
                accentColor = AppColors.coral;
                break;
              case QuizDifficulty.scholar:
                accentColor = AppColors.rarityLegendary;
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isPerfect ? accentColor : AppColors.blush,
                  width: isPerfect ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
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
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isPerfect ? Icons.stars_rounded : Icons.quiz_rounded,
                            color: accentColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.label,
                                style: const TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                level.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (bestScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$bestScore / $totalQuestions',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.muted,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================= 2. QUESTION RUNNER =================
  Widget _buildQuestionRunner(BuildContext context, AppState appState) {
    final level = QuizData.levels[appState.selectedDifficulty]!;
    final question = level.questions[_currentQIndex];
    final totalQ = level.questions.length;

    return AppScaffold(
      onBack: () {
        showDialog(
          context: context,
          builder: (_) => QuitQuizDialog(
            onConfirmQuit: () {
              appState.navigateTo(AppScreen.quizSelect);
            },
          ),
        );
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.coral,
                  ),
                ),
              ),
              Text(
                'Question ${_currentQIndex + 1} of $totalQ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQIndex + 1) / totalQ,
              backgroundColor: AppColors.blush,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.coral),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),

          // Question Prompt
          Text(
            question.question,
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
              height: 1.35,
            ),
          ),
          if (question.instruction != null) ...[
            const SizedBox(height: 6),
            Text(
              question.instruction!,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.muted,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Question Type Component
          _buildQuestionComponent(question, appState),

          const SizedBox(height: 16),

          // Feedback & Explanation Card (when answered)
          if (_isAnswered) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLastAnswerCorrect
                    ? AppColors.correctGreenBg
                    : AppColors.incorrectRedBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isLastAnswerCorrect
                      ? AppColors.correctGreen.withValues(alpha: 0.4)
                      : AppColors.incorrectRed.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isLastAnswerCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _isLastAnswerCorrect
                            ? AppColors.correctGreen
                            : AppColors.incorrectRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLastAnswerCorrect ? 'Correct!' : 'Not quite!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isLastAnswerCorrect
                              ? AppColors.correctGreen
                              : AppColors.incorrectRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 20),

            // Next / Finish Button
            PrimaryButton(
              text: _currentQIndex + 1 < totalQ ? 'Next Question' : 'View Results',
              onPressed: () {
                if (_currentQIndex + 1 < totalQ) {
                  setState(() {
                    _currentQIndex++;
                    _resetQuestionState();
                  });
                } else {
                  appState.finishQuiz(appState.selectedDifficulty, _score);
                }
              },
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  // ================= 3. QUESTION TYPE HANDLERS =================
  Widget _buildQuestionComponent(QuizQuestion q, AppState appState) {
    switch (q.type) {
      case QuestionType.single:
      case QuestionType.oddOneOut:
        return _buildSingleChoice(q, appState);
      case QuestionType.trueFalse:
        return _buildTrueFalse(q, appState);
      case QuestionType.multiSelect:
        return _buildMultiSelect(q, appState);
      case QuestionType.fillGapSingle:
        return _buildFillGap(q, appState);
      case QuestionType.match:
        return _buildMatchPairs(q, appState);
      case QuestionType.order:
        return _buildOrderItems(q, appState);
    }
  }

  // --- Single Choice ---
  Widget _buildSingleChoice(QuizQuestion q, AppState appState) {
    return Column(
      children: List.generate(q.options.length, (idx) {
        final option = q.options[idx];
        final isSelected = _selectedSingleIndex == idx;
        final isCorrectOption = idx == q.correct;
        final hasLearnMore = q.learnMoreMap?.containsKey(option) ?? false;

        Color bgColor = Colors.white;
        Color borderColor = AppColors.blush;
        Color textColor = AppColors.dark;

        if (_isAnswered) {
          if (isCorrectOption) {
            bgColor = AppColors.correctGreenBg;
            borderColor = AppColors.correctGreen;
            textColor = AppColors.correctGreen;
          } else if (isSelected) {
            bgColor = AppColors.incorrectRedBg;
            borderColor = AppColors.incorrectRed;
            textColor = AppColors.incorrectRed;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isAnswered
                  ? null
                  : () {
                      final correct = idx == q.correct;
                      setState(() {
                        _selectedSingleIndex = idx;
                        _isAnswered = true;
                        _isLastAnswerCorrect = correct;
                        if (correct) _score++;
                      });
                      appState.recordQuestionResult(q.id, correct);
                    },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: isSelected || (_isAnswered && isCorrectOption)
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (hasLearnMore && _isAnswered)
                      IconButton(
                        icon: const Icon(Icons.info_outline_rounded, color: AppColors.coral),
                        onPressed: () {
                          final info = q.learnMoreMap![option]!;
                          showDialog(
                            context: context,
                            builder: (_) => LearnMoreDialog(info: info),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- True / False ---
  Widget _buildTrueFalse(QuizQuestion q, AppState appState) {
    return Row(
      children: [
        Expanded(child: _buildTFButton(true, 'True', q, appState)),
        const SizedBox(width: 14),
        Expanded(child: _buildTFButton(false, 'False', q, appState)),
      ],
    );
  }

  Widget _buildTFButton(bool val, String label, QuizQuestion q, AppState appState) {
    final isSelected = _selectedTF == val;
    final isCorrectOption = val == q.correct;

    Color bgColor = Colors.white;
    Color borderColor = AppColors.blush;
    Color textColor = AppColors.dark;

    if (_isAnswered) {
      if (isCorrectOption) {
        bgColor = AppColors.correctGreenBg;
        borderColor = AppColors.correctGreen;
        textColor = AppColors.correctGreen;
      } else if (isSelected) {
        bgColor = AppColors.incorrectRedBg;
        borderColor = AppColors.incorrectRed;
        textColor = AppColors.incorrectRed;
      }
    }

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAnswered
              ? null
              : () {
                  final correct = val == q.correct;
                  setState(() {
                    _selectedTF = val;
                    _isAnswered = true;
                    _isLastAnswerCorrect = correct;
                    if (correct) _score++;
                  });
                  appState.recordQuestionResult(q.id, correct);
                },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Multi Select with Toggle Fix (Q14 Fix Included!) ---
  Widget _buildMultiSelect(QuizQuestion q, AppState appState) {
    final List<int> correctList = (q.correct as List<dynamic>).map((e) => e as int).toList();

    return Column(
      children: [
        ...List.generate(q.options.length, (idx) {
          final option = q.options[idx];
          final isChecked = _selectedMultiIndices.contains(idx);
          final isCorrectOption = correctList.contains(idx);
          final hasLearnMore = q.learnMoreMap?.containsKey(option) ?? false;

          Color bgColor = isChecked ? AppColors.cream : Colors.white;
          Color borderColor = isChecked ? AppColors.coral : AppColors.blush;
          Color textColor = AppColors.dark;

          if (_isAnswered) {
            if (isCorrectOption) {
              bgColor = AppColors.correctGreenBg;
              borderColor = AppColors.correctGreen;
              textColor = AppColors.correctGreen;
            } else if (isChecked) {
              bgColor = AppColors.incorrectRedBg;
              borderColor = AppColors.incorrectRed;
              textColor = AppColors.incorrectRed;
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isAnswered
                    ? null
                    : () {
                        setState(() {
                          if (_selectedMultiIndices.contains(idx)) {
                            _selectedMultiIndices.remove(idx);
                          } else {
                            _selectedMultiIndices.add(idx);
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isChecked ? AppColors.coral : Colors.transparent,
                          border: Border.all(
                            color: isChecked ? AppColors.coral : AppColors.muted,
                            width: 2,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (hasLearnMore && _isAnswered)
                        IconButton(
                          icon: const Icon(Icons.info_outline_rounded, color: AppColors.coral),
                          onPressed: () {
                            final info = q.learnMoreMap![option]!;
                            showDialog(
                              context: context,
                              builder: (_) => LearnMoreDialog(info: info),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),

        // Confirm Button for Multi-Select
        if (!_isAnswered)
          PrimaryButton(
            text: 'Confirm Answers',
            onPressed: _selectedMultiIndices.isEmpty
                ? null
                : () {
                    final selectedSorted = _selectedMultiIndices.toList()..sort();
                    final correctSorted = List<int>.from(correctList)..sort();
                    final isCorrect = selectedSorted.length == correctSorted.length &&
                        selectedSorted.every((e) => correctSorted.contains(e));

                    setState(() {
                      _isAnswered = true;
                      _isLastAnswerCorrect = isCorrect;
                      if (isCorrect) _score++;
                    });
                    appState.recordQuestionResult(q.id, isCorrect);
                  },
          ),
      ],
    );
  }

  // --- Fill in the Gap ---
  Widget _buildFillGap(QuizQuestion q, AppState appState) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: List.generate(q.options.length, (idx) {
            final option = q.options[idx];
            final isSelected = _selectedGapIndex == idx;
            final isCorrectOption = idx == q.correct;

            Color bgColor = Colors.white;
            Color borderColor = AppColors.blush;
            Color textColor = AppColors.dark;

            if (_isAnswered) {
              if (isCorrectOption) {
                bgColor = AppColors.correctGreenBg;
                borderColor = AppColors.correctGreen;
                textColor = AppColors.correctGreen;
              } else if (isSelected) {
                bgColor = AppColors.incorrectRedBg;
                borderColor = AppColors.incorrectRed;
                textColor = AppColors.incorrectRed;
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isAnswered
                      ? null
                      : () {
                          final correct = idx == q.correct;
                          setState(() {
                            _selectedGapIndex = idx;
                            _isAnswered = true;
                            _isLastAnswerCorrect = correct;
                            if (correct) _score++;
                          });
                          appState.recordQuestionResult(q.id, correct);
                        },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- Match Pairs ---
  Widget _buildMatchPairs(QuizQuestion q, AppState appState) {
    final leftList = q.leftMatch ?? [];
    final rightList = q.rightMatch ?? [];
    final correctPairs = q.correctPairs ?? {};

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              child: Column(
                children: List.generate(leftList.length, (lIdx) {
                  final isPaired = _userMatchPairs.containsKey(lIdx);
                  final isActive = _activeMatchLeftIndex == lIdx;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.cream
                          : (isPaired ? const Color(0xFFEBF3F8) : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? AppColors.coral
                            : (isPaired ? AppColors.sky : AppColors.blush),
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isAnswered
                            ? null
                            : () {
                                setState(() {
                                  _activeMatchLeftIndex = lIdx;
                                });
                              },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            leftList[lIdx],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),

            // Right Column
            Expanded(
              child: Column(
                children: List.generate(rightList.length, (rIdx) {
                  final isPaired = _userMatchPairs.values.contains(rIdx);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isPaired ? const Color(0xFFEBF3F8) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isPaired ? AppColors.sky : AppColors.blush,
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isAnswered || _activeMatchLeftIndex == null
                            ? null
                            : () {
                                setState(() {
                                  _userMatchPairs[_activeMatchLeftIndex!] = rIdx;
                                  _activeMatchLeftIndex = null;
                                });
                              },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            rightList[rIdx],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (!_isAnswered)
          PrimaryButton(
            text: 'Submit Matches',
            onPressed: _userMatchPairs.length == leftList.length
                ? () {
                    bool allCorrect = true;
                    _userMatchPairs.forEach((l, r) {
                      if (correctPairs[l] != r) allCorrect = false;
                    });

                    setState(() {
                      _isAnswered = true;
                      _isLastAnswerCorrect = allCorrect;
                      if (allCorrect) _score++;
                    });
                    appState.recordQuestionResult(q.id, allCorrect);
                  }
                : null,
          ),
      ],
    );
  }

  // --- Order Items ---
  Widget _buildOrderItems(QuizQuestion q, AppState appState) {
    final items = q.orderItems ?? [];
    if (!mounted || _userMatchPairs.isEmpty && !_isAnswered) {
      _currentOrderIndices = List.generate(items.length, (i) => i);
    }

    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _currentOrderIndices.length,
          // ignore: deprecated_member_use
          onReorder: _isAnswered
              ? (_, _) {}
              : (oldIdx, newIdx) {
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.blush),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.coral.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.coral,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[itemIdx],
                      style: const TextStyle(fontSize: 13.5, color: AppColors.dark),
                    ),
                  ),
                  const Icon(Icons.drag_handle_rounded, color: AppColors.muted),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        if (!_isAnswered)
          PrimaryButton(
            text: 'Submit Order',
            onPressed: () {
              final correctOrder = q.correctOrder ?? [];
              bool isCorrect = true;
              for (int i = 0; i < correctOrder.length; i++) {
                if (_currentOrderIndices[i] != correctOrder[i]) {
                  isCorrect = false;
                  break;
                }
              }

              setState(() {
                _isAnswered = true;
                _isLastAnswerCorrect = isCorrect;
                if (isCorrect) _score++;
              });
              appState.recordQuestionResult(q.id, isCorrect);
            },
          ),
      ],
    );
  }

  // ================= 4. RESULTS VIEW =================
  Widget _buildResultsView(BuildContext context, AppState appState) {
    final level = QuizData.levels[appState.selectedDifficulty]!;
    final totalQ = level.questions.length;
    final isPerfect = _score == totalQ;

    // Check if celebration dialog should appear
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nextCard = appState.getNextCardToReveal();
      if (nextCard != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CardRevealDialog(
            cardId: nextCard,
            onDismiss: () => Navigator.of(context).pop(),
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
    });

    return AppScaffold(
      backgroundGradient: AppColors.warmBackground,
      onBack: () => appState.navigateTo(AppScreen.quizSelect),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isPerfect ? const Color(0xFFFFF3CD) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              isPerfect ? Icons.military_tech_rounded : Icons.emoji_events_rounded,
              size: 56,
              color: isPerfect ? AppColors.rarityRare : AppColors.coral,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 18),

          Text(
            isPerfect ? 'Flawless Knowledge!' : 'Quiz Completed!',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            '${level.label} Level',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 20),

          // Score card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.blush),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.08),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '$_score / $totalQ',
                  style: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPerfect
                      ? '100% Score! You have mastered this tier.'
                      : 'Great job! Play again to improve your score and unlock legendary cards.',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          PrimaryButton(
            text: 'Try Another Level',
            onPressed: () => appState.navigateTo(AppScreen.quizSelect),
          ),
          const SizedBox(height: 12),

          PrimaryButton(
            text: 'View Collection (${appState.unlockedCardsCount}/${appState.totalCardsCount})',
            isSecondary: true,
            onPressed: () => appState.navigateTo(AppScreen.library),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
