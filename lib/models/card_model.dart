enum CardRarity {
  common,
  uncommon,
  rare,
  legendary,
}

enum CardUnlockType {
  story,
  quizExplorer,
  quizApprentice,
  quizHistorian,
  quizScholar,
  quizHistorianPerfect,
  quizScholarPerfect,
  quizAllPerfect,
  questionCorrect,
  allCompleted,
}

extension CardRarityExtension on CardRarity {
  String get displayName {
    switch (this) {
      case CardRarity.common:
        return 'Common';
      case CardRarity.uncommon:
        return 'Uncommon';
      case CardRarity.rare:
        return 'Rare';
      case CardRarity.legendary:
        return 'Legendary';
    }
  }
}

class CharacterCard {
  final String id;
  final String name;
  final CardRarity rarity;
  final String imageAsset;
  final String? teaserMessage;
  final String? historicalBio;
  final CardUnlockType unlockType;
  final String? specificQuestionId;

  const CharacterCard({
    required this.id,
    required this.name,
    required this.rarity,
    required this.imageAsset,
    this.teaserMessage,
    this.historicalBio,
    this.unlockType = CardUnlockType.story,
    this.specificQuestionId,
  });

  String get hint => teaserMessage ?? 'Unlocked through your Kirkyard journey';
}
