# QodeX Tarot Module — Technical Specification

## Overview

The Tarot Module brings the ancient art of cartomancy to QodeX, offering users a complete digital tarot experience. With 78 cards, multiple spreads, and deep integration with numerology and astrology, this module provides profound divination insights personalized to each user.

**Module Status**: Planned for V3.3 (Post-launch)
**Complexity**: Very High (requires extensive content + AI interpretation)
**Dependencies**: Core Numerology, Astrology Module, User Profile, Notifications

---

## Core Concepts

### The Tarot Deck Structure

#### Major Arcana (22 Cards)

The soul's journey from ignorance to enlightenment.

| # | Card | Hebrew Letter | Element | Keywords |
|---|------|---------------|---------|----------|
| 0 | The Fool | Aleph | Air | Beginnings, innocence, spontaneity |
| I | The Magician | Beth | Mercury | Manifestation, resourcefulness, power |
| II | The High Priestess | Gimel | Moon | Intuition, unconscious, mystery |
| III | The Empress | Daleth | Venus | Fertility, nurturing, abundance |
| IV | The Emperor | He | Aries | Authority, structure, father figure |
| V | The Hierophant | Vau | Taurus | Tradition, conformity, spirituality |
| VI | The Lovers | Zain | Gemini | Love, harmony, choices |
| VII | The Chariot | Cheth | Cancer | Control, willpower, victory |
| VIII | Strength | Teth | Leo | Courage, persuasion, influence |
| IX | The Hermit | Yod | Virgo | Soul-searching, introspection, guidance |
| X | Wheel of Fortune | Kaph | Jupiter | Luck, karma, cycles |
| XI | Justice | Lamed | Libra | Fairness, truth, law |
| XII | The Hanged Man | Mem | Water | Pause, surrender, new perspective |
| XIII | Death | Nun | Scorpio | Endings, transformation, transition |
| XIV | Temperance | Samech | Sagittarius | Balance, moderation, patience |
| XV | The Devil | Ayin | Capricorn | Bondage, materialism, addiction |
| XVI | The Tower | Pe | Mars | Sudden change, upheaval, awakening |
| XVII | The Star | Tzaddi | Aquarius | Hope, faith, purpose |
| XVIII | The Moon | Qoph | Pisces | Illusion, fear, anxiety |
| XIX | The Sun | Resh | Sun | Positivity, fun, warmth |
| XX | Judgement | Shin | Fire | Judgement, rebirth, inner calling |
| XXI | The World | Tau | Saturn | Completion, integration, accomplishment |

#### Minor Arcana (56 Cards)

**Four Suits**: Everyday situations and practical guidance

| Suit | Element | Season | Direction | Color | Domain |
|------|---------|--------|-----------|-------|--------|
| Wands | Fire | Spring | South | Red/Yellow | Creativity, passion, career |
| Cups | Water | Summer | West | Blue | Emotions, relationships, intuition |
| Swords | Air | Autumn | East | Gray/White | Intellect, conflict, decisions |
| Pentacles | Earth | Winter | North | Green/Brown | Money, health, material world |

**Card Hierarchy** (per suit):

| Rank | Title | Meaning |
|------|-------|---------|
| Ace | Root of [Element] | New beginning, potential |
| 2 | Dominion/Union | Balance, partnership |
| 3 | Virtue/Abundance | Growth, collaboration |
| 4 | Completion/Foundation | Stability, rest |
| 5 | Strife/Loss | Conflict, challenge |
| 6 | Victory/Success | Triumph, recognition |
| 7 | Valor/Deception | Perseverance, strategy |
| 8 | Swiftness/Indolence | Movement, speed |
| 9 | Strength/Gain | Resilience, near-completion |
| 10 | Oppression/Wealth | Burden, culmination |
| Page | Messenger | New ideas, beginnings |
| Knight | Action | Pursuit, adventure |
| Queen | Mastery | Nurturing, embodiment |
| King | Authority | Leadership, command |

### Numerology in Tarot

| Number | Tarot Significance | Numerology Correspondence |
|--------|-------------------|---------------------------|
| 1 | New beginnings, potential | Independence, leadership |
| 2 | Duality, balance | Cooperation, harmony |
| 3 | Growth, expression | Creativity, joy |
| 4 | Stability, foundation | Order, discipline |
| 5 | Change, conflict | Freedom, adaptability |
| 6 | Harmony, restoration | Responsibility, service |
| 7 | Reflection, assessment | Analysis, spirituality |
| 8 | Movement, power | Ambition, abundance |
| 9 | Completion, attainment | Wisdom, compassion |
| 10 | End of cycle, renewal | Completion, new beginnings |

---

## Feature Specifications

### 1. Full Card Library

#### 1.1 Card Browser

**Layout Options**:
- **Grid View**: 3-column scrollable grid (thumbnail + name)
- **Suit View**: Horizontal tabs for each suit + Major Arcana
- **Numerology View**: Grouped by card number (all Aces, all 2s, etc.)
- **Element View**: Fire/Water/Air/Earth/Major grouping

**Card Thumbnail**:
```
┌─────────────┐
│   [Art]     │
│  120x200pt  │
│             │
│ The Fool    │
│ 0 • Major   │
└─────────────┘
```

#### 1.2 Card Detail View

**Sections** (scrollable):

```
┌─────────────────────────────────┐
│  ← The Fool                     │
│                                 │
│     [Full Card Art]             │
│       280x480pt                 │
│                                 │
│  THE FOOL                       │
│  0 • Major Arcana • Air         │
│  Letter: Aleph • Path: 11       │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  KEYWORDS                       │
│  Beginnings • Innocence         │
│  Spontaneity • Free Spirit      │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  UPRIGHT MEANING                │
│  [Detailed interpretation...]   │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  REVERSED MEANING               │
│  [Reversed interpretation...]   │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  NUMEROLOGY CONNECTION          │
│  Resonates with Life Path 1     │
│  [Learn more →]                 │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  ASTROLOGICAL CORRESPONDENCE    │
│  Ruled by: Uranus               │
│  Current Transit: Square to     │
│  your natal Sun                 │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  SYMBOLISM                      │
│  • White rose: Purity           │
│  • Cliff edge: Risk             │
│  • Dog: Loyalty/Warning         │
│  • Bundle: Untapped potential   │
│                                 │
│  [Previous]        [Next]       │
└─────────────────────────────────┘
```

#### 1.3 Card Search & Filter

**Search Capabilities**:
- Card name
- Keyword
- Meaning text
- Symbol element (e.g., "search: dog")
- Numerology number
- Astrological correspondence

**Filter Options**:
- Major/Minor Arcana
- Suit (Wands/Cups/Swords/Pentacles)
- Element (Fire/Water/Air/Earth)
- Number (1-10, Page, Knight, Queen, King)
- Reversals (cards you've drawn reversed most)

### 2. Daily Card Draw

#### 2.1 Draw Experience

**Animation Flow**:
1. User taps "Draw Today's Card"
2. Deck shuffles (animated)
3. Cards fan out
4. User intuitively selects (or auto-selects after 5s)
5. Card flips with 3D rotation
6. Card slides up to full view

**Haptic Sequence**:
- Shuffle: Light, rapid taps
- Selection: Medium impact
- Reveal: Strong impact + success haptic

#### 2.2 Personal Context Integration

**Context Factors**:
```swift
struct DrawContext {
    let userLifePath: Int
    let personalYear: Int
    let personalMonth: Int
    let personalDay: Int
    let currentTransits: [Transit]
    let lastDraw: DailyDraw?
    let recentCards: [Card] // Last 7 days
    let userIntention: String? // Optional input
}

func contextualInterpretation(card: Card, context: DrawContext) -> Interpretation {
    // Modify base meaning based on:
    // 1. Life Path resonance
    // 2. Current numerology cycle
    // 3. Astrological transits
    // 4. Avoid recent repeats
    // 5. User intention keywords
}
```

#### 2.3 Daily Card Result Screen

```
┌─────────────────────────────────┐
│  Today's Card • March 11, 2026  │
│                                 │
│     [Card Art - Revealed]       │
│                                 │
│  THE CHARIOT                    │
│  VII • Major Arcana             │
│                                 │
│  "Victory through determination │
│   and willpower"                │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  FOR YOU (Life Path 7)          │
│                                 │
│  As a seeker of truth, today    │
│  brings an opportunity to       │
│  direct your analytical energy  │
│  toward a specific goal. Your   │
│  Personal Day 3 adds creative   │
│  momentum to this Chariot       │
│  energy.                        │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  AFFIRMATION                    │
│  "I move forward with clarity   │
│   and confidence."              │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  JOURNAL PROMPT                 │
│  What goal requires your full   │
│  focus and determination today? │
│                                 │
│  [Save to Journal]  [Share]     │
│                                 │
│  [See Full Meaning]  [Another]  │
└─────────────────────────────────┘
```

### 3. Tarot Spreads

#### 3.1 Spread Library

| Spread | Cards | Best For | Time |
|--------|-------|----------|------|
| Single Card | 1 | Daily guidance, quick answers | 2 min |
| Three Card | 3 | Past/Present/Future or Situation/Action/Outcome | 5 min |
| Celtic Cross | 10 | Deep insight, complex situations | 15 min |
| Relationship | 7 | Love/Partnership dynamics | 10 min |
| Career Path | 5 | Work/professional decisions | 8 min |
| Life Path | 6 | Alignment with numerology | 10 min |
| Chakra Spread | 7 | Energy center assessment | 12 min |
| Year Ahead | 12 | Monthly forecast | 20 min |
| Decision | 4 | Choice A vs Choice B | 6 min |
| Soul Purpose | 5 | Life mission/Calling | 10 min |

#### 3.2 Spread Layout Specifications

**Three Card Spread**:
```
┌─────────────────────────────────────────┐
│                                         │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐│
│   │         │  │         │  │         ││
│   │  Past   │  │ Present │  │ Future  ││
│   │         │  │         │  │         ││
│   └─────────┘  └─────────┘  └─────────┘│
│                                         │
│   Or: Situation / Action / Outcome      │
│   Or: Mind / Body / Spirit              │
│   Or: You / Other / Outcome             │
│                                         │
└─────────────────────────────────────────┘
```

**Celtic Cross Spread** (10 positions):
```
┌─────────────────────────────────────────┐
│                                         │
│              ┌─────────┐                │
│              │    2    │                │
│              │  ↑↓ 1   │                │
│              │    3    │                │
│              └─────────┘                │
│                                         │
│   ┌─────────┐              ┌─────────┐  │
│   │    4    │              │    5    │  │
│   └─────────┘              └─────────┘  │
│                                         │
│   ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│   │    6    │ │    7    │ │    8    │  │
│   └─────────┘ └─────────┘ └─────────┘  │
│                                         │
│   ┌─────────┐ ┌─────────┐              │
│   │    9    │ │   10    │              │
│   └─────────┘ └─────────┘              │
│                                         │
└─────────────────────────────────────────┘

Positions:
1. Present situation (center, crossing)
2. Challenge/Opposition (crossing #1)
3. Foundation (below)
4. Past (left)
5. Crown/Goal (above)
6. Future (right)
7. Self (bottom row left)
8. Environment (bottom row center)
9. Hopes/Fears (bottom row right)
10. Outcome (far right)
```

#### 3.3 Spread Reading Flow

1. **Selection**: User chooses spread type
2. **Intention**: Optional text input for focus
3. **Shuffle**: Animated deck shuffling
4. **Placement**: Cards dealt to positions (animated)
5. **Reveal**: User taps each card to flip
6. **Interpretation**: Position-by-position reading
7. **Synthesis**: Overall spread meaning
8. **Save**: Option to save reading to journal

### 4. Card-of-the-Day Notifications

#### 4.1 Notification Content

**Morning Notification** (7:00 AM default):
```
🔮 Your Daily Tarot Card

The High Priestess appeared for you today.

"Trust your intuition. Answers lie within."

Tap to see your full reading →
```

**Evening Reflection** (8:00 PM optional):
```
🌙 Daily Card Reflection

How did The High Priestess energy
show up in your day?

[Journal about it] →
```

#### 4.2 Smart Timing

**Algorithm**:
```swift
func optimalNotificationTime(for user: User) -> Date {
    // Consider:
    // 1. User's typical app open time
    // 2. Wake time (if HealthKit connected)
    // 3. Daily routine patterns
    // 4. Timezone
    // 5. Weekend vs weekday patterns
}
```

### 5. Tarot + Numerology Integration

#### 5.1 Life Path Card Affinities

| Life Path | Affinity Cards | Why |
|-----------|----------------|-----|
| 1 | Magician, Sun, Ace of Wands | Leadership, new beginnings |
| 2 | High Priestess, Lovers, 2 of Cups | Intuition, partnership |
| 3 | Empress, 3 of Pentacles | Creativity, expression |
| 4 | Emperor, 4 of Wands | Structure, foundation |
| 5 | Hierophant, 5 of Swords | Change, learning |
| 6 | Lovers, 6 of Cups | Harmony, love |
| 7 | Chariot, Hermit, 7 of Pentacles | Spirituality, seeking |
| 8 | Strength, 8 of Pentacles | Power, mastery |
| 9 | Hermit, 9 of Cups | Wisdom, completion |
| 11 | Justice, Star | Illumination, balance |
| 22 | Fool, World | Mastery of potential |
| 33 | Empress, Sun | Compassionate leadership |

#### 5.2 Birth Cards (Major Arcana)

**Calculation**:
```swift
func birthCards(for birthDate: Date) -> (Card, Card?) {
    let components = Calendar.current.dateComponents([.month, .day], from: birthDate)
    let month = components.month!
    let day = components.day!
    
    // Method 1: Month + Day
    var sum = month + day
    if sum > 22 { sum = reduceTo22(sum) }
    let firstCard = majorArcana[sum]
    
    // Method 2: Full reduction
    let secondSum = reduceNumerology(sum)
    let secondCard = secondSum != sum ? majorArcana[secondSum] : nil
    
    return (firstCard, secondCard)
}

// Example: March 11 → 3 + 11 = 14 (Temperance)
//          1 + 4 = 5 (Hierophant)
// Birth Cards: Temperance + Hierophant
```

#### 5.3 Personal Year Card

```swift
func personalYearCard(for date: Date, birthDate: Date) -> Card {
    let year = Calendar.current.component(.year, from: date)
    let personalYear = calculatePersonalYear(year, birthDate)
    let reduced = personalYear > 22 ? reduceTo22(personalYear) : personalYear
    return majorArcana[reduced]
}
```

### 6. Tarot + Astrology Integration

#### 6.1 Transit-Based Card Recommendations

**Algorithm**:
```swift
func transitInfluencedCards(for user: User, date: Date) -> [CardRecommendation] {
    let transits = AstrologyEngine.currentTransits(for: user.natalChart, date: date)
    var recommendations: [CardRecommendation] = []
    
    for transit in transits {
        // Find cards ruled by or associated with transit planets/signs
        let associatedCards = cardsForTransit(transit)
        recommendations.append(contentsOf: associatedCards)
    }
    
    return recommendations.sorted(by: \.relevanceScore)
}
```

**Example**: Saturn conjunct natal Sun
- Saturn rules: World, Devil, Hermit
- Sun rules: Sun
- Recommended cards: World (completion), Devil (limitations), Sun (vitality)

#### 6.2 Astrological Spread

**Layout**: 12 houses of the zodiac + 1 center card

| Position | House | Meaning |
|----------|-------|---------|
| Center | Self | Core theme |
| 1 | 1st House | Self, appearance |
| 2 | 2nd House | Values, money |
| 3 | 3rd House | Communication |
| 4 | 4th House | Home, roots |
| 5 | 5th House | Creativity, romance |
| 6 | 6th House | Health, service |
| 7 | 7th House | Partnerships |
| 8 | 8th House | Transformation |
| 9 | 9th House | Philosophy, travel |
| 10 | 10th House | Career |
| 11 | 11th House | Community |
| 12 | 12th House | Secrets, subconscious |

### 7. Learning Mode

#### 7.1 Study Deck

**Features**:
- Flashcard-style learning
- Spaced repetition algorithm
- Progress tracking
- Quiz mode
- Symbol library

**Study Modes**:
1. **Name Recognition**: See art, name the card
2. **Meaning Recall**: See card, recall meanings
3. **Reverse Learning**: See meaning, identify card
4. **Symbol Study**: Learn individual symbols
5. **Quiz**: Multiple choice, fill-in-blank

#### 7.2 Card Comparison Tool

Compare two cards side-by-side:
- Visual comparison
- Keyword overlap
- Elemental affinity
- Numerological connection
- Astrological rulers

#### 7.3 Learning Path

**Beginner Path** (14 days):
- Day 1-7: Major Arcana (3 cards/day)
- Day 8-11: Court Cards (4 ranks/day)
- Day 12-14: Minor Arcana by suit

**Intermediate Path** (30 days):
- Week 1: Major Arcana deep dive
- Week 2: Minor Arcana meanings
- Week 3: Reversals
- Week 4: Combinations

**Advanced Path** (Ongoing):
- Symbol deep dives
- Historical decks
- Reading techniques
- Intuitive development

---

## Data Models

```swift
// MARK: - Tarot Card
struct TarotCard: Codable, Identifiable {
    let id: String // fool, magician, ace-of-wands, etc.
    let number: Int? // 0-21 for Major, 1-10 for Minor
    let rank: CardRank? // ace, two...ten, page, knight, queen, king
    let suit: Suit? // wands, cups, swords, pentacles
    let arcana: Arcana // major or minor
    let element: Element?
    let astrology: AstrologicalCorrespondence?
    let hebrewLetter: HebrewLetter?
    let treeOfLifePath: Int? // 11-32
    
    // Content
    let name: String
    let keywords: [String]
    let keywordsReversed: [String]
    let descriptionUpright: String
    let descriptionReversed: String
    let symbolism: [Symbol]
    let advice: String
    let adviceReversed: String
    
    // Assets
    let artwork: ImageAsset // Multiple deck support
    let thumbnail: ImageAsset
}

enum Arcana: String, Codable {
    case major
    case minor
}

enum Suit: String, Codable, CaseIterable {
    case wands = "Wands"
    case cups = "Cups"
    case swords = "Swords"
    case pentacles = "Pentacles"
    
    var element: Element {
        switch self {
        case .wands: return .fire
        case .cups: return .water
        case .swords: return .air
        case .pentacles: return .earth
        }
    }
}

enum CardRank: String, Codable {
    case ace, two, three, four, five
    case six, seven, eight, nine, ten
    case page, knight, queen, king
}

struct Symbol: Codable {
    let name: String
    let meaning: String
    let position: String // "top left", "center", etc.
}

// MARK: - Tarot Spread
struct TarotSpread: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let numberOfCards: Int
    let positions: [SpreadPosition]
    let recommendedFor: [String] // intentions
    let difficulty: Difficulty
    let estimatedTime: TimeInterval
}

struct SpreadPosition: Codable {
    let index: Int
    let name: String
    let meaning: String
    let x: Double // 0-1 position in layout
    let y: Double // 0-1 position in layout
    let rotation: Double // degrees
}

// MARK: - Tarot Reading
struct TarotReading: Codable, Identifiable {
    let id: String
    let userId: String
    let createdAt: Date
    let spread: TarotSpread
    let intention: String?
    let cards: [DrawnCard]
    let interpretation: Interpretation?
    let isSaved: Bool
    let tags: [String]
}

struct DrawnCard: Codable {
    let card: TarotCard
    let position: SpreadPosition
    let isReversed: Bool
    let timestamp: Date
}

struct Interpretation: Codable {
    let positionMeanings: [PositionInterpretation]
    let overall: String
    let advice: String
    let numerologyConnection: String?
    let astrologyConnection: String?
}

struct PositionInterpretation: Codable {
    let position: SpreadPosition
    let meaning: String
    let keywords: [String]
}

// MARK: - Daily Draw
struct DailyDraw: Codable, Identifiable {
    let id: String
    let userId: String
    let date: Date
    let card: TarotCard
    let isReversed: Bool
    let context: DrawContext
    let personalInterpretation: String
    let userReflection: String?
    let isJournalSaved: Bool
}

struct DrawContext: Codable {
    let lifePathNumber: Int
    let personalYear: Int
    let personalMonth: Int
    let personalDay: Int
    let currentTransits: [TransitSummary]
    let recentCards: [String] // Card IDs from last 7 days
}

// MARK: - Birth Cards
struct BirthCards: Codable {
    let personalityCard: TarotCard // First card
    let soulCard: TarotCard? // Second card (if different)
    let shadowCard: TarotCard? // 21 - personality number
    let yearCard: TarotCard? // Current personal year
}
```

---

## Integration Points

### With Numerology Module

| Integration | Description |
|-------------|-------------|
| Life Path Affinity | Highlight cards matching user's Life Path |
| Birth Cards | Calculate and display personal Major Arcana |
| Personal Year Card | Annual tarot theme |
| Daily Context | Numerology influences card interpretation |
| Compatibility | Compare birth cards between users |
| Forecasts | Tarot + numerology combined predictions |

### With Astrology Module

| Integration | Description |
|-------------|-------------|
| Transit Cards | Recommend cards based on current transits |
| Astrological Spread | 12-house spread using natal chart |
| Planetary Rulership | Cards organized by ruling planet |
| Moon Phase | Void moon warnings for readings |
| Retrograde | Special guidance during Mercury Rx |
| Electional Tarot | Best timing for specific questions |

### With Journal Module

| Integration | Description |
|-------------|-------------|
| Reading Log | Auto-save readings to journal |
| Reflection Prompts | Daily card journal prompts |
| Pattern Tracking | Notice recurring cards over time |
| Intentions | Pull journal intentions into readings |
| Insights | AI analysis of reading patterns |

### With Community

| Integration | Description |
|-------------|-------------|
| Share Readings | Post readings (card positions visible) |
| Group Spreads | Collective readings for events |
| Card Discussions | Thread per card |
| Reader Directory | Find community readers |
| Reading Exchange | Trade readings with peers |

### Subscription Tiers

| Feature | Free | Inner Circle | Initiate | Master |
|---------|------|--------------|----------|--------|
| Daily Draw | ✅ | ✅ | ✅ | ✅ |
| Card Library | 22 Major only | All 78 | All 78 | All 78 |
| Spreads | 3-Card only | 5 spreads | 10 spreads | All spreads |
| Saved Readings | 3 | Unlimited | Unlimited | Unlimited |
| Numerology Link | Basic | Full | Full | Full |
| Astrology Link | ❌ | Basic | Full | Full |
| AI Interpretation | ❌ | ✅ | ✅ | ✅ |
| Learning Mode | Limited | Full | Full | Full |
| Custom Spreads | ❌ | ❌ | ✅ | ✅ |
| Multiple Decks | ❌ | 2 decks | 5 decks | All decks |
| Reading History | 7 days | 90 days | 1 year | Forever |

---

## Content Structure

### Content Inventory

| Content Type | Count | Format | Source |
|--------------|-------|--------|--------|
| Card Meanings | 156 (78 × 2) | Rich text | Shani-written |
| Keywords | ~500 | Text array | Shani-curated |
| Artwork | 78+ images | PNG/SVG | Artist commission |
| Symbol Descriptions | ~200 | Text | Research + Shani |
| Spread Instructions | 10+ | Rich text | Shani-written |
| Guided Interpretations | 78+ | Template + AI | Dynamic |
| Audio Guides | 78+ | MP3 | Shani-recorded |
| Learning Content | 50+ lessons | Mixed | Course content |

### Artwork Requirements

**Deck Style**: Custom QodeX Tarot
- Mystical yet modern aesthetic
- Consistent with app design (dark, gold accents)
- Diverse representation in figures
- Symbol-rich imagery

**Technical Specs**:
- Resolution: 1200 x 2000px (portrait)
- Format: PNG with transparency
- Color space: sRGB
- Style: Digital illustration, slightly painterly

---

## Technical Requirements

### Frameworks

| Framework | Purpose |
|-----------|---------|
| Core Animation | Card animations, 3D flips |
| UIKit | Spread layouts |
| SwiftUI | Card browser, detail views |
| Core ML | AI interpretation (optional) |
| AVFoundation | Audio playback |

### Card Animation Specs

| Animation | Duration | Easing |
|-----------|----------|--------|
| Shuffle | 1.5s | EaseInOut |
| Deal | 0.3s per card | EaseOut |
| Flip (3D) | 0.4s | EaseInOut |
| Hover | 0.2s | EaseOut |
| Selection | 0.15s | Spring |

### Performance Targets

| Metric | Target |
|--------|--------|
| Card Load | < 100ms |
| Spread Setup | < 2s |
| Animation FPS | 60fps |
| Library Scroll | 60fps |
| Search Response | < 300ms |

### Storage

| Asset Type | Size | CDN |
|------------|------|-----|
| Card Art (78 cards) | 50MB | Required |
| Thumbnails | 5MB | Bundle |
| Audio Files | 100MB | Required |
| Text Content | 2MB | Bundle |

---

## UI/UX Specifications

### Navigation

```
Tarot (Tab)
├── Draw (Default)
│   ├── Daily Card
│   ├── Quick Draw
│   └── Focused Reading
├── Library
│   ├── All Cards
│   ├── Major Arcana
│   ├── Minor Arcana
│   └── Search
├── Spreads
│   ├── My Spreads
│   ├── Browse
│   └── Custom Builder
├── History
│   ├── Saved Readings
│   ├── Statistics
│   └── Patterns
└── Learn
    ├── Study Deck
    ├── Birth Cards
    └── Courses
```

### Color Coding by Suit

| Suit | Primary | Secondary | Glow |
|------|---------|-----------|------|
| Wands | #FF6B35 | #FFB347 | Orange |
| Cups | #4A90E2 | #87CEEB | Blue |
| Swords | #E0E0E0 | #B0B0B0 | Silver |
| Pentacles | #228B22 | #90EE90 | Green |
| Major | #D4AF37 | #FFE5A0 | Gold |

### Accessibility

- **VoiceOver**: Full labels for all cards
- **Dynamic Type**: Scalable up to 310%
- **Reduce Motion**: Static card reveals
- **Color Blind**: Pattern differentiation
- **Switch Control**: Full navigation support

---

## Success Metrics

### Engagement

| Metric | Target |
|--------|--------|
| Daily Draw Completion | 35% of users |
| Spread Usage | 2 per week per user |
| Card Library Browse | 5 min avg session |
| Learning Mode Usage | 20% of users |
| Saved Readings | 3 per user/week |

### Retention

| Metric | Target |
|--------|--------|
| 7-Day Retention | 55% |
| 30-Day Retention | 40% |
| Daily Streak (7+) | 20% |

### Business

| Metric | Target |
|--------|--------|
| Premium Conversion | 12% |
| Spread Completion | 80% |
| Social Shares | 1 per 10 readings |

---

**Document Version**: 1.0
**Last Updated**: March 2026
**Author**: QodeX Product Team
