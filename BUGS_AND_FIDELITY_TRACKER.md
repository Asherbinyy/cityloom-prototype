# CityLoom: HTML Prototype vs Flutter Side-by-Side Fidelity & Bug Tracker

This document provides a comprehensive side-by-side comparison between the original HTML/CSS/JS prototype (`Prototype Files/The Html Code.txt`) and the Flutter Web implementation (`lib/`).

---

## 1. Top AppBar & Header Comparison

| Element | HTML Specification (`The Html Code.txt`) | Flutter Current Status | Required Action / Fix |
| :--- | :--- | :--- | :--- |
| **Top Bar Layout** | Flexbox with `.top-bar-left`, `.top-bar-center` (absolute centered logo), and `.top-bar-right`. | Centered Row with logo & title. | Use absolute centered CityLoom logo on the same baseline without title crowding. |
| **Logo Image** | Exact CityLoom logo SVG/PNG (`height: 22px`, centered). | `Image.asset('assets/images/logo.png', height: 24)`. | Align logo perfectly in center and ensure exact proportional sizing. |
| **Back Button** | 36x36px circle, `background: rgba(255,255,255,0.7)`, `border: 1px solid var(--blush)`, coral chevron icon. | 40x40px circle, coral back arrow. | Standardize to 36x36px with frosted glass blur effect (`BackdropFilter`). |
| **Library Button** | Pill shaped `20px` height with custom book icon and count `X/10` in DM Sans bold. | Custom `library_icon.png` extracted from HTML base64 with `X/10` badge. | Ensure exact 20x20px icon sizing with `rgba(255,255,255,0.7)` frosted glass background. |

---

## 2. Audio Player & Synced Lyrics

| Feature | HTML Prototype | Flutter Implementation | Required Action / Fix |
| :--- | :--- | :--- | :--- |
| **Audio Label** | `AUDIO STORY` (uppercase DM Sans, letter-spacing 2px, coral `#FDA692`, no bullet dot `•`). | Removed dot, rendered as `AUDIO STORY`. | Match exact typography (`11px DM Sans 700`, uppercase, coral). |
| **Audio Player Controls** | 48px coral circle with white play/pause icon, speed pill `1.0x / 1.5x / 2.0x`, slider with coral fill. | 68px circle, custom slider, speed pill. | Standardize play button to 48px circle, matching HTML proportions. |
| **Script Toggle** | Single "Show Script" / "Hide Script" text button with chevron. | "Show Script" / "Hide Script" text button. | Animated height transition on script reveal. |
| **Live Lyrics Highlighting** | Real-time bold & color highlight tracking active spoken words (Spotify style). | Line-by-line subtitle tracking with bold highlight for active segment. | Match exact audio timestamps and highlight active words/phrases dynamically. |

---

## 3. Interactive Map & Walking Animation

| Feature | HTML Prototype | Flutter Implementation | Required Action / Fix |
| :--- | :--- | :--- | :--- |
| **Initial Position** | Gateway on far west: `(0.12, 0.16)`. | Initial coordinates set to `Offset(0.12, 0.16)`. | Verified: Avatar starts on white gateway. |
| **Stop A Pin** | Mortsafes: `(0.52, 0.59)`. | `Offset(0.52, 0.59)`. | Pin rests directly over the Mortsafes label on the map illustration. |
| **Stop B Pin** | Covenanters' Prison: `(0.44, 0.15)`. | `Offset(0.44, 0.15)`. | Pin rests directly over Covenanters' Prison gate. |
| **Stop C Pin** | Black Mausoleum: `(0.44, 0.52)`. | `Offset(0.44, 0.52)`. | Pin rests directly over Black Mausoleum. |
| **Walk Paths** | Constrained strictly to stone walkways without cutting across grass or Kirk building. | Custom path waypoints following stone paths. | Keep avatar trajectory precisely on stone walkways. |
| **Footsteps Trail** | Natural alternating dual footsteps (left/right feet) along trajectory with lateral offset and angle rotation. | `CustomPainter` with dual alternating foot shapes and rotation. | Render footsteps with footstep audio clicks during movement. |
| **Completed Badge** | Circular emerald badge with checkmark emblem. | Gradient emerald badge with white checkmark. | Ensure crisp rendering on both mobile and web. |

---

## 4. Card Library & Background Gradients

| Screen / Feature | HTML Prototype | Flutter Implementation | Required Action / Fix |
| :--- | :--- | :--- | :--- |
| **Library Background** | `linear-gradient(170deg, #fff4eb 0%, #d4e8f2 50%, #a5cee4 100%)` (Blue-ish theme). | Applied `AppScaffold.libraryGradient`. | Verified: Library has blue-ish gradient while other screens have warm peach gradient. |
| **Rarity Colors** | Common: `#2A2A2A`, Uncommon: `#2563EB`, Rare: `#9333EA`, Legendary: `#D97706`. | Exact hex colors for rarity headers and badges. | Verified: Correct colors displayed. |
| **Locked Cards** | Dark textured card with padlock icon 🔒, card name, and hint text. Shakes on tap. | Custom styled dark card with antique gold lock, card title, hint, and shake animation. | Tap locked card $\rightarrow$ shake animation + floating hint toast. |
| **Unlocked Cards** | Full-bleed card illustration with Hero pop-in animation on tap. | Hero widget + Fullscreen dialog view. | Smooth dialog popup with card details and historical bio. |

---

## 5. Kirkyard Quiz Interactions & Colors

| Question Type | HTML Prototype | Flutter Implementation | Required Action / Fix |
| :--- | :--- | :--- | :--- |
| **Single Choice** | Tap to select (coral border, cream bg). Tap selected to deselect. Confirm button. | Single choice with deselect and Confirm button. | Green `#6BCB77` on correct, Red `#E74C3C` on incorrect. |
| **Multi-Select** | Checkboxes toggle on/off. Confirm button. | Multi-select with toggle checkboxes and Confirm button. | Accurate multi-option scoring. |
| **True / False** | Large True / False buttons. Tap selected to deselect. | True / False buttons with deselect. | Immediate feedback on Confirm. |
| **Matching Questions** | Left item selects (coral). Right item pairs with color. **Tap paired item to unpair/deselect**. | Color-coded matching with unpairing on tap. | Match colors: Purple (`#9B59B6`), Gold (`#E6A817`), Blue (`#3498DB`), Green (`#27AE60`), Red (`#E74C3C`). |
| **Order Questions** | Drag & drop or numbered reorder. | `ReorderableListView` with number badges. | Smooth drag-and-drop ordering. |
| **Post-Quiz Survey** | "We'd love your feedback!" card linking to Google Form. | "Help Shape CityLoom!" feedback card. | Opens `https://forms.gle/2iMZ6P9CGV3iMUja7`. |

---

## 6. Navigation Stack & History

| Transition | HTML Behavior | Flutter Implementation | Status |
| :--- | :--- | :--- | :--- |
| **Quiz $\rightarrow$ Back** | Returns to Difficulty Selection (`screen-quiz-select`). | `appState.goBack()` pops to `AppScreen.quizSelect`. | ✅ Fixed |
| **Library $\rightarrow$ Back** | Returns to the exact previous screen (Tour, Map, Complete, or Home). | `appState.goBack()` pops history stack. | ✅ Fixed |
| **Survey $\rightarrow$ Back** | Returns to previous screen without jumping to Splash. | `appState.goBack()` pops history stack. | ✅ Fixed |
| **Stop $\rightarrow$ Back** | Returns to the corresponding Map screen for that stop. | `appState.goBack()` returns to `MapScreen`. | ✅ Fixed |

---

## 7. Card Unlock Sequences & Sound Gestures

| Card ID | Character Name | Unlock Rule in HTML Prototype |
| :--- | :--- | :--- |
| `mary` | Mary Queen of Scots | Automatically unlocked after Welcome/Intro stop audio. |
| `bobby` | Greyfriars Bobby | Complete any Explorer quiz. |
| `charles` | King Charles I | Unlocked after Stop B (Covenanters' Prison). |
| `burke` | William Burke | Answer Apprentice Q6 correctly (Match person to role). |
| `hare` | William Hare | Answer Historian Q2 correctly (Burke & Hare T/F). |
| `margaret` | Margaret Docherty | Burke & Hare unlocked + Scholar Q8 (Odd One Out) correct. |
| `mckenzie` | George "Bluidy" McKenzie | Answer Scholar Q6 (National Covenant) or McKenzie Q correctly. |
| `henrietta` | Queen Henrietta Maria | Charles I unlocked + Scholar Q4 correct. |
| `poltergeist` | The McKenzie Poltergeist | Score 100% on all 4 difficulty levels (Explorer, Apprentice, Historian, Scholar). |
| `knox` | Dr. Robert Knox | Complete all Burke & Hare questions across all tiers. |

---

## 8. Running HTML vs Flutter Side-by-Side

To run both side-by-side for pixel-perfect comparison:
1. **HTML Prototype**: Open `Prototype Files/The Html Code.txt` directly in any web browser (or rename to `.html`).
2. **Flutter Web Prototype**: Run locally at `http://localhost:8080` or view online at `https://asherbinyy.github.io/cityloom-prototype/`.
