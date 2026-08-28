import 'package:flutter/material.dart';
import '../models/tour_model.dart';

class TourData {
  static const List<TourStop> stops = [
    TourStop(
      id: 'intro',
      label: 'Welcome',
      title: 'Introduction',
      mapTitle: 'Welcome to Greyfriars',
      mapDesc: 'Listen to a brief introduction about your journey through Greyfriars Kirkyard before heading to your first stop.',
      stopDesc: 'Listen to a brief introduction about your journey through Greyfriars Kirkyard before heading to your first stop.',
      audioAsset: 'assets/audio/intro.mp3',
      photoAsset: 'assets/images/screen-intro_photo.jpg',
      unlockedCardId: 'mary',
      mapCoordinate: Offset(0.50, 0.85),
      progressStep: 0,
      storyScript: '''Welcome to Greyfriars Kirkyard, one of the most storied, atmospheric, and historically significant churchyards in Scotland.

Founded in 1562 under Mary Queen of Scots after the churchyard at St Giles became overcrowded, this ground holds the remains of over 100,000 people beneath its lawns.

Throughout the centuries, Greyfriars has borne witness to Scotland's turbulent religious wars, the grim era of grave-robbing resurrection men, literary icons, loyal companions, and chilling supernatural legends.

As you explore today, listen closely to the audio stories at each stop. Complete the tour to test your knowledge in the Kirkyard Quiz and collect rare historical character cards!''',
    ),
    TourStop(
      id: 'stop-a',
      label: 'Stop A',
      title: 'The Mortsafes',
      mapTitle: 'Head to the Mortsafes',
      mapDesc: 'Use the map below to find your way to Stop A. Look for the iron cages near the south side of the Kirk.',
      stopDesc: 'You should see these iron cages in front of you. Press play to hear the story behind them.',
      audioAsset: 'assets/audio/mortsafes.mp3',
      photoAsset: 'assets/images/screen-stop-a_photo.jpg',
      unlockedCardId: null,
      mapCoordinate: Offset(0.55, 0.60),
      progressStep: 1,
      storyScript: '''In early 19th-century Edinburgh, medical teaching and anatomical research were at the cutting edge of science. But medical lecturers needed human cadavers for dissection, creating an immense, lucrative demand.

Enter the "Resurrection Men" — grave robbers who would creep into churchyards in the dead of night to dig up newly buried bodies and sell them to anatomy professors.

To protect their deceased loved ones, Edinburgh families invented "mortsafes": massive iron cages or heavy stone vaults placed over fresh graves. These remained locked over the coffin for six to eight weeks until the body had decomposed enough to be useless for medical dissection, after which the cage would be removed and rented to another family.

These iron cages you see before you are authentic survivals of Edinburgh's grave-robbing panic!''',
    ),
    TourStop(
      id: 'stop-b',
      label: 'Stop B',
      title: "The Covenanters' Prison",
      mapTitle: "Head to the Covenanters' Prison",
      mapDesc: "Use the map below to find your way to Stop B, in the north-west corner of the Kirkyard.",
      stopDesc: "Stand before the iron gates of the Covenanters' Prison. Press play to hear the harrowing story of the 1,200 prisoners held here.",
      audioAsset: 'assets/audio/covenenters.mp3',
      photoAsset: 'assets/images/screen-intro_photo.jpg',
      unlockedCardId: 'charles',
      mapCoordinate: Offset(0.35, 0.35),
      progressStep: 2,
      storyScript: '''In 1638, thousands of Scots gathered at Greyfriars Kirk to sign the National Covenant, pledging allegiance to their Presbyterian faith and rejecting King Charles I's attempts to impose the Anglican Book of Common Prayer.

Four decades later, following the defeat of the Covenanters at the Battle of Bothwell Bridge in 1679, over 1,200 prisoners were marched to Greyfriars and herded into this walled, open-air field.

For more than four months throughout a freezing Scottish winter, these men were kept without shelter, blankets, or basic sanitation, surviving on four ounces of bread a day. Many died of exposure and disease, while others were executed or transported as slaves.

This enclosure is widely regarded as one of the earliest concentration camps in modern European history.''',
    ),
    TourStop(
      id: 'stop-c',
      label: 'Stop C',
      title: 'The Black Mausoleum',
      mapTitle: 'Head to the Black Mausoleum',
      mapDesc: 'Use the map below to find your way to Stop C, just south of the Covenanters\' Prison.',
      stopDesc: 'You are standing before the tomb of Sir George McKenzie. Press play to uncover its dark past and modern hauntings.',
      audioAsset: 'assets/audio/black_mausoleum.mp3',
      photoAsset: 'assets/images/screen-stop-a_photo.jpg',
      unlockedCardId: null,
      mapCoordinate: Offset(0.30, 0.48),
      progressStep: 3,
      storyScript: '''Sir George Mackenzie was the Lord Advocate responsible for the brutal trial and imprisonment of the Covenanters, earning him the lasting moniker "Bluidy Mackenzie." Ironically, when he died in 1691, he was entombed in this very churchyard, only yards from his former prisoners.

The tomb remained quiet for centuries until one stormy night in 1999, when a homeless man broke inside seeking shelter from the cold. As he walked across the floor, the ground collapsed beneath him into a hidden crypt filled with coffins and skeletal remains.

Since that disturbance, the Black Mausoleum has become the focus of hundreds of reported encounters with the infamous "McKenzie Poltergeist" — from unexplained scratches and burns to strange cold spots and sudden collapses.''',
    ),
  ];
}
