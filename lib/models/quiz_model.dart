enum QuestionType {
  single,
  trueFalse,
  multiSelect,
  fillGapSingle,
  oddOneOut,
  match,
  order,
}

enum QuizDifficulty {
  explorer,
  apprentice,
  historian,
  scholar,
}

extension QuizDifficultyExtension on QuizDifficulty {
  String get id {
    switch (this) {
      case QuizDifficulty.explorer:
        return 'explorer';
      case QuizDifficulty.apprentice:
        return 'apprentice';
      case QuizDifficulty.historian:
        return 'historian';
      case QuizDifficulty.scholar:
        return 'scholar';
    }
  }

  String get label {
    switch (this) {
      case QuizDifficulty.explorer:
        return 'Explorer';
      case QuizDifficulty.apprentice:
        return 'Apprentice';
      case QuizDifficulty.historian:
        return 'Historian';
      case QuizDifficulty.scholar:
        return 'Scholar';
    }
  }
}

class LearnMoreInfo {
  final String title;
  final String text;

  const LearnMoreInfo({
    required this.title,
    required this.text,
  });
}

class QuizQuestion {
  final String id;
  final QuestionType type;
  final String question;
  final String? instruction;
  final List<String> options;
  final dynamic correct; // int for single/TF/oddOneOut, List<int> for multi, bool for TF
  final String explanation;
  final List<String>? leftMatch;
  final List<String>? rightMatch;
  final Map<int, int>? correctPairs; // left index -> right index
  final List<String>? orderItems;
  final List<int>? correctOrder;
  final Map<String, LearnMoreInfo>? learnMoreMap; // option text -> LearnMoreInfo

  const QuizQuestion({
    required this.id,
    required this.type,
    required this.question,
    this.instruction,
    this.options = const [],
    this.correct,
    required this.explanation,
    this.leftMatch,
    this.rightMatch,
    this.correctPairs,
    this.orderItems,
    this.correctOrder,
    this.learnMoreMap,
  });
}

class DifficultyLevel {
  final QuizDifficulty difficulty;
  final String label;
  final String description;
  final List<QuizQuestion> questions;

  const DifficultyLevel({
    required this.difficulty,
    required this.label,
    required this.description,
    required this.questions,
  });
}
