import '../models/card_model.dart';

class CardData {
  static const Map<String, CharacterCard> cards = {
    'mary': CharacterCard(
      id: 'mary',
      name: 'Mary Queen of Scots',
      rarity: CardRarity.common,
      imageAsset: 'assets/images/cards/card_mary.png',
      teaserMessage:
          'The Queen who granted Greyfriars Kirkyard to Edinburgh in 1562...',
      historicalBio:
          'Mary Stuart granted the gardens of the Franciscan convent to the town council in 1562 for use as a burial ground because St Giles kirkyard had become overcrowded.',
      unlockType: CardUnlockType.story,
    ),
    'bobby': CharacterCard(
      id: 'bobby',
      name: 'Greyfriars Bobby',
      rarity: CardRarity.common,
      imageAsset: 'assets/images/cards/card_bobby.png',
      teaserMessage: 'Not every story at Greyfriars is a dark one...',
      historicalBio:
          'The legendary Skye Terrier who spent 14 years guarding the grave of his owner, John Gray, until his own death in 1872.',
      unlockType: CardUnlockType.quizExplorer,
    ),
    'charles': CharacterCard(
      id: 'charles',
      name: 'King Charles I',
      rarity: CardRarity.common,
      imageAsset: 'assets/images/cards/card_charles.png',
      teaserMessage:
          'A King whose religious policies ignited rebellion across Scotland...',
      historicalBio:
          'King of England, Scotland, and Ireland whose attempts to impose the Anglican Book of Common Prayer on Presbyterian Scotland sparked the National Covenant of 1638.',
      unlockType: CardUnlockType.story,
    ),
    'burke': CharacterCard(
      id: 'burke',
      name: 'William Burke',
      rarity: CardRarity.common,
      imageAsset: 'assets/images/cards/card_burke.png',
      teaserMessage: 'One half of Edinburgh\'s most infamous murderous duo...',
      historicalBio:
          'Irish immigrant who, along with William Hare, murdered at least 16 people in 1828 to sell their corpses to Dr Robert Knox for anatomical dissection. Hanged in 1829.',
      unlockType: CardUnlockType.quizApprentice,
      specificQuestionId: 'apprentice_q6',
    ),
    'hare': CharacterCard(
      id: 'hare',
      name: 'William Hare',
      rarity: CardRarity.common,
      imageAsset: 'assets/images/cards/card_hare.png',
      teaserMessage:
          'The partner who turned King\'s evidence to save his own neck...',
      historicalBio:
          'Partner in crime to William Burke. Offered immunity from prosecution in exchange for testifying against Burke. Released from prison and fled Scotland.',
      unlockType: CardUnlockType.quizHistorian,
      specificQuestionId: 'historian_q2',
    ),
    'margaret': CharacterCard(
      id: 'margaret',
      name: 'Margaret Docherty',
      rarity: CardRarity.uncommon,
      imageAsset: 'assets/images/cards/card_margaret.png',
      teaserMessage: "You've uncovered Burke & Hare's downfall...",
      historicalBio:
          'The final victim of Burke and Hare, also known as Madgy McGonegal. Her murder on Halloween 1828 led to their discovery and arrest.',
      unlockType: CardUnlockType.questionCorrect,
      specificQuestionId: 'scholar_q12',
    ),
    'mckenzie': CharacterCard(
      id: 'mckenzie',
      name: 'George "Bluidy" McKenzie',
      rarity: CardRarity.uncommon,
      imageAsset: 'assets/images/cards/card_mckenzie.png',
      teaserMessage:
          'The ruthless Lord Advocate who earned his terrifying nickname...',
      historicalBio:
          'Sir George Mackenzie of Rosehaugh, Lord Advocate under Charles II, known as "Bluidy Mackenzie" for his brutal prosecution of the Covenanters.',
      unlockType: CardUnlockType.questionCorrect,
      specificQuestionId: 'scholar_q7',
    ),
    'henrietta': CharacterCard(
      id: 'henrietta',
      name: 'Queen Henrietta Maria',
      rarity: CardRarity.rare,
      imageAsset: 'assets/images/cards/card_henrietta.png',
      teaserMessage:
          'The French Catholic Queen whose marriage stoked religious tension in Scotland...',
      historicalBio:
          'Queen consort of King Charles I. Her open practice of Roman Catholicism fueled fears of a Catholic revival, intensifying resistance to royal religious policy.',
      unlockType: CardUnlockType.questionCorrect,
      specificQuestionId: 'scholar_q4',
    ),
    'poltergeist': CharacterCard(
      id: 'poltergeist',
      name: 'The Mackenzie Poltergeist',
      rarity: CardRarity.legendary,
      imageAsset: 'assets/images/cards/card_poltergeist.png',
      teaserMessage:
          'The malevolent entity said to haunt the Black Mausoleum...',
      historicalBio:
          'One of the most documented supernatural phenomena in the world, with hundreds of reported attacks on visitors to the Covenanters\' Prison and Black Mausoleum since 1999.',
      unlockType: CardUnlockType.quizAllPerfect,
    ),
    'knox': CharacterCard(
      id: 'knox',
      name: 'Dr. Robert Knox',
      rarity: CardRarity.legendary,
      imageAsset: 'assets/images/cards/card_knox.png',
      teaserMessage:
          'The brilliant anatomist whose demand for bodies drove the murders...',
      historicalBio:
          'Prominent Scottish anatomist and lecturer at Surgeon\'s Square who purchased bodies from Burke and Hare without questioning their origin.',
      unlockType: CardUnlockType.allCompleted,
    ),
  };
}
