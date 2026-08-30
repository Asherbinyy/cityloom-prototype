import '../models/tour_model.dart';

/// Centralized, modular script repository for CityLoom Greyfriars Kirkyard tour.
/// Contains all full narration scripts, voice actor dialogues, and subtitle timestamps.
class ScriptsData {
  // ==================== 1. INTRODUCTION SCRIPT ====================
  static const String introNarration = '''Welcome to Greyfriars Kirkyard, one of Edinburgh's oldest graveyards and one of the city's most storied places, where the mysteries of its past refuse to stay buried.

The history of the land stretches back almost six centuries, and within these walls the line between history and legend begins to blur. As you explore, we’ll share with you stories of body snatchers, haunted graves and ghosts that many still claim walk these paths after dark…

In the early 1440s, King James I of Scotland granted a large plot of land, on what was then the rural outskirts of medieval Edinburgh, to the Franciscan Order of Friars Minor. The friars were instantly recognisable by their simple, undyed grey robes, and the people of Edinburgh began calling them the "Grey Friars." The nickname stuck, becoming the name of the land itself, a name that has survived to today.

The land didn’t officially become a burial ground until 1562. By then, the churchyard at St. Giles had become dangerously overcrowded, and Mary Queen of Scots granted the land to Edinburgh's Town Council to serve as a new cemetery to suit the growing city’s needs.

It is estimated that, over the centuries, more than 100,000 people were buried here, beneath your very feet. Men, women and children, from all walks of life. Every gravestone you see marks a story, but countless others have been lost beneath the earth, their names erased by time.

"This chapter will explore some of the most ominous stories Greyfriars Kirkyard has to offer. Whenever you’re ready, select the first stop and we can explore together."''';

  static const List<TourSubtitle> introSubtitles = [
    TourSubtitle(
      startSeconds: 0.0,
      endSeconds: 15.0,
      text: "Welcome to Greyfriars Kirkyard, where the mysteries of its past refuse to stay buried.",
    ),
    TourSubtitle(
      startSeconds: 15.0,
      endSeconds: 32.0,
      text: "In the 1440s, King James I granted this land to the Franciscan Order, the 'Grey Friars'.",
    ),
    TourSubtitle(
      startSeconds: 32.0,
      endSeconds: 52.0,
      text: "In 1562, Mary Queen of Scots granted this ground to serve as a cemetery for the growing city.",
    ),
    TourSubtitle(
      startSeconds: 52.0,
      endSeconds: 78.0,
      text: "Over 100,000 souls were laid to rest beneath your feet across six centuries of history.",
    ),
    TourSubtitle(
      startSeconds: 78.0,
      endSeconds: 95.0,
      text: "Whenever you're ready, select the first stop on the map to begin our journey together.",
    ),
  ];

  // ==================== 2. STOP 1: THE MORTSAFES SCRIPT ====================
  static const String mortsafesNarration = '''Almost exclusively found within the UK, specifically Scotland, the iron barred cages over the graves before you, called "Mortsafes", aren’t intended to keep the dead within their graves, but to keep the living out…

By the eighteenth century many private anatomy colleges had already opened in Scotland. The University of Edinburgh Medical School opened its doors in 1726, which quickly earned an international reputation for excellence in education. Edinburgh had rapidly become one of Europe's greatest centres of medical learning, and prospective students travelled from across Britain and beyond to learn anatomy from the finest physicians of the age.

But this led to a problem… To understand the human body, students needed human bodies to dissect. However, by law the only corpses that could be used were those of executed criminals. As the medical schools grew, demand for bodies far outstripped the legal supply. In the 18th and early 19th century, universities started offering payment for fresh corpses—up to £10, when working-class families made less than £1 a month.

A new and sinister trade emerged: "Resurrection men", or graverobbers, would sneak into graveyards under cover of darkness to dig into fresh graves and steal the recently buried. Curiously, valuables buried with the dead were often left behind: stealing property was a capital crime, but stealing a corpse was a legal grey area.

Christians believed the body needed to remain intact for Judgement Day. Disturbance of a grave was seen as a desecration of faith. Those who could afford it paid to have iron mortsafes locked over graves for six to eight weeks until decomposition made the body useless for dissection.

Major M. E. Lindsay erected one of the double mortsafes here in Greyfriars to protect his two daughters, who died in 1837 and 1838.

When there were no bodies to steal, two men plunged the city into darkness: William Burke and William Hare murdered sixteen vulnerable people in 1828 to sell their bodies to Dr Robert Knox. Their final victim, Margaret Docherty, led to their arrest. Burke was hanged in 1829 and publicly dissected before 40,000 spectators. The murders led to the Anatomy Act of 1832, legally ending the resurrection trade.''';

  static const List<TourSubtitle> mortsafesSubtitles = [
    TourSubtitle(
      startSeconds: 0.0,
      endSeconds: 16.0,
      text: "The iron cages before you, called Mortsafes, were built not to keep the dead in, but to keep the living out.",
    ),
    TourSubtitle(
      startSeconds: 16.0,
      endSeconds: 38.0,
      text: "With the Medical School opening in 1726, demand for cadavers far outstripped legal supply.",
    ),
    TourSubtitle(
      startSeconds: 38.0,
      endSeconds: 65.0,
      text: "Resurrection men crept into graveyards to dig up newly buried bodies, selling them for up to £10 each.",
    ),
    TourSubtitle(
      startSeconds: 65.0,
      endSeconds: 98.0,
      text: "Mortsafes were locked over graves for six weeks until bodies were no longer of use to anatomy schools.",
    ),
    TourSubtitle(
      startSeconds: 98.0,
      endSeconds: 135.0,
      text: "Burke and Hare turned to murder in 1828, leading directly to the Anatomy Act of 1832.",
    ),
  ];

  // ==================== 3. STOP 2: COVENANTERS' PRISON SCRIPT ====================
  static const String covenantersNarration = '''The quiet corner before you has witnessed some of the darkest days in Greyfriars' history.

In the seventeenth century, King Charles I introduced reforms that sparked a religious civil war that would last decades. He tried to force the heavily Presbyterian Church of Scotland to adopt high church practices and introduced a new Book of Common Prayer in 1637, which caused widespread outrage. Scots saw this as an attack on their faith and suspiciously pro-Catholic due to his marriage to Henrietta Maria, a Roman Catholic French princess.

In 1638, thousands of Presbyterians signed the National Covenant right here in Greyfriars, pledging to defend the independence of the Scottish Kirk.

Following decades of conflict, the Covenanters suffered a crushing defeat at the Battle of Bothwell Bridge in 1679. Around 1,200 captured Covenanters were marched to Edinburgh and imprisoned here, in an open enclosure beside Greyfriars Kirkyard.

The prisoners were kept in an open field with no shelter through months of freezing Scottish weather. Food was scarce, disease was rampant, and conditions were so brutal it is often described as the world's first open concentration camp.

Many died of exposure and disease, others were executed, and over 250 were shipped to the colonies. The suffering endured within these walls gave rise to countless ghost sightings, temperature drops, and unexplained phenomena.''';

  static const List<TourSubtitle> covenantersSubtitles = [
    TourSubtitle(
      startSeconds: 0.0,
      endSeconds: 18.0,
      text: "Behind these iron gates lies what is often described as the world's first open-air concentration camp.",
    ),
    TourSubtitle(
      startSeconds: 18.0,
      endSeconds: 42.0,
      text: "In 1638, thousands signed the National Covenant at Greyfriars to defend the Scottish Kirk against Charles I.",
    ),
    TourSubtitle(
      startSeconds: 42.0,
      endSeconds: 70.0,
      text: "Following the Battle of Bothwell Bridge in 1679, 1,200 Covenanters were imprisoned in this freezing open field.",
    ),
    TourSubtitle(
      startSeconds: 70.0,
      endSeconds: 105.0,
      text: "Enduring starvation and cold, many perished, leaving a tragic legacy that still echoes today.",
    ),
  ];

  // ==================== 4. STOP 3: THE BLACK MAUSOLEUM SCRIPT ====================
  static const String mackenzieNarration = '''Here before you lies The Black Mausoleum, the final resting place of Sir George Mackenzie of Rosehaugh, better known today as "Bloody McKenzie."

Born in Dundee in 1636, Mackenzie was a respected lawyer, author of 'Aretina' (the first Scottish novel), and founder of the Advocates Library. But history remembers him for his ruthlessness as Lord Advocate under Charles II.

Responsible for the relentless prosecution of the Covenanters, Mackenzie sent almost 500 prisoners to the adjacent Covenanters' Prison and ordered torture and executions for hundreds more. After his death in 1691, he was buried in this ornate 17th-century mausoleum—right beside the very prison wall.

In 1999, a homeless man broke into the tomb seeking shelter, fell through the floor into a pit of old bodies, and emerged trembling in shock. Since that night, over 350 documented poltergeist attacks have been reported around the tomb: sudden cold spots, scratches, bruises, and ghostly knocking.

The Black Mausoleum remains one of the most famously haunted locations in the United Kingdom.

"That concludes this chapter of the tour. We hope you have enjoyed your visit to Greyfriars Kirkyard."''';

  static const List<TourSubtitle> mackenzieSubtitles = [
    TourSubtitle(
      startSeconds: 0.0,
      endSeconds: 18.0,
      text: "The Black Mausoleum is the tomb of Sir George Mackenzie, infamous as 'Bloody McKenzie'.",
    ),
    TourSubtitle(
      startSeconds: 18.0,
      endSeconds: 44.0,
      text: "As Lord Advocate, he led the ruthless prosecution of Covenanters, yet was buried right beside their prison.",
    ),
    TourSubtitle(
      startSeconds: 44.0,
      endSeconds: 75.0,
      text: "In 1999, an intruder broke into the crypt, awakening what became known as the Mackenzie Poltergeist.",
    ),
    TourSubtitle(
      startSeconds: 75.0,
      endSeconds: 110.0,
      text: "With over 350 documented encounters, this tomb remains one of the most haunted sites in Britain.",
    ),
  ];
}
