import 'package:flutter/material.dart';
import '../models/tour_model.dart';

class TourData {
  // Initial entrance coordinate on the white area in the very left gateway of the map
  static const Offset entranceCoordinate = Offset(0.12, 0.16);

  static const List<TourStop> stops = [
    TourStop(
      id: 'intro',
      label: 'Welcome',
      title: 'Introduction',
      mapTitle: 'Welcome to Greyfriars',
      mapDesc:
          'Listen to a brief introduction about your journey through Greyfriars Kirkyard before heading to your first stop.',
      stopDesc:
          'Listen to a brief introduction about your journey through Greyfriars Kirkyard before heading to your first stop.',
      audioAsset: 'assets/audio/intro.mp3',
      photoAsset: 'assets/images/screen-intro_photo.jpg',
      unlockedCardId: 'mary',
      mapCoordinate: entranceCoordinate,
      walkPath: [
        Offset(0.12, 0.16),
      ],
      progressStep: 0,
      storyScript:
          '''Welcome to Greyfriars Kirkyard, one of the most storied, atmospheric, and historically significant churchyards in Scotland.

Founded in 1562 under Mary Queen of Scots after the churchyard at St Giles became overcrowded, this ground holds the remains of over 100,000 people beneath its lawns.

Throughout the centuries, Greyfriars has borne witness to Scotland's turbulent religious wars, the grim era of grave-robbing resurrection men, literary icons, loyal companions, and chilling supernatural legends.

As you explore today, listen closely to the audio stories at each stop. Complete the tour to test your knowledge in the Kirkyard Quiz and collect rare historical character cards!''',
      subtitles: [
        TourSubtitle(
          startSeconds: 0.0,
          endSeconds: 15.0,
          text:
              'Welcome to Greyfriars Kirkyard, one of the most storied and atmospheric churchyards in Scotland.',
        ),
        TourSubtitle(
          startSeconds: 15.0,
          endSeconds: 32.0,
          text:
              'Founded in 1562 under Mary Queen of Scots, this ground holds the remains of over 100,000 souls.',
        ),
        TourSubtitle(
          startSeconds: 32.0,
          endSeconds: 52.0,
          text:
              'Throughout the centuries, Greyfriars witnessed religious wars, grave-robbing resurrection men, and supernatural legends.',
        ),
        TourSubtitle(
          startSeconds: 52.0,
          endSeconds: 85.0,
          text:
              'Listen closely to each audio stop to test your knowledge in the Kirkyard Quiz and unlock rare character cards!',
        ),
      ],
    ),
    TourStop(
      id: 'stop-a',
      label: 'Stop A',
      title: 'The Mortsafes',
      mapTitle: 'Head to the Mortsafes',
      mapDesc:
          'Use the map below to find your way to Stop A. Look for the iron cages near the south side of the Kirk.',
      stopDesc:
          'You should see these iron cages in front of you. Press play to hear the story behind them.',
      audioAsset: 'assets/audio/mortsafes.mp3',
      photoAsset: 'assets/images/screen-stop-a_photo.jpg',
      unlockedCardId: null,
      mapCoordinate: Offset(0.52, 0.59),
      walkPath: [
        Offset(0.12, 0.16),
        Offset(0.22, 0.16),
        Offset(0.33, 0.16),
        Offset(0.42, 0.22),
        Offset(0.50, 0.35),
        Offset(0.56, 0.48),
        Offset(0.52, 0.59),
      ],
      progressStep: 1,
      storyScript:
          '''In early 19th-century Edinburgh, medical teaching and anatomical research were at the cutting edge of science. But medical lecturers needed human cadavers for dissection, creating an immense, lucrative demand.

Enter the "Resurrection Men" — grave robbers who would creep into churchyards in the dead of night to dig up newly buried bodies and sell them to anatomy professors.

To protect their deceased loved ones, Edinburgh families invented "mortsafes": massive iron cages or heavy stone vaults placed over fresh graves. These remained locked over the coffin for six to eight weeks until the body had decomposed enough to be useless for medical dissection, after which the cage would be removed and rented to another family.

These iron cages you see before you are authentic survivals of Edinburgh's grave-robbing panic!''',
      subtitles: [
        TourSubtitle(
          startSeconds: 0.0,
          endSeconds: 18.0,
          text:
              'In early 19th-century Edinburgh, medical research was at the cutting edge of science.',
        ),
        TourSubtitle(
          startSeconds: 18.0,
          endSeconds: 38.0,
          text:
              'Lecturers needed human cadavers for dissection, creating an immense, lucrative demand for bodies.',
        ),
        TourSubtitle(
          startSeconds: 38.0,
          endSeconds: 64.0,
          text:
              'Resurrection Men crept into churchyards at night to dig up newly buried corpses and sell them.',
        ),
        TourSubtitle(
          startSeconds: 64.0,
          endSeconds: 96.0,
          text:
              'Families invented "mortsafes": massive iron cages locked over graves to protect their deceased loved ones.',
        ),
        TourSubtitle(
          startSeconds: 96.0,
          endSeconds: 125.0,
          text:
              'These iron cages you see before you are authentic survivals of Edinburgh\'s grave-robbing panic!',
        ),
      ],
    ),
    TourStop(
      id: 'stop-b',
      label: 'Stop B',
      title: "Covenanters' Prison",
      mapTitle: "Head to the Covenanters' Prison",
      mapDesc:
          "Walk towards the southern section of the graveyard to find the gated entrance to the Covenanters' Prison.",
      stopDesc:
          'Stand near the iron gates of the prison. Listen to the tragic story of what took place here in 1679.',
      audioAsset: 'assets/audio/covenanters.mp3',
      photoAsset: '',
      unlockedCardId: null,
      mapCoordinate: Offset(0.44, 0.15),
      walkPath: [
        Offset(0.52, 0.59),
        Offset(0.56, 0.48),
        Offset(0.50, 0.35),
        Offset(0.42, 0.22),
        Offset(0.33, 0.16),
        Offset(0.44, 0.15),
      ],
      progressStep: 2,
      storyScript:
          '''Behind these iron gates lies what is often described as the world's first open-air concentration camp.

In 1679, following the Battle of Bothwell Bridge, over 1,200 Scottish Covenanters — Presbyterians who resisted the King's attempts to enforce Anglican worship — were marched here and imprisoned in this muddy field.

For over four bitter months through autumn and winter, with no roof or shelter, they survived on four ounces of bread a day. Many perished from exposure and starvation. Others were executed at the nearby Grassmarket, while over 250 were sentenced to transportation to the Caribbean, only to perish in a shipwreck off Orkney.

Today, this enclosure remains a solemn memorial to their sacrifice.''',
      subtitles: [
        TourSubtitle(
          startSeconds: 0.0,
          endSeconds: 16.0,
          text:
              'Behind these iron gates lies what is often described as the world\'s first open-air concentration camp.',
        ),
        TourSubtitle(
          startSeconds: 16.0,
          endSeconds: 38.0,
          text:
              'In 1679, over 1,200 Scottish Covenanters were imprisoned in this open field without shelter.',
        ),
        TourSubtitle(
          startSeconds: 38.0,
          endSeconds: 62.0,
          text:
              'For four bitter months, with four ounces of bread a day, many perished from starvation and exposure.',
        ),
        TourSubtitle(
          startSeconds: 62.0,
          endSeconds: 90.0,
          text:
              'Today, this enclosure stands as a solemn memorial to Scotland\'s turbulent religious history.',
        ),
      ],
    ),
    TourStop(
      id: 'stop-c',
      label: 'Stop C',
      title: 'Mackenzie Mausoleum',
      mapTitle: 'Head to the Black Mausoleum',
      mapDesc:
          'Follow the path to the domed mausoleum of Sir George "Bloody" Mackenzie.',
      stopDesc:
          'You are standing before the Black Mausoleum. Listen to the history and dark legends surrounding this tomb.',
      audioAsset: 'assets/audio/black_mausoleum.mp3',
      photoAsset: '',
      unlockedCardId: null,
      mapCoordinate: Offset(0.44, 0.52),
      walkPath: [
        Offset(0.44, 0.15),
        Offset(0.33, 0.16),
        Offset(0.24, 0.24),
        Offset(0.25, 0.38),
        Offset(0.33, 0.48),
        Offset(0.44, 0.52),
      ],
      progressStep: 3,
      storyScript:
          '''This imposing domed structure is the final resting place of Sir George Mackenzie of Rosehaugh, King's Advocate under Charles II.

Infamous in Scottish history as "Bluidy Mackenzie," he ruthlessly persecuted the Covenanters, sending hundreds to their deaths and imprisonment just yards away. Ironically, he was buried right beside the very people he condemned.

Since 1999, after a homeless intruder broke into the tomb and fell into an old pit of coffins, the mausoleum has been the epicenter of what paranormal researchers call the "Mackenzie Poltergeist" — with hundreds of documented reports of cold spots, scratches, and unexplained phenomena.''',
      subtitles: [
        TourSubtitle(
          startSeconds: 0.0,
          endSeconds: 18.0,
          text:
              'This imposing domed structure is the tomb of Sir George Mackenzie, known as "Bluidy Mackenzie".',
        ),
        TourSubtitle(
          startSeconds: 18.0,
          endSeconds: 40.0,
          text:
              'As King\'s Advocate, he persecuted the Covenanters, yet was buried right beside them.',
        ),
        TourSubtitle(
          startSeconds: 40.0,
          endSeconds: 65.0,
          text:
              'Since 1999, after an intruder breached the tomb, it became famous for the "Mackenzie Poltergeist".',
        ),
        TourSubtitle(
          startSeconds: 65.0,
          endSeconds: 95.0,
          text:
              'Hundreds of visitors have reported unexplained cold spots, scratches, and supernatural encounters here.',
        ),
      ],
    ),
  ];
}
