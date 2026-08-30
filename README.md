# CityLoom – Greyfriars Kirkyard Prototype

An interactive, responsive audio walking tour and gamified exploration of **Greyfriars Kirkyard** in Edinburgh, built with **Flutter Web**.

🌐 **Live Demo:** [https://asherbinyy.github.io/cityloom-prototype/](https://asherbinyy.github.io/cityloom-prototype/)

---

## 🌟 Key Features

1. **Immersive Audio Walking Tour:**
   - **Per-Stop Narration:** Distinct, high-quality audio recordings for Intro, Stop A (*The Mortsafes*), Stop B (*The Covenanters' Prison*), and Stop C (*The Black Mausoleum*).
   - **Spotify-Style Synced Transcripts:** Dynamic word-level karaoke transcript highlighting powered by Whisper JSON timestamps.
   - **Playback Speed Controller:** Toggle easily between **1.0x**, **1.5x**, **2.0x**, and **3.0x** speed.
   - **Consistent Navigation:** Uniform button dimensions across both primary actions and skip actions.

2. **Interactive Map Navigation:**
   - Visual map of Greyfriars Kirkyard with interactive pins for Stops A, B, and C.
   - Animated walking character following tour progress with pulsing destination markers.

3. **Gamified 4-Tier Kirkyard Quiz:**
   - **4 Difficulty Tiers:** Explorer (5 Qs), Apprentice (7 Qs), Historian (10 Qs), and Scholar (14 Qs).
   - **7 Question Formats:** Single Choice, True/False, Multi-Select, Fill in the Blank, Odd One Out, Matching Pairs, and Drag/Tap Ordering.
   - **Historical Context Modals:** Learn More popups on options for deep educational engagement.

4. **Character Card Collection & Unlocks:**
   - **10 Unique Cards** across 4 Rarity Tiers:
     - *Common:* Mary Queen of Scots, Greyfriars Bobby, King Charles I, William Burke, William Hare
     - *Uncommon:* Margaret Docherty, George "Bluidy" McKenzie
     - *Rare:* Henrietta Maria
     - *Legendary:* The McKenzie Poltergeist, Dr Robert Knox
   - **Two-Step Unlock Reveal Animation:** Teaser with rarity badge → 3D flip card reveal with celebration shine.
   - **Zoomable Card Viewer:** Inspect high-resolution card illustrations and historical biographies in the Library.
   - **Grand Completion Celebration:** Trophy celebration when all 10 cards are collected.

5. **Feedback & Survey Integration:**
   - Direct integration with Google Forms for user feedback: [https://forms.gle/2iMZ6P9CGV3iMUja7](https://forms.gle/2iMZ6P9CGV3iMUja7).

---

## 📂 Project Architecture

```
lib/
├── data/
│   ├── card_data.dart        # 10 character cards definitions, rarities, and bios
│   ├── quiz_data.dart        # 36 quiz questions across 4 tiers + learn more context
│   └── tour_data.dart        # 4 stops, audio paths, map coordinates
├── models/
│   ├── card_model.dart       # CharacterCard model and CardRarity enum
│   ├── quiz_model.dart       # QuizQuestion, LearnMoreInfo, QuestionType enums
│   └── tour_model.dart       # TourStop model
├── screens/
│   ├── home_screen.dart           # Logo, title, disclaimer, start button
│   ├── intro_screen.dart          # Welcome intro audio and synced transcript
│   ├── map_screen.dart            # Interactive map navigation
│   ├── stop_screen.dart           # Stop photograph, audio player, and synced transcript
│   ├── tour_complete_screen.dart  # Tour wrap-up and collection stats
│   ├── quiz_screen.dart           # Tier select, 7-question runner, and results
│   ├── library_screen.dart        # Card collection grid with locked teasers
│   └── survey_screen.dart         # Google Forms feedback link
├── state/
│   └── app_state.dart             # Card unlocks, navigation, quiz scores, storage
├── theme/
│   └── app_theme.dart             # CityLoom color palette and DM Sans / Playfair typography
├── widgets/
│   ├── app_image.dart             # Shimmer image loader placeholder
│   ├── app_scaffold.dart          # Responsive max-width web layout & header
│   ├── audio_player_card.dart     # JustAudio player with speed controller
│   ├── synced_transcript.dart     # Whisper word-level synced transcript viewer
│   ├── card_fullscreen_dialog.dart# Zoomable card inspection modal
│   ├── card_reveal_dialog.dart    # 3D card unlock reveal modal
│   ├── congratulations_dialog.dart# 10-card completion celebration
│   ├── credits_dialog.dart        # Project credits & AI disclaimer modal
│   ├── map_interactive_widget.dart# Animated map with pins and walking avatar
│   ├── primary_button.dart        # Uniform primary and secondary buttons
│   ├── progress_strip.dart        # Step progress indicator
│   └── quit_quiz_dialog.dart      # Quiz quit confirmation modal
└── main.dart                      # MultiProvider setup and screen router
```

---

## 🚀 Running Locally

### Prerequisites
- Flutter SDK 3.24+ / 3.47+ (or FVM)

### Development
```bash
# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome
```

### Build for Web Release
```bash
flutter build web --release --base-href /cityloom-prototype/
```

---

## 👥 Credits

- **Director and research:** Malek Ben Khaled
- **Scriptwriter:** Aoibhín Gallagher
- **Voice actors:** Gregor Campbell, Kieran Lee-Hamilton, Robbie Hail, Malek Ben Khaled
- **Sound production and design:** Malek Ben Khaled
- **Quiz Concept:** Malek Ben Khaled
- **Prototype development:** Ahmed Elsherbini

*All sounds and music used in this project are copyright and royalty-free. All real location photographs in this project were taken by the founder.*

**Disclaimer:** *Illustrations are currently AI-generated but **will not be used** in the final product.*
