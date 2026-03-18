# QodeX Kabbalah Module Specification

## Overview
The Kabbalah Module provides an interactive journey through the Tree of Life, offering personalized spiritual insights based on the user's birth data and current spiritual cycles.

---

## Core Concepts

### Tree of Life (Etz Chaim)
The Tree of Life consists of **10 Sephirot** (divine emanations) connected by **22 Paths** (Hebrew letters):

```
        Kether (1)
       /        \
   Chokmah --- Binah (2-3)
    (Wisdom)  (Understanding)
       |    |    |
   Chesed   |   Geburah (4-5)
  (Mercy)   |  (Severity)
       \    |    /
        Tiphareth (6)
       (Beauty)
       /        \
    Netzach --- Hod (7-8)
   (Victory)  (Splendor)
       \        /
       Yesod (9)
    (Foundation)
         |
      Malkuth (10)
      (Kingdom)
```

### The 22 Hebrew Letters & Paths
| Letter | Name | Path | Meaning | Element |
|--------|------|------|---------|---------|
| א | Aleph | 11 | Ox, Beginning | Air |
| ב | Bet | 12 | House | Mercury |
| ג | Gimel | 13 | Camel | Moon |
| ד | Dalet | 14 | Door | Venus |
| ה | He | 15 | Window | Aries |
| ו | Vav | 16 | Nail/Nail | Taurus |
| ז | Zayin | 17 | Sword | Gemini |
| ח | Chet | 18 | Fence | Cancer |
| ט | Tet | 19 | Serpent | Leo |
| י | Yod | 20 | Hand | Virgo |
| כ | Kaf | 21 | Palm | Jupiter |
| ל | Lamed | 22 | Ox Goad | Libra |
| מ | Mem | 23 | Water | Water |
| נ | Nun | 24 | Fish | Scorpio |
| ס | Samekh | 25 | Prop | Sagittarius |
| ע | Ayin | 26 | Eye | Capricorn |
| פ | Pe | 27 | Mouth | Mars |
| צ | Tsade | 28 | Fish Hook | Aquarius |
| ק | Qof | 29 | Back of Head | Pisces |
| ר | Resh | 30 | Head | Sun |
| ש | Shin | 31 | Tooth | Fire |
| ת | Tav | 32 | Cross | Saturn |

### Four Worlds (Olamot)
| World | Name | Quality | Sephirot | Associated With |
|-------|------|---------|----------|-----------------|
| Atzilut | Emanation | Archetypal | 1 | Divine Will |
| Briah | Creation | Creative | 2-3 | Archangels |
| Yetzirah | Formation | Formative | 4-9 | Angels |
| Assiah | Action | Material | 10 | Physical World |

---

## Feature Specifications

### 1. Interactive Tree of Life Visualization

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  🌳 Tree of Life                        │
│                                         │
│       ╭─────────╮                       │
│       │ Kether  │ ① Crown               │
│       ╰────┬────╯   Divine Will         │
│      ╱     │     ╲                      │
│  ╭──┴──╮   │   ╭──┴──╮                  │
│  │Chok.│───┼───│Binah│ ②③ Supernal     │
│  ╰──┬──╯   │   ╰──┬──╯                  │
│     │  ╭───┴───╮  │                      │
│     └──┤Tiphar.├──┘ ⑥ Balance           │
│        ╰───┬───╯                        │
│   ╭────────┼────────╮                   │
│ ╭─┴─╮    ╭─┴─╮    ╭─┴─╮                 │
│ │Che│────│Ye │────│Hod│ ④⑤⑨            │
│ ╰─┬─╯    ╰───╯    ╰─┬─╯                 │
│   │                 │                   │
│ ╭─┴─╮             ╭─┴─╮                 │
│ │Net│─────────────│Mal│ ⑦⑧⑩            │
│ ╰───╯             ╰───╯                 │
│                                         │
│  [My Tree] [Meditations] [Letters] [🔮] │
└─────────────────────────────────────────┘
```

**Features:**
- **3D/2D Toggle**: Switch between dimensional representations
- **Tap to Explore**: Each Sephira opens detailed modal
- **Path Highlighting**: Tap a path to see corresponding Hebrew letter
- **Personal Overlay**: Show user's activated Sephirot with glow effects
- **Zoom & Pan**: Explore the tree at different scales

**Technical Specs:**
- Use SwiftUI + SceneKit for 3D rendering
- SVG fallback for 2D mode
- 60fps animation for interactions
- Haptic feedback on selection

---

### 2. Personal Sephirot Activation

**Calculation Logic:**

#### Birth Sephira Calculation
```swift
func calculateBirthSephira(birthDate: Date) -> Sephira {
    // 1. Calculate Life Path Number
    let lifePath = calculateLifePath(from: birthDate)
    
    // 2. Map Life Path to Sephira
    // Life Path 1,10,19,28 -> Kether (1)
    // Life Path 2,11,20,29 -> Chokmah (2)
    // Life Path 3,12,21,30 -> Binah (3)
    // Life Path 4,13,22,31 -> Chesed (4)
    // Life Path 5,14,23,32 -> Geburah (5)
    // Life Path 6,15,24,33 -> Tiphareth (6)
    // Life Path 7,16,25 -> Netzach (7)
    // Life Path 8,17,26 -> Hod (8)
    // Life Path 9,18,27 -> Yesod (9)
    // Master Numbers 11,22,33 have dual resonance
    
    let sephiraNumber = lifePath % 10 == 0 ? 1 : lifePath % 10
    return Sephira.allCases[sephiraNumber - 1]
}
```

#### Personal Tree Mapping
```swift
struct PersonalTree {
    let dominantSephira: Sephira      // Primary life energy
    let supportingSephira: [Sephira]   // Secondary influences
    let challengeSephira: Sephira      // Growth area
    let gatewayPath: HebrewLetter      // Primary spiritual path
    
    // Calculate from full birth chart data
    init(birthChart: BirthChart) {
        // Elemental distribution affects Sephirot
        // Fire -> Geburah, Netzach strength
        // Water -> Binah, Hod strength
        // Air -> Chokmah, Yesod strength
        // Earth -> Malkuth, Chesed strength
    }
}
```

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  ✨ Your Personal Tree                  │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │    [Tree visualization with     │   │
│  │     your activated nodes         │   │
│  │     glowing in gold]            │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  🌟 DOMINANT: Tiphareth (Beauty)        │
│     Life Path: 6                        │
│     Quality: Harmony, compassion        │
│                                         │
│  Your Tree Profile:                     │
│  ├─ Strong: Chesed (Mercy) ████████░░   │
│  ├─ Strong: Geburah (Strength) █████░░░ │
│  ├─ Active: Yesod (Foundation) ██████░░ │
│  └─ Growth: Kether (Crown) ███░░░░░░░   │
│                                         │
│  [View Full Analysis] [Daily Focus]     │
└─────────────────────────────────────────┘
```

---

### 3. Path Working Meditations

**Content Structure:**

#### Meditation Library
| Path | Hebrew Letter | Theme | Duration | Difficulty |
|------|---------------|-------|----------|------------|
| 11 | Aleph (א) | The Fool's Journey | 10 min | Beginner |
| 12 | Bet (ב) | The House Within | 12 min | Beginner |
| 13 | Gimel (ג) | The Desert Crossing | 15 min | Intermediate |
| 14 | Dalet (ד) | Open Doorways | 12 min | Intermediate |
| 15 | He (ה) | Divine Breath | 10 min | Beginner |
| ... | ... | ... | ... | ... |

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  🧘 Path Working                        │
│                                         │
│  Current Path: Path 22 - Lamed (ל)      │
│  Connecting: Chesed ↔ Tiphareth         │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │     [Visualization:            │   │
│  │      Walking the path           │   │
│  │      between spheres]           │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Today's Practice:                      │
│  "The Ox Goad - Discipline in Love"    │
│                                         │
│  ┌─ Meditation Guide ─────────────┐    │
│  │ • Sit comfortably              │    │
│  │ • Visualize the blue path...   │    │
│  │ • Breathe with the letter...   │    │
│  │ • Enter Tiphareth's light...   │    │
│  └────────────────────────────────┘    │
│                                         │
│  [Start 15-min Journey] [Journal]       │
│                                         │
│  Your Progress: 7/22 Paths explored     │
│  ████████░░░░░░░░░░░░ 32%              │
└─────────────────────────────────────────┘
```

**Features:**
- Guided audio meditations
- Visual path animations
- Breathing timers synchronized to Hebrew letter vibrations
- Progress tracking across all 22 paths
- Journal entries for each path experience

---

### 4. Daily Sephira Focus

**Calculation Logic:**
```swift
func calculateDailyFocus(for date: Date, user: User) -> DailyFocus {
    // 1. Universal day calculation
    let universalDay = calculateUniversalDay(date)
    
    // 2. Personal day calculation
    let personalDay = calculatePersonalDay(date, birthDate: user.birthDate)
    
    // 3. Current astrological influences
    let planetaryHour = calculatePlanetaryHour(date)
    
    // 4. Determine dominant Sephira
    // Weight: Personal day (40%), Universal day (30%), Planetary hour (30%)
    let sephiraWeights = calculateWeightedInfluence(
        personal: personalDay,
        universal: universalDay,
        planetary: planetaryHour
    )
    
    return DailyFocus(
        primarySephira: sephiraWeights.max(),
        secondaryInfluences: sephiraWeights.next(2),
        guidance: generateGuidance(for: sephiraWeights),
        practices: suggestPractices(for: sephiraWeights),
        affirmation: generateAffirmation(for: sephiraWeights)
    )
}
```

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  📅 Tuesday, March 11, 2025            │
│                                         │
│  ╭─────────────────────────────────╮   │
│  │                                 │   │
│  │         ⚡ GEBURAH ⚡           │   │
│  │         (Severity)              │   │
│  │              5                  │   │
│  │                                 │   │
│  │    "The Strength to Discern"    │   │
│  │                                 │   │
│  ╰─────────────────────────────────╯   │
│                                         │
│  Today's Energy: MARS                   │
│  Quality: Discipline, Boundaries, Power │
│  Color: Red                             │
│  Metal: Iron                            │
│                                         │
│  🎯 Focus Areas:                        │
│  • Set clear boundaries                 │
│  • Cut away what no longer serves       │
│  • Stand firm in your truth             │
│                                         │
│  🧘 Suggested Practice:                 │
│  "The Sword of Discernment"             │
│  [Start 10-min meditation]              │
│                                         │
│  💎 Daily Affirmation:                  │
│  "I have the strength to release        │
│   what holds me back."                  │
│                                         │
│  Also Influential: Tiphareth, Hod       │
└─────────────────────────────────────────┘
```

---

### 5. Hebrew Letter Meanings

**Content Structure:**

Each letter entry includes:
- **Symbol**: Character + Name
- **Numeric Value**: Gematria
- **Meaning**: Core concept
- **Shape Significance**: Visual meditation
- **Sound**: Pronunciation guide + audio
- **Path Details**: Connecting Sephirot
- **Tarot Correspondence**: Associated Major Arcana
- **Personal Connection**: User's relationship based on birth data

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  א Aleph (אלף)                          │
│  The First Breath                       │
│                                         │
│  ┌────────┐                             │
│  │        │  Gematria: 1               │
│  │  א     │  Element: Air              │
│  │        │  Planet: Mercury           │
│  └────────┘  Tarot: The Fool (0)        │
│                                         │
│  Path 11: Kether ↔ Chokmah              │
│  [Visual diagram of connection]         │
│                                         │
│  Meanings:                              │
│  • Ox (strength, patience)              │
│  • Beginning, the breath before thought │
│  • The silent letter, pure spirit       │
│                                         │
│  In Your Chart:                         │
│  Aleph appears in your Hebrew name      │
│  analysis as a gateway letter.          │
│  Personal strength: 78%                 │
│                                         │
│  [Listen to pronunciation]              │
│  [Meditate with this letter]            │
└─────────────────────────────────────────┘
```

---

### 6. Correspondences System

**Master Correspondence Table:**

| Number | Sephira | Hebrew | Planet | Metal | Color | Tarot | Angel |
|--------|---------|--------|--------|-------|-------|-------|-------|
| 1 | Kether | - | Primum Mobile | - | White brilliance | - | Metatron |
| 2 | Chokmah | א | Zodiac | - | Grey | 4 Kings | Raziel |
| 3 | Binah | ב | Saturn | Lead | Black | 3 Queens | Tzaphkiel |
| 4 | Chesed | ג | Jupiter | Tin | Blue | 4 Aces | Tzadkiel |
| 5 | Geburah | ד | Mars | Iron | Red | 4 Twos | Khamael |
| 6 | Tiphareth | ה | Sun | Gold | Yellow | 4 Sixes | Raphael |
| 7 | Netzach | ו | Venus | Copper | Green | 4 Fours | Haniel |
| 8 | Hod | ז | Mercury | Mercury | Orange | 4 Fives | Michael |
| 9 | Yesod | ח | Moon | Silver | Purple | 4 Nines | Gabriel |
| 10 | Malkuth | ט | Earth | - | Multicolor | 4 Tens | Sandalphon |

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  🔗 Correspondences                     │
│                                         │
│  Select to explore connections:         │
│                                         │
│  [Number] [Planet] [Sephira] [Tarot]    │
│  [Metal]  [Color]  [Angel] [Element]    │
│                                         │
│  Showing: Number → Sephira → Planet     │
│                                         │
│  ╭─────────────────────────────────╮   │
│  │  Number 6  →  Tiphareth        │   │
│  │  (Beauty)  →  ☉ Sun            │   │
│  │                                 │   │
│  │  Color: Yellow/Gold            │   │
│  │  Metal: Gold                   │   │
│  │  Tarot: 4 Sixes, The Sun       │   │
│  │  Angel: Raphael                │   │
│  │  Element: Air/Fire balance     │   │
│  ╰─────────────────────────────────╯   │
│                                         │
│  Personal Note:                         │
│  Tiphareth is your dominant Sephira.    │
│  [View in My Tree]                      │
└─────────────────────────────────────────┘
```

---

## Current Spiritual Cycle

**Calculation Logic:**
```swift
struct SpiritualCycle {
    let currentCycle: CycleType
    let progress: Double  // 0.0 - 1.0
    let activePaths: [HebrewLetter]
    let dominantWorld: FourWorlds
    
    enum CycleType {
        case sephira(Sephira)  // ~28 days per Sephira
        case path(HebrewLetter) // ~52 days per path
        case year(Int)          // Hebrew year influence
    }
}

func calculateSpiritualCycle(for date: Date, user: User) -> SpiritualCycle {
    // 1. Sephirot Cycle: 10 Sephirot × 28 days = 280 day cycle
    let daysSinceReference = date.daysSince(springEquinoxReference)
    let sephiraIndex = (daysSinceReference % 280) / 28
    let sephiraProgress = Double(daysSinceReference % 28) / 28.0
    
    // 2. Path Cycle: 22 Paths × 16 days = 352 day cycle
    let pathDaysSince = date.daysSince(pathReferenceDate)
    let pathIndex = (pathDaysSince % 352) / 16
    
    // 3. Hebrew Year influence
    let hebrewYear = date.hebrewYear()
    let yearNumber = hebrewYear % 22  // 22-year cycle
    
    return SpiritualCycle(
        currentCycle: .sephira(Sephira.allCases[sephiraIndex]),
        progress: sephiraProgress,
        activePaths: calculateActivePaths(for: date),
        dominantWorld: calculateDominantWorld(for: date, user: user)
    )
}
```

---

## Integration Points

### With Numerology Module
- Life Path number → Primary Sephira
- Personal Year → Influencing Sephira
- Name analysis → Hebrew letter correspondences

### With Astrology Module
- Planet positions → Active Sephirot
- Zodiac sign → Element → Sephira affinities
- House placements → Path activations

### With Tarot Module
- Path → Major Arcana mapping
- Sephira → Minor Arcana (suits)
- Daily spread → Tree of Life spread positions

### With Meditation Module
- Sephira meditations → Audio library
- Path working → Guided journeys
- Breathing exercises → Hebrew letter vibrations

---

## Data Models

```swift
// MARK: - Core Enums

enum Sephira: Int, CaseIterable {
    case kether = 1      // Crown
    case chokmah = 2     // Wisdom
    case binah = 3       // Understanding
    case chesed = 4      // Mercy
    case geburah = 5     // Severity
    case tiphareth = 6   // Beauty
    case netzach = 7     // Victory
    case hod = 8         // Splendor
    case yesod = 9       // Foundation
    case malkuth = 10    // Kingdom
    
    var name: String { /* ... */ }
    var hebrewName: String { /* ... */ }
    var color: Color { /* ... */ }
    var planet: Planet { /* ... */ }
    var metal: Metal { /* ... */ }
}

enum HebrewLetter: String, CaseIterable {
    case aleph = "א"
    case bet = "ב"
    // ... all 22 letters
    
    var gematria: Int { /* ... */ }
    var path: Path { /* ... */ }
    var element: Element? { /* ... */ }
    var planet: Planet? { /* ... */ }
    var tarotCard: TarotCard { /* ... */ }
}

struct Path {
    let number: Int  // 11-32
    let letter: HebrewLetter
    let from: Sephira
    let to: Sephira
    let meaning: String
    let meditation: Meditation
}

enum FourWorlds: String {
    case atzilut = "Emanation"
    case briah = "Creation"
    case yetzirah = "Formation"
    case assiah = "Action"
    
    var sephirot: [Sephira] { /* ... */ }
    var quality: String { /* ... */ }
}

// MARK: - User Data Models

struct PersonalTree {
    let userId: UUID
    let dominantSephira: Sephira
    let sephiraStrengths: [Sephira: Double]  // 0.0 - 1.0
    let activePaths: [Path]
    let fourWorldsDistribution: [FourWorlds: Double]
    let calculatedAt: Date
}

struct DailyFocus {
    let date: Date
    let primarySephira: Sephira
    let secondarySephira: [Sephira]
    let activePaths: [Path]
    let dominantWorld: FourWorlds
    let guidance: String
    let practices: [Practice]
    let affirmation: String
}

struct Meditation {
    let id: UUID
    let title: String
    let path: Path?
    let sephira: Sephira?
    let duration: TimeInterval
    let audioURL: URL?
    let script: String
    let difficulty: Difficulty
}
```

---

## Content Assets Required

### Audio
- 22 Path working meditations (15-20 min each)
- 10 Sephira attunement meditations (10 min each)
- Hebrew letter pronunciation guide
- Background ambient tracks

### Visual
- Tree of Life diagram (SVG/SceneKit)
- Sephira symbols/colors
- Hebrew letter calligraphy
- Path visualization animations
- Meditation background videos

### Text
- Sephira descriptions (500 words each)
- Path interpretations (300 words each)
- Hebrew letter deep dives (400 words each)
- Daily guidance templates
- Affirmation library (100+ entries)

---

## API/External Integration

### Hebrew Calendar
- Hebrew date conversion for spiritual cycle calculations
- Holiday awareness for special practices
- Parasha (weekly Torah portion) connections

### Moon Phases
- Lunar cycle influence on Yesod
- New/Full moon ritual suggestions
- Monthly energy forecasts

---

## Settings & Customization

```swift
struct KabbalahSettings {
    var showHebrewNames: Bool = true
    var treeVisualization: TreeStyle = .threeD
    var meditationAudioEnabled: Bool = true
    var dailyFocusNotifications: Bool = true
    var notificationTime: Date = Date(hour: 7, minute: 0)
    var pathWorkingReminder: Bool = true
    var hebrewCalendarIntegration: Bool = false
    var advancedCorrespondences: Bool = false
}
```

---

## Future Enhancements

1. **Advanced Path Working**: Virtual reality Tree of Life exploration
2. **Community Features**: Share path experiences anonymously
3. **Expert Content**: Guest teachers for specific paths
4. **Ritual Integration**: Step-by-step ritual guides
5. **Divination**: Tree of Life-based oracle readings
6. **Study Mode**: Structured Kabbalah learning curriculum

---

*Document Version: 1.0*
*Last Updated: March 2025*
