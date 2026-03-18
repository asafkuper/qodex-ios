# QodeX Playing Cards (Cartomancy) Module — Technical Specification

## Overview

The Playing Cards Module brings the practical, accessible art of cartomancy to QodeX. Using a standard 52-card deck (no Major Arcana), this module offers quick, grounded readings focused on everyday situations. Playing card divination predates tarot and provides faster, more direct insights perfect for daily guidance.

**Module Status**: Planned for V3.4 (Post-launch)
**Complexity**: Medium (simpler than tarot, extensive content)
**Dependencies**: Core Numerology, User Profile, Social Features

---

## Core Concepts

### The Playing Card Deck

**52 Cards**: No Jokers (optional expansion)

#### Four Suits

| Suit | Symbol | Element | Season | Time | Color | Domain |
|------|--------|---------|--------|------|-------|--------|
| Hearts ♥ | ♥ | Water | Spring | Morning | Red | Emotions, love, relationships, family |
| Diamonds ♦ | ♦ | Earth | Summer | Afternoon | Red | Money, career, values, practicality |
| Clubs ♣ | ♣ | Fire | Autumn | Evening | Black | Work, creativity, growth, ambition |
| Spades ♠ | ♠ | Air | Winter | Night | Black | Challenges, intellect, endings, truth |

#### Card Hierarchy

**Number Cards (2-10)**:
- Represent situations, energies, and practical matters
- Combine suit meaning with numerology
- Even numbers = stability, balance
- Odd numbers = change, action

**Court Cards (J, Q, K)**:
- Represent people or personality aspects
- Can also represent situations requiring those qualities

| Rank | Playing Card | Represents | Qualities |
|------|-------------|------------|-----------|
| Jack (J) | Young person | Messenger, beginner, student | Youthful, enthusiastic, learning |
| Queen (Q) | Mature feminine | Nurturer, master, insider | Experienced, supportive, influential |
| King (K) | Mature masculine | Authority, leader, expert | Powerful, established, commanding |

**Ace (A)**:
- Root of the suit
- New beginnings, pure potential
- Strongest card in each suit

### Numerology in Playing Cards

| Card | Meaning | Life Path Connection |
|------|---------|---------------------|
| Ace (1) | New beginning, opportunity, gift | All 1s, 10s, 19s, 28s |
| 2 | Partnership, balance, choice | All 2s, 11s, 20s, 29s |
| 3 | Growth, creativity, expression | All 3s, 12s, 21s, 30s |
| 4 | Stability, foundation, rest | All 4s, 13s, 22s, 31s |
| 5 | Change, conflict, adventure | All 5s, 14s, 23s |
| 6 | Harmony, responsibility, love | All 6s, 15s, 24s |
| 7 | Assessment, spirituality, luck | All 7s, 16s, 25s |
| 8 | Power, movement, success | All 8s, 17s, 26s |
| 9 | Completion, wisdom, letting go | All 9s, 18s, 27s |
| 10 | End of cycle, culmination | All endings, mastery |

### Court Card Personalities

| Card | Person Type | When representing the Querent | Keywords |
|------|-------------|-------------------------------|----------|
| J♥ | Young emotional person | You seek love/connection | Romantic, sensitive, dreamer |
| Q♥ | Nurturing woman | You nurture others | Loving, supportive, intuitive |
| K♥ | Emotional authority | You lead with heart | Compassionate, protective, warm |
| J♦ | Young ambitious person | You pursue success | Enterprising, practical, eager |
| Q♦ | Businesswoman | You manage resources | Savvy, organized, valuable |
| K♦ | Financial leader | You command wealth | Successful, established, generous |
| J♣ | Creative youth | You start new projects | Inspired, active, curious |
| Q♣ | Creative woman | You cultivate growth | Productive, helpful, wise |
| K♣ | Creative authority | You command work | Accomplished, professional, strong |
| J♠ | Young truth-seeker | You face challenges | Honest, direct, brave |
| Q♠ | Independent woman | You speak truth | Perceptive, honest, resilient |
| K♠ | Authority on truth | You command respect | Powerful, intellectual, final |

---

## Feature Specifications

### 1. 52-Card Library

#### 1.1 Card Browser

**Layout Options**:
- **Grid View**: 4 suits as tabs, cards in suit order
- **Quick Find**: Search by name, meaning, or number
- **Numerology View**: All cards grouped by number (all 7s together)
- **Court View**: Just the 12 court cards

**Card Display**:
```
┌─────────────────────────────────┐
│  ♥ HEARTS                       │
│                                 │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐   │
│  │A ♥ │ │2 ♥ │ │3 ♥ │ │4 ♥ │   │
│  │    │ │    │ │    │ │    │   │
│  └────┘ └────┘ └────┘ └────┘   │
│                                 │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐   │
│  │5 ♥ │ │6 ♥ │ │7 ♥ │ │8 ♥ │   │
│  │    │ │    │ │    │ │    │   │
│  └────┘ └────┘ └────┘ └────┘   │
│                                 │
│  [J ♥] [Q ♥] [K ♥]             │
│                                 │
└─────────────────────────────────┘
```

#### 1.2 Card Detail View

```
┌─────────────────────────────────┐
│  ← Ace of Hearts                │
│                                 │
│        ┌─────────┐              │
│        │    ♥    │              │
│        │   A     │              │
│        │  BIG    │              │
│        │   ♥     │              │
│        │         │              │
│        └─────────┘              │
│                                 │
│  ACE OF HEARTS ♥                │
│  Water • Spring • Morning       │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  KEY MEANINGS                   │
│                                 │
│  💕 Love & New Relationships    │
│  🎁 A Gift or Blessing          │
│  🏠 Home & Family Matters       │
│  💧 Emotional New Beginning     │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  DETAILED INTERPRETATION        │
│                                 │
│  The Ace of Hearts heralds a    │
│  new emotional experience.      │
│  This could be the beginning    │
│  of a relationship, a new       │
│  phase in family life, or a     │
│  fresh emotional start.         │
│                                 │
│  In readings, this card         │
│  suggests love is coming or     │
│  an existing bond will deepen.  │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  IN DIFFERENT CONTEXTS          │
│                                 │
│  💼 Career: New job you'll love │
│  💰 Money: Unexpected gift      │
│  ❤️ Love: New relationship      │
│  🏥 Health: Emotional healing   │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  NUMEROLOGY LINK                │
│  Resonates with Life Path 1     │
│  Personal Year 1                │
│  [See Your Numbers →]           │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  RELATED CARDS                  │
│  [2♥] [K♥] [A♦]                │
│                                 │
│  [Previous]        [Next]       │
└─────────────────────────────────┘
```

### 2. Quick Daily Draws

#### 2.1 Single Card Draw

**Use Cases**:
- Daily guidance
- Yes/no questions
- Quick decision help
- Mood check

**Animation**:
1. Deck shuffles (simpler than tarot)
2. Fan out (5 cards visible)
3. User picks one (or auto-select)
4. Card slides forward and flips
5. Result displays with context

**Result Screen**:
```
┌─────────────────────────────────┐
│  Your Card • March 11, 2026     │
│                                 │
│        ┌─────────┐              │
│        │    ♦    │              │
│        │    7    │              │
│        │   ♦     │              │
│        │  BIG    │              │
│        │   ♦     │              │
│        └─────────┘              │
│                                 │
│  SEVEN OF DIAMONDS              │
│                                 │
│  "A small win or lucky break    │
│   is coming your way"           │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  FOR YOUR LIFE PATH 7           │
│                                 │
│  Your analytical nature meets   │
│  opportunity today. This 7      │
│  resonates with your Life Path  │
│  - trust your assessment of     │
│  this unexpected gain.          │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  ACTION STEP                    │
│  Stay alert for unexpected      │
│  financial or career            │
│  opportunities. Your sharp      │
│  eye will spot what others      │
│  miss.                          │
│                                 │
│  [Save] [Share] [Journal]       │
└─────────────────────────────────┘
```

#### 2.2 Three Card Draw

**Spread Options**:

| Layout | Position 1 | Position 2 | Position 3 |
|--------|-----------|-----------|-----------|
| Time | Past | Present | Future |
| Situation | Problem | Action | Outcome |
| Relationship | You | Connection | Them |
| Decision | Option A | Option B | Advice |
| Mind/Body/Spirit | Thoughts | Actions | Feelings |

**Layout**:
```
┌─────────────────────────────────────────┐
│                                         │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐│
│   │   ♥     │  │   ♠     │  │   ♣     ││
│   │   3     │  │   K     │  │   J     ││
│   │  ♥      │  │  ♠      │  │  ♣      ││
│   └─────────┘  └─────────┘  └─────────┘│
│                                         │
│    Past        Present      Future      │
│   (3♥)         (K♠)         (J♣)        │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                         │
│  READING SYNTHESIS                      │
│                                         │
│  Your emotional foundation (3♥) has     │
│  prepared you for the current truth     │
│  you must face (K♠). A new creative     │
│  beginning (J♣) emerges from this       │
│  honest assessment.                     │
│                                         │
│  Key Message: Growth through truth.     │
│                                         │
└─────────────────────────────────────────┘
```

### 3. Compatibility Readings

#### 3.1 Two-Person Compatibility

**Input**:
- Person A: Name + Birth date
- Person B: Name + Birth date
- Relationship type (optional): Romantic, Friendship, Business, Family

**Calculation**:
```swift
struct CompatibilityReading {
    let personA: PersonCards
    let personB: PersonCards
    let relationshipCards: [PlayingCard]
    let compatibilityScore: Int // 0-100
    let elementalBalance: [Element: Double]
    let strengths: [String]
    let challenges: [String]
    let advice: String
}

func calculateCompatibility(personA: User, personB: User) -> CompatibilityReading {
    // Get birth cards for both
    let cardsA = birthCards(for: personA.birthDate)
    let cardsB = birthCards(for: personB.birthDate)
    
    // Relationship spread: 5 cards
    // 1. Person A's energy
    // 2. Person B's energy
    // 3. Relationship foundation
    // 4. Current dynamic
    // 5. Future potential
    
    // Calculate elemental compatibility
    let balance = calculateElementalBalance(cardsA, cardsB)
    
    // Generate score based on suit affinity
    let score = calculateCompatibilityScore(cardsA, cardsB)
    
    return CompatibilityReading(...)
}
```

**Result Screen**:
```
┌─────────────────────────────────┐
│  Compatibility Reading          │
│  You & Sarah                    │
│                                 │
│        ┌─────────┐              │
│        │ ♥ K ♥   │              │
│        │  78%    │              │
│        │ ♣ Q ♣   │              │
│        └─────────┘              │
│                                 │
│  Your Cards    |  Their Cards   │
│  K♥ King of    |  Q♣ Queen of   │
│     Hearts     |     Clubs      │
│  (Leadership)  |  (Creativity)  │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  ELEMENTAL BALANCE              │
│                                 │
│  ❤️ Hearts    ████████░░  40%   │
│  ♦ Diamonds   ██░░░░░░░░  10%   │
│  ♣ Clubs      █████████░  45%   │
│  ♠ Spades     █░░░░░░░░░   5%   │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  YOUR STRENGTHS                 │
│  • Emotional leadership meets   │
│    creative productivity        │
│  • Heart (you) + Work (them)    │
│    = Balanced partnership       │
│  • Mutual respect for authority │
│                                 │
│  WATCH OUT FOR                  │
│  • Different priorities         │
│    (love vs. achievement)       │
│  • You may seem too intense     │
│  • They may seem too busy       │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  THE RELATIONSHIP SPREAD        │
│                                 │
│  [5 cards in cross pattern]     │
│                                 │
│  Foundation: A♥ (strong love)   │
│  Dynamic:    5♠ (challenges)    │
│  Future:     2♦ (partnership)   │
│                                 │
│  [Full Reading] [Share]         │
└─────────────────────────────────┘
```

#### 3.2 Group Compatibility

For 3-6 people:
- Shows interconnected dynamics
- Identifies natural leaders
- Highlights potential conflicts
- Suggests optimal collaboration roles

### 4. Birthday Card Calculation

#### 4.1 Birth Card Algorithm

**Primary Birth Card**:
```swift
func birthCard(for birthDate: Date) -> PlayingCard {
    let components = Calendar.current.dateComponents([.month, .day], from: birthDate)
    let month = components.month! // 1-12
    let day = components.day!     // 1-31
    
    // Sum month + day
    var sum = month + day
    
    // If > 13, reduce
    while sum > 13 {
        sum = String(sum).compactMap { $0.wholeNumberValue }.reduce(0, +)
    }
    
    // Special case: sum = 13 → King (13)
    // sum = 12 → Queen (12)
    // sum = 11 → Jack (11)
    // 1-10: number cards
    // 0 or reduction to 0: Ace
    
    let rank = sum == 0 ? 1 : sum
    let suit = suitForBirthDate(birthDate)
    
    return PlayingCard(rank: rank, suit: suit)
}

// Alternative: Fixed correspondences
func suitForBirthDate(_ date: Date) -> Suit {
    let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)!
    switch dayOfYear % 4 {
    case 0: return .hearts
    case 1: return .diamonds
    case 2: return .clubs
    case 3: return .spades
    default: return .hearts
    }
}
```

**Birth Card Examples**:

| Birth Date | Calculation | Birth Card | Meaning |
|------------|-------------|------------|---------|
| Jan 1 | 1+1=2 | 2♥ | Emotional balance |
| March 11 | 3+11=14→5 | 5♦ | Financial change |
| July 4 | 7+4=11→J | J♣ | Creative messenger |
| Dec 25 | 12+25=37→10 | 10♠ | Cycle completion |

#### 4.2 Birth Card Profile

**Screen Layout**:
```
┌─────────────────────────────────┐
│  Your Birth Card                │
│                                 │
│        ┌─────────┐              │
│        │    ♦    │              │
│        │    7    │              │
│        │   ♦     │              │
│        │  BIG    │              │
│        │   ♦     │              │
│        └─────────┘              │
│                                 │
│  SEVEN OF DIAMONDS              │
│  Your Core Identity             │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  BIRTH CARD MEANING             │
│                                 │
│  As a Seven of Diamonds, you    │
│  are the assessor of value.     │
│  You have a natural gift for    │
│  evaluating opportunities and   │
│  seeing the true worth in       │
│  people and situations.         │
│                                 │
│  Your Life Path 7 amplifies     │
│  this analytical energy.        │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  YOUR GIFTS                     │
│  • Sharp financial intuition    │
│  • Ability to spot deals        │
│  • Analytical mind              │
│  • Lucky breaks find you        │
│                                 │
│  YOUR CHALLENGES                │
│  • Over-analyzing emotions      │
│  • Material over-focus          │
│  • Restlessness                 │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  FAMOUS 7♦ PEOPLE               │
│  • [Celebrity names]            │
│                                 │
│  [View Full Profile]            │
└─────────────────────────────────┘
```

#### 4.3 Planetary Period Cards

Each year of life has a governing card:

| Age Range | Card | Theme |
|-----------|------|-------|
| 0-13 | Birth Card | Foundation building |
| 14-26 | Mercury Card | Learning, communication |
| 27-39 | Venus Card | Relationships, values |
| 40-52 | Mars Card | Action, career peak |
| 53-65 | Jupiter Card | Expansion, wisdom |
| 66-78 | Saturn Card | Mastery, legacy |
| 79+ | Uranus Card | Liberation, uniqueness |

### 5. 7-Year Life Spread

#### 5.1 The Grand Spread

A comprehensive 28-card spread covering 7 years:

**Layout**: 7 columns (years) × 4 rows (quarters)

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  YEAR 1    YEAR 2    YEAR 3    YEAR 4    YEAR 5    ...     │
│                                                             │
│  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐               │
│  │ Q1  │  │ Q1  │  │ Q1  │  │ Q1  │  │ Q1  │   Theme       │
│  └─────┘  └─────┘  └─────┘  └─────┘  └─────┘               │
│  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐               │
│  │ Q2  │  │ Q2  │  │ Q2  │  │ Q2  │  │ Q2  │               │
│  └─────┘  └─────┘  └─────┘  └─────┘  └─────┘               │
│  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐               │
│  │ Q3  │  │ Q3  │  │ Q3  │  │ Q3  │  │ Q3  │               │
│  └─────┘  └─────┘  └─────┘  └─────┘  └─────┘               │
│  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐               │
│  │ Q4  │  │ Q4  │  │ Q4  │  │ Q4  │  │ Q4  │               │
│  └─────┘  └─────┘  └─────┘  └─────┘  └─────┘               │
│                                                             │
│  Theme     Theme     Theme     Theme     Theme              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Interpretation Levels**:
1. **Quarter Cards**: Specific events/challenges
2. **Year Theme**: Overall energy for the year
3. **Progression**: Story arc across 7 years
4. **Highlights**: Major turning points

#### 5.2 Focused Year Reading

For detailed single-year forecast:
- 12 cards (one per month)
- 4 summary cards (seasons)
- 1 year theme card
- Birth card influence

### 6. Playing Cards + Numerology Integration

#### 6.1 Life Path Card Affinities

| Life Path | Affinity Cards | Why |
|-----------|----------------|-----|
| 1 | A♥, A♦, K♣ | Leadership, new starts |
| 2 | 2♥, 2♦, Q♥ | Partnership, balance |
| 3 | 3♥, 3♣, J♥ | Creativity, expression |
| 4 | 4♦, 4♣, K♦ | Stability, foundation |
| 5 | 5♥, 5♠, J♦ | Change, freedom |
| 6 | 6♥, 6♦, Q♦ | Harmony, responsibility |
| 7 | 7♦, 7♠, K♠ | Analysis, spirituality |
| 8 | 8♣, 8♦, K♣ | Power, abundance |
| 9 | 9♥, 9♠, Q♠ | Completion, wisdom |
| 11 | J♠, Q♣, A♠ | Intuition, mastery |
| 22 | K♥, A♣, 10♦ | Master builder |
| 33 | Q♥, K♥, 6♥ | Compassionate service |

#### 6.2 Personal Day Alignment

```swift
func dailyCardAlignment(for date: Date, user: User) -> CardAlignment {
    let personalDay = NumerologyCalculator.personalDay(for: date, birthDate: user.birthDate)
    let birthCard = user.birthCard
    
    // Find cards matching personal day number
    let alignedCards = deck.filter { 
        cardRank($0) == personalDay || 
        cardRank($0) == reduceTo13(personalDay)
    }
    
    // Consider suit affinity with birth card
    let recommended = alignedCards.sorted {
        suitAffinity($0.suit, birthCard.suit) > 
        suitAffinity($1.suit, birthCard.suit)
    }
    
    return CardAlignment(...)
}
```

#### 6.3 Combined Readings

**Numerology + Cards Spreads**:
- Core numbers as positions
- Card draws for each number
- Combined interpretation

Example:
```
┌─────────────────────────────────────────┐
│  Your Numbers + Cards                   │
│                                         │
│  Life Path 7        →  7♦ (assessment)  │
│  Expression 3       →  3♥ (creativity)  │
│  Soul Urge 9        →  9♥ (completion)  │
│  Personality 4      →  4♣ (stability)   │
│                                         │
│  Reading: Your analytical nature (7)    │
│  expresses through creative emotion (3),│
│  driven by desire for emotional         │
│  completion (9), presenting as stable   │
│  work ethic (4).                        │
│                                         │
└─────────────────────────────────────────┘
```

---

## Data Models

```swift
// MARK: - Playing Card
struct PlayingCard: Codable, Identifiable, Hashable {
    let rank: CardRank
    let suit: Suit
    
    var id: String { "\(rank.rawValue)-of-\(suit.rawValue)" }
    var displayName: String { "\(rank.displayName) of \(suit.displayName)" }
    var symbol: String { suit.symbol }
    var color: CardColor { suit.color }
    
    // Numerological value
    var numerologyValue: Int {
        switch rank {
        case .ace: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        case .jack: return 11
        case .queen: return 12
        case .king: return 13
        }
    }
}

enum Suit: String, Codable, CaseIterable {
    case hearts = "Hearts"
    case diamonds = "Diamonds"
    case clubs = "Clubs"
    case spades = "Spades"
    
    var symbol: String {
        switch self {
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        case .spades: return "♠"
        }
    }
    
    var color: CardColor {
        switch self {
        case .hearts, .diamonds: return .red
        case .clubs, .spades: return .black
        }
    }
    
    var element: Element {
        switch self {
        case .hearts: return .water
        case .diamonds: return .earth
        case .clubs: return .fire
        case .spades: return .air
        }
    }
}

enum CardRank: String, Codable, CaseIterable {
    case ace = "Ace"
    case two = "Two"
    case three = "Three"
    case four = "Four"
    case five = "Five"
    case six = "Six"
    case seven = "Seven"
    case eight = "Eight"
    case nine = "Nine"
    case ten = "Ten"
    case jack = "Jack"
    case queen = "Queen"
    case king = "King"
    
    var displayName: String { rawValue }
    
    var abbreviated: String {
        switch self {
        case .ace: return "A"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        default: return String(numerologyValue)
        }
    }
}

enum CardColor: String, Codable {
    case red
    case black
}

// MARK: - Card Meaning
struct CardMeaning: Codable {
    let card: PlayingCard
    let keywords: [String]
    let generalMeaning: String
    let loveMeaning: String
    let careerMeaning: String
    let moneyMeaning: String
    let healthMeaning: String
    let advice: String
    let numerologyConnection: String
    let relatedCards: [PlayingCard]
}

// MARK: - Card Spread
struct CardSpread: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let numberOfCards: Int
    let positions: [SpreadPosition]
    let isCustom: Bool
    let createdBy: String? // user ID if custom
}

// MARK: - Card Reading
struct CardReading: Codable, Identifiable {
    let id: String
    let userId: String
    let createdAt: Date
    let spread: CardSpread
    let cards: [DrawnPlayingCard]
    let intention: String?
    let question: String?
    let interpretation: String?
    let isSaved: Bool
    let tags: [String]
}

struct DrawnPlayingCard: Codable {
    let card: PlayingCard
    let position: SpreadPosition
    let timestamp: Date
}

// MARK: - Birth Card
struct BirthCardProfile: Codable {
    let userId: String
    let birthCard: PlayingCard
    let calculatedAt: Date
    let meaning: String
    let gifts: [String]
    let challenges: [String]
    let famousPeople: [String]
    let yearCards: [YearCard]
}

struct YearCard: Codable {
    let year: Int
    let age: Int
    let card: PlayingCard
    let theme: String
}

// MARK: - Compatibility Reading
struct CompatibilityReading: Codable, Identifiable {
    let id: String
    let userAId: String
    let userBId: String
    let createdAt: Date
    let personA: PersonCardProfile
    let personB: PersonCardProfile
    let spreadCards: [DrawnPlayingCard]
    let compatibilityScore: Int
    let elementalBalance: [Element: Double]
    let strengths: [String]
    let challenges: [String]
    let advice: String
}

struct PersonCardProfile: Codable {
    let name: String
    let birthCard: PlayingCard
    let elementalAffinity: Element
    let courtCardRepresentation: PlayingCard?
}

// MARK: - Daily Card
struct DailyCard: Codable, Identifiable {
    let id: String
    let userId: String
    let date: Date
    let card: PlayingCard
    let context: DrawContext
    let personalInterpretation: String
    let actionStep: String
    let userReflection: String?
}
```

---

## Integration Points

### With Numerology Module

| Integration | Description |
|-------------|-------------|
| Birth Card | Calculate from birth date using numerology |
| Life Path Affinity | Suggest cards matching Life Path |
| Daily Alignment | Cards aligned with Personal Day |
| Yearly Forecast | 7-year spread using numerology cycles |
| Combined Readings | Cards drawn for each core number |

### With Tarot Module

| Integration | Description |
|-------------|-------------|
| Quick Alternative | Playing cards for fast readings |
| Comparison Tool | Same question, both systems |
| Learning Path | Playing cards before tarot |
| Court Cards | Shared court card meanings |
| Suit Correspondences | Hearts=Cups, Diamonds=Pentacles, etc. |

### With Social Features

| Integration | Description |
|-------------|-------------|
| Compatibility | Compare birth cards with friends |
| Group Spreads | Multi-person readings |
| Share Daily Card | Social media sharing |
| Reading Exchange | Trade interpretations |
| Leaderboards | Most readings, longest streaks |

### Subscription Tiers

| Feature | Free | Inner Circle | Initiate | Master |
|---------|------|--------------|----------|--------|
| Card Library | All 52 | All 52 | All 52 | All 52 |
| Daily Draw | ✅ | ✅ | ✅ | ✅ |
| 3-Card Spread | ✅ | ✅ | ✅ | ✅ |
| Saved Readings | 5 | Unlimited | Unlimited | Unlimited |
| Birth Card | ✅ | ✅ | ✅ | ✅ |
| Compatibility | 1/week | Unlimited | Unlimited | Unlimited |
| 7-Year Spread | ❌ | ✅ | ✅ | ✅ |
| Custom Spreads | ❌ | 3 | 10 | Unlimited |
| Yearly Forecast | ❌ | ❌ | ✅ | ✅ |
| AI Interpretation | ❌ | Basic | Full | Full |

---

## Content Structure

### Content Inventory

| Content Type | Count | Format | Source |
|--------------|-------|--------|--------|
| Card Meanings | 52 | Rich text | Shani-written |
| Keywords | ~300 | Text array | Curated |
| Context Meanings | 260 (52×5) | Text | Shani-written |
| Compatibility Patterns | 100+ | Algorithm + Text | Dynamic |
| Famous Birth Cards | 50+ | List | Research |
| Spread Templates | 10 | Rich text | Shani-designed |

### Card Art

**Style Options**:
1. **Classic**: Traditional playing card design
2. **Mystical**: Enhanced with esoteric symbols
3. **Modern**: Clean, minimalist design
4. **QodeX Brand**: Custom design matching app aesthetic

**Technical Specs**:
- Size: 600 x 840px (standard card ratio)
- Format: SVG for crisp scaling
- Colors: Suit-appropriate (red/black)

---

## UI/UX Specifications

### Navigation

```
Playing Cards (Tab)
├── Draw (Default)
│   ├── Daily Card
│   ├── Quick 3-Card
│   └── Custom Spread
├── Library
│   ├── All Cards
│   ├── By Suit
│   ├── By Number
│   └── Search
├── My Cards
│   ├── Birth Card
│   ├── Compatibility
│   └── 7-Year Spread
├── History
│   ├── Saved Readings
│   └── Statistics
└── Learn
    ├── Card Meanings
    ├── How to Read
    └── Practice
```

### Visual Design

**Card Display**:
- Realistic card rendering with shadows
- Flip animation (3D rotation)
- Fan layout for spreads
- Tap to enlarge
- Swipe between cards

**Color Scheme**:
- Hearts: #DC143C (Crimson)
- Diamonds: #FF6B6B (Coral Red)
- Clubs: #2F4F4F (Dark Slate)
- Spades: #1C1C1C (Near Black)
- Background: #0A0A0F (App standard)
- Accents: #D4AF37 (Gold)

### Animations

| Interaction | Animation | Duration |
|-------------|-----------|----------|
| Shuffle | Cards scramble | 1.0s |
| Deal | Slide to position | 0.2s each |
| Flip | 3D Y-rotation | 0.4s |
| Select | Scale up + glow | 0.15s |
| Spread | Fan out from center | 0.5s |

---

## Technical Requirements

### Performance

| Metric | Target |
|--------|--------|
| Card Load | < 50ms |
| Shuffle Animation | 60fps |
| Spread Setup | < 1s |
| Compatibility Calc | < 2s |

### Storage

| Asset | Size | Location |
|-------|------|----------|
| Card Images (SVG) | 2MB | Bundle |
| Text Content | 1MB | Bundle |
| User Readings | Variable | Local + Cloud |

---

## Success Metrics

### Engagement

| Metric | Target |
|--------|--------|
| Daily Draw Rate | 40% of users |
| Spread Usage | 3 per week |
| Birth Card View | 80% check it |
| Compatibility Use | 1 per week |
| Library Browse | 3 min avg |

### Business

| Metric | Target |
|--------|--------|
| Free-to-Paid (via this) | 5% |
| Social Shares | 1 per 8 readings |
| Streak Retention (14d) | 30% |

---

## Quick Reference: Suit Correspondences

| System | Hearts ♥ | Diamonds ♦ | Clubs ♣ | Spades ♠ |
|--------|----------|-----------|---------|----------|
| **Element** | Water | Earth | Fire | Air |
| **Season** | Spring | Summer | Autumn | Winter |
| **Time** | Morning | Afternoon | Evening | Night |
| **Tarot** | Cups | Pentacles | Wands | Swords |
| **Focus** | Emotions | Money | Work | Challenges |
| **Facets** | Love, Family | Career, Value | Growth, Creativity | Truth, Endings |

---

**Document Version**: 1.0
**Last Updated**: March 2026
**Author**: QodeX Product Team
