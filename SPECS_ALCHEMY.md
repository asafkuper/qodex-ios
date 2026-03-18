# QodeX Alchemy Module Specification

## Overview
The Alchemy Module guides users through the ancient art of transformation, tracking their elemental profile and providing personalized practices for achieving inner balance and transmutation.

---

## Core Concepts

### The 4 Elements
| Element | Quality | Season | Direction | Time | Temperament |
|---------|---------|--------|-----------|------|-------------|
| 🔥 Fire | Hot & Dry | Summer | South | Noon | Choleric |
| 💧 Water | Cold & Wet | Winter | North | Midnight | Phlegmatic |
| 🌬️ Air | Hot & Wet | Spring | East | Dawn | Sanguine |
| 🌍 Earth | Cold & Dry | Autumn | West | Dusk | Melancholic |

### The 3 Principles (Tria Prima)
| Principle | Symbol | Quality | Element | Soul Aspect |
|-----------|--------|---------|---------|-------------|
| 🜍 Sulfur | 🜍 | Masculine, Active, Soul | Fire & Air | Consciousness, Will |
| ☿ Mercury | ☿ | Neutral, Balanced, Spirit | Water & Air | Connection, Communication |
| 🜔 Salt | 🜔 | Feminine, Passive, Body | Earth & Water | Form, Substance |

### The 7 Metals & Planets
| Metal | Symbol | Planet | Day | Element | Stage |
|-------|--------|--------|-----|---------|-------|
| Gold | ☉ | ☉ Sun | Sunday | Fire | Completion |
| Silver | ☽ | ☽ Moon | Monday | Water | Reflection |
| Iron | ♂ | ♂ Mars | Tuesday | Fire | Calcination |
| Mercury | ☿ | ☿ Mercury | Wednesday | Water/Air | Separation |
| Tin | ♃ | ♃ Jupiter | Thursday | Air | Exaltation |
| Copper | ♀ | ♀ Venus | Friday | Water/Earth | Multiplication |
| Lead | ♄ | ♄ Saturn | Saturday | Earth | Putrefaction |

### Alchemical Operations (The 12 Stages)
1. **Calcination** - Breaking down ego through fire
2. **Dissolution** - Dissolving in water, unconscious exploration
3. **Separation** - Dividing pure from impure
4. **Conjunction** - Recombining opposites
5. **Putrefaction** - Decay before renewal
6. **Congelation** - Solidifying the new form
7. **Cibation** - Feeding the work
8. **Sublimation** - Purification through vaporization
9. **Fermentation** - Spiritual animation
10. **Exaltation** - Raising to higher vibration
11. **Multiplication** - Increasing the power
12. **Projection** - Final manifestation

---

## Feature Specifications

### 1. Elemental Profile

**Calculation Logic:**
```swift
struct ElementalProfile {
    let fire: Double    // 0.0 - 1.0
    let water: Double   // 0.0 - 1.0
    let air: Double     // 0.0 - 1.0
    let earth: Double   // 0.0 - 1.0
    
    var dominant: Element {
        max(fire, water, air, earth) element
    }
    
    var weakest: Element {
        min(fire, water, air, earth) element
    }
    
    var balance: Double {
        // Calculate variance from perfect balance (0.25 each)
        let ideal = 0.25
        let variance = abs(fire - ideal) + abs(water - ideal) + 
                      abs(air - ideal) + abs(earth - ideal)
        return 1.0 - (variance / 2.0)  // 1.0 = perfect balance
    }
}

func calculateElementalProfile(from chart: BirthChart) -> ElementalProfile {
    // 1. Sun sign element (25% weight)
    let sunElement = chart.sunSign.element
    
    // 2. Moon sign element (25% weight)
    let moonElement = chart.moonSign.element
    
    // 3. Rising sign element (20% weight)
    let risingElement = chart.risingSign.element
    
    // 4. Planet distribution (20% weight)
    let planetElements = chart.planets.map { $0.sign.element }
    
    // 5. House distribution (10% weight)
    let houseElements = chart.houses.map { $0.element }
    
    // Aggregate with weights
    return ElementalProfile(
        fire: weightedAverage([sunElement, moonElement, risingElement, planetElements, houseElements]),
        water: /* ... */,
        air: /* ... */,
        earth: /* ... */
    )
}
```

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  🜁 Your Elemental Profile               │
│                                         │
│        ╭─────────────╮                  │
│       ╱    🔥 85%    ╲                 │
│      ╱   FIRE        ╲                 │
│     ╱   Choleric      ╲                │
│    ╱                   ╲               │
│   ╱  🌬️ 60%    💧 45%  ╲              │
│  ╱   AIR       WATER    ╲             │
│ ╱   Sanguine  Phlegmatic ╲            │
│╱                           ╲           │
│      🌍 10%                 ╲          │
│     EARTH                    ╲         │
│    Melancholic                ╲        │
│                                ╰───────╯
│                                         │
│  Dominant: 🔥 Fire (85%)                │
│  "The Alchemist's Flame"                │
│                                         │
│  Profile Analysis:                      │
│  You possess strong creative drive and  │
│  transformative energy. Your challenge  │
│  is grounding (Earth: 10%).             │
│                                         │
│  [View Full Analysis] [Balance Tips]    │
└─────────────────────────────────────────┘
```

---

### 2. Elemental Balance Tracker

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  ⚖️ Elemental Balance                   │
│  Last 30 Days                           │
│                                         │
│  Fire    ████████████████████░░  78%   │
│          [sparkline graph]              │
│                                         │
│  Water   ██████████░░░░░░░░░░░░  42%   │
│          [sparkline graph]              │
│                                         │
│  Air     ██████████████░░░░░░░░  56%   │
│          [sparkline graph]              │
│                                         │
│  Earth   ████░░░░░░░░░░░░░░░░░░  18%   │
│          [sparkline graph]              │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │     Balance Score: 62/100       │   │
│  │                                 │   │
│  │  [Visual: Elements in motion]   │   │
│  │                                 │   │
│  │  🔥🔥🔥🔥🔥🔥🔥🔥               │   │
│  │  💧💧💧💧                       │   │
│  │  🌬️🌬️🌬️🌬️🌬️                  │   │
│  │  🌍🌍                           │   │
│  └─────────────────────────────────┘   │
│                                         │
│  This Week's Trend: Fire ↑ Earth ↓     │
│                                         │
│  [Log Activity] [View History]          │
└─────────────────────────────────────────┘
```

**Activity Logging:**
```swift
enum ElementalActivity {
    case meditation(element: Element, duration: TimeInterval)
    case exercise(type: ExerciseType, intensity: Int)
    case creativeWork(medium: String, duration: TimeInterval)
    case socialInteraction(type: SocialType, energy: Int)
    case rest(quality: RestQuality, duration: TimeInterval)
    case meal(type: MealElemental, satisfaction: Int)
    case natureExposure(element: Element, duration: TimeInterval)
}

func logActivity(_ activity: ElementalActivity) {
    // Update elemental balance based on activity
    // Fire activities: Exercise, passion projects, conflict
    // Water activities: Meditation, emotional processing, bathing
    // Air activities: Reading, socializing, planning
    // Earth activities: Gardening, cooking, organizing
}
```

---

### 3. Daily Element Focus

**Calculation Logic:**
```swift
func calculateDailyElement(for date: Date, profile: ElementalProfile) -> DailyElement {
    // 1. Astrological influence
    let moonSign = calculateMoonSign(for: date)
    let moonElement = moonSign.element
    
    // 2. Day of week influence
    let weekdayElement = weekdayToElement(date.weekday)
    // Sunday = Fire, Monday = Water, Tuesday = Fire, 
    // Wednesday = Air, Thursday = Air, Friday = Water, Saturday = Earth
    
    // 3. Seasonal influence
    let seasonalElement = seasonToElement(date.season)
    
    // 4. User's current balance (inverse to recommend what's needed)
    let neededElement = profile.weakest
    
    // Weight and calculate
    let weights: [Element: Double] = [
        .fire: calculateWeight(moon: moonElement, weekday: weekdayElement, 
                              seasonal: seasonalElement, needed: neededElement),
        .water: /* ... */,
        .air: /* ... */,
        .earth: /* ... */
    ]
    
    return DailyElement(
        primary: weights.maxElement(),
        secondary: weights.secondHighest(),
        practices: generatePractices(for: weights),
        forecast: generateForecast(for: date, weights: weights)
    )
}
```

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  🌊 Today's Element: WATER              │
│  Wednesday, March 12                    │
│                                         │
│  ╭─────────────────────────────────╮   │
│  │                                 │   │
│  │     [Flowing water animation]   │   │
│  │                                 │   │
│  │          💧 WATER 💧            │   │
│  │        Cold & Wet               │   │
│  │        Winter's Flow            │   │
│  │                                 │   │
│  ╰─────────────────────────────────╯   │
│                                         │
│  Lunar Influence: Moon in Cancer ♋     │
│  Secondary: 🔥 Fire (Mars aspect)       │
│                                         │
│  For Your Profile:                      │
│  Water complements your dominant Fire.  │
│  Today is ideal for emotional processing│
│  and cooling your inner flame.          │
│                                         │
│  🧘 Suggested Practices:                │
│  ├─ Morning: Water meditation (10 min)  │
│  ├─ Afternoon: Journaling by water      │
│  ├─ Evening: Bath ritual with salts     │
│  └─ Before bed: Emotional release       │
│                                         │
│  [Start Water Meditation]               │
│  [Log Water Activity]                   │
└─────────────────────────────────────────┘
```

---

### 4. Alchemical Transformation Meditations

**Content Structure:**

#### The 12 Operations Series
| Stage | Name | Element | Focus | Duration |
|-------|------|---------|-------|----------|
| 1 | Calcination | 🔥 Fire | Ego dissolution | 15 min |
| 2 | Dissolution | 💧 Water | Unconscious exploration | 18 min |
| 3 | Separation | 🌬️ Air | Discernment | 12 min |
| 4 | Conjunction | 🌍 Earth | Sacred marriage | 20 min |
| 5 | Putrefaction | 🌍 Earth | Decay and rebirth | 15 min |
| 6 | Congelation | 💧 Water | Crystallization | 14 min |
| 7 | Cibation | 🌍 Earth | Nourishment | 12 min |
| 8 | Sublimation | 🌬️ Air | Purification | 16 min |
| 9 | Fermentation | 💧 Water | Spiritual animation | 18 min |
| 10 | Exaltation | 🔥 Fire | Rising energy | 14 min |
| 11 | Multiplication | 🔥 Fire | Expansion | 15 min |
| 12 | Projection | 🌍 Earth | Manifestation | 20 min |

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  ⚗️ The Great Work                      │
│  Alchemical Transformation Journey       │
│                                         │
│  Your Progress:                         │
│  ████████░░░░░░░░░░░░ 2/12 Complete    │
│                                         │
│  Current Stage: DISSOLUTION             │
│  Stage 2 of 12                          │
│  Element: 💧 Water                      │
│  Duration: 18 minutes                   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │  [Animated alembic with        │   │
│  │   dissolving substances]        │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Dissolution invites you to surrender   │
│  to the waters of the unconscious.      │
│  Allow rigid structures to soften.      │
│                                         │
│  Stage Symbol: 🜄 Water                  │
│  Mercury Phase: ☿ Coagulation           │
│                                         │
│  [Begin Dissolution Practice]           │
│  [Read Stage Guide]                     │
│                                         │
│  Completed Stages:                      │
│  ☑️ Calcination (Fire)                  │
│  ⏳ Dissolution (Water) - In Progress   │
│  ○ Separation (Air) - Locked            │
└─────────────────────────────────────────┘
```

---

### 5. Metal Associations & Planetary Working

**Personal Metal Affinity Calculation:**
```swift
struct MetalAffinity {
    let gold: Double      // Sun influence
    let silver: Double    // Moon influence
    let mercury: Double   // Mercury influence
    let copper: Double    // Venus influence
    let iron: Double      // Mars influence
    let tin: Double       // Jupiter influence
    let lead: Double      // Saturn influence
    
    var dominantMetal: Metal {
        // Based on planetary positions in birth chart
    }
    
    var currentMetal: Metal {
        // Based on current planetary hour
    }
}

func calculateMetalAffinity(chart: BirthChart, date: Date) -> MetalAffinity {
    // Weight by:
    // - Sun/Moon sign rulers
    // - Planet positions in signs
    // - Current planetary hours
    // - Elemental profile correlation
}
```

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  🜔 The Seven Metals                     │
│                                         │
│  Your Personal Affinities:              │
│                                         │
│  Primary Metal:                         │
│  ╭─────────────────────────────────╮   │
│  │  ☉ GOLD                         │   │
│  │  The Sun's Perfection           │   │
│  │  Affinity: 87%                  │   │
│  │                                 │   │
│  │  "Completion, radiance, the     │   │
│  │   work fulfilled"               │   │
│  ╰─────────────────────────────────╯   │
│                                         │
│  Secondary Affinities:                  │
│  ♃ Tin (Jupiter) ████████████░░ 76%    │
│  ☽ Silver (Moon) ██████████░░░░ 65%    │
│  ♀ Copper (Venus) ████████░░░░░░ 54%   │
│                                         │
│  Growth Areas:                          │
│  ♄ Lead (Saturn) ███░░░░░░░░░░░░ 32%   │
│  ♂ Iron (Mars) ████░░░░░░░░░░░░░ 38%   │
│                                         │
│  Today's Planetary Hour:                │
│  🜚 Mercury Hour (13:00-14:00)           │
│  Optimal for: Communication, learning   │
│                                         │
│  [Metal Meditation] [Planetary Hours]   │
└─────────────────────────────────────────┘
```

---

### 6. The Laboratory (Practice Exercises)

**Exercise Categories:**

#### Fire Practices
- Candle gazing meditation
- Sun salutations
- Passion journaling
- Creative visualization
- Fire breathing (pranayama)

#### Water Practices
- Bath rituals
- Emotional flow writing
- Moon gazing
- Water blessing ceremonies
- Tears release meditation

#### Air Practices
- Breath awareness
- Cloud watching
- Feather visualization
- Thought observation
- Wind connection

#### Earth Practices
- Grounding meditation
- Crystal work
- Garden tending
- Clay modeling
- Body scan relaxation

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  🜔 The Laboratory                       │
│  Practice Space for Inner Alchemy       │
│                                         │
│  Choose Your Element:                   │
│  [🔥 Fire] [💧 Water] [🌬️ Air] [🌍 Earth]│
│                                         │
│  Fire Practices Available:              │
│  ┌─────────────────────────────────┐   │
│  │ ⚗️ Candle Gazing                │   │
│  │    15 min • Beginner            │   │
│  │    Focus and will cultivation   │   │
│  ├─────────────────────────────────┤   │
│  │ ⚗️ Solar Breath (Surya Bhedana) │   │
│  │    10 min • Intermediate        │   │
│  │    Activating inner fire        │   │
│  ├─────────────────────────────────┤   │
│  │ ⚗️ Phoenix Visualization        │   │
│  │    20 min • Advanced            │   │
│  │    Death and rebirth journey    │   │
│  ├─────────────────────────────────┤   │
│  │ ⚗️ Creative Ignition            │   │
│  │    Variable • All levels        │   │
│  │    Spark creative projects      │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Recommended for You:                   │
│  "Earth Grounding" - Your weakest       │
│  element needs attention.               │
│                                         │
│  [Start Recommended] [Random Practice]  │
│                                         │
│  Your Practice Stats:                   │
│  This week: 5 practices • 72 minutes    │
│  Streak: 3 days 🔥                      │
└─────────────────────────────────────────┘
```

---

### 7. Elemental Weather

**Calculation Logic:**
```swift
struct ElementalWeather {
    let timestamp: Date
    let fireIntensity: Double   // 0.0 - 1.0
    let waterIntensity: Double
    let airIntensity: Double
    let earthIntensity: Double
    let dominantCondition: ElementalCondition
    let forecast: [ElementalForecast]  // Next 7 days
    
    enum ElementalCondition {
        case calm              // All balanced
        case storm(Fire)       // Fire dominant
        case flood(Water)      // Water dominant
        case gale(Air)         // Air dominant
        case earthquake(Earth) // Earth dominant
        case convergence       // Two elements equal
        case void              // All low
    }
}

func calculateElementalWeather(for date: Date, location: Location) -> ElementalWeather {
    // Factors:
    // 1. Moon phase and sign
    // 2. Planetary aspects
    // 3. Season
    // 4. Local weather (if available)
    // 5. Solar activity
    // 6. User's elemental cycle
    
    let moonPhase = calculateMoonPhase(date)
    let moonSign = calculateMoonSign(date)
    let aspects = calculatePlanetaryAspects(date)
    
    return ElementalWeather(
        fireIntensity: calculateFire(moon: moonPhase, aspects: aspects),
        waterIntensity: calculateWater(moon: moonSign, aspects: aspects),
        airIntensity: calculateAir(aspects: aspects, season: date.season),
        earthIntensity: calculateEarth(moon: moonSign, season: date.season),
        dominantCondition: determineCondition(/* ... */),
        forecast: generateForecast(from: date, days: 7)
    )
}
```

**UI Mockup Description:**
```
┌─────────────────────────────────────────┐
│  🌤️ Elemental Weather                   │
│  Current Conditions & Forecast          │
│                                         │
│  ╭─────────────────────────────────╮   │
│  │  NOW: BALANCED CONVERGENCE      │   │
│  │                                 │   │
│  │     🔥 45%    💧 48%            │   │
│  │     🌬️ 50%    🌍 47%            │   │
│  │                                 │   │
│  │  All elements near equilibrium  │   │
│  │  Ideal for integration work     │   │
│  ╰─────────────────────────────────╯   │
│                                         │
│  7-Day Forecast:                        │
│  ┌─────────────────────────────────┐   │
│  │ Thu 🔥 Fire Storm   ████████░░ │   │
│  │ Fri  💧 Heavy Rain  █████████░ │   │
│  │ Sat  🌬️ Windy       ██████░░░░ │   │
│  │ Sun  🌍 Stable      █████░░░░░ │   │
│  │ Mon  ⚖️ Balanced    ██████░░░░ │   │
│  │ Tue  🔥 Heat Wave   █████████░ │   │
│  │ Wed  💧 Flood       ████████░░ │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Best Days for Your Practice:           │
│  • Fire work: Thursday, Tuesday         │
│  • Water work: Friday, Wednesday        │
│  • Integration: Sunday, Monday          │
│                                         │
│  [Set Weather Alerts] [Weekly Planner]  │
└─────────────────────────────────────────┘
```

---

## Integration Points

### With Kabbalah Module
- Elements map to Sephirot qualities
- Alchemy operations align with Path working
- Metal correspondences link to Hebrew letter metals

### With Numerology Module
- Life Path → Primary element affinity
- Personal Year → Elemental focus shift
- Name analysis → Hidden element patterns

### With Astrology Module
- Planet positions → Metal affinities
- Zodiac elements → Base elemental profile
- Houses → Elemental distribution
- Aspects → Elemental weather

### With Meditation Module
- Elemental meditations → Audio library
- Alchemical operations → Guided journeys
- Breathing practices → Pranayama integration

---

## Data Models

```swift
// MARK: - Core Enums

enum Element: String, CaseIterable {
    case fire = "Fire"
    case water = "Water"
    case air = "Air"
    case earth = "Earth"
    
    var symbol: String { /* 🔥 💧 🌬️ 🌍 */ }
    var quality: (hot: Bool, wet: Bool) { /* ... */ }
    var season: Season { /* ... */ }
    var direction: Direction { /* ... */ }
    var temperament: Temperament { /* ... */ }
    var color: Color { /* ... */ }
}

enum Principle: String {
    case sulfur = "Sulfur"
    case mercury = "Mercury"
    case salt = "Salt"
    
    var symbol: String { /* 🜍 ☿ 🜔 */ }
    var quality: String { /* ... */ }
    var elements: [Element] { /* ... */ }
    var soulAspect: String { /* ... */ }
}

enum Metal: String, CaseIterable {
    case gold = "Gold"
    case silver = "Silver"
    case mercury = "Mercury"
    case copper = "Copper"
    case iron = "Iron"
    case tin = "Tin"
    case lead = "Lead"
    
    var symbol: String { /* ☉ ☽ ☿ ♀ ♂ ♃ ♄ */ }
    var planet: Planet { /* ... */ }
    var day: Weekday { /* ... */ }
    var element: Element { /* ... */ }
    var stage: AlchemicalStage { /* ... */ }
}

enum AlchemicalStage: Int, CaseIterable {
    case calcination = 1
    case dissolution = 2
    case separation = 3
    case conjunction = 4
    case putrefaction = 5
    case congelation = 6
    case cibation = 7
    case sublimation = 8
    case fermentation = 9
    case exaltation = 10
    case multiplication = 11
    case projection = 12
    
    var name: String { /* ... */ }
    var element: Element { /* ... */ }
    var principle: Principle { /* ... */ }
    var description: String { /* ... */ }
}

// MARK: - User Data Models

struct ElementalProfile {
    let userId: UUID
    let fire: Double
    let water: Double
    let air: Double
    let earth: Double
    let calculatedAt: Date
    let sourceChartId: UUID?
}

struct ElementalBalanceHistory {
    let userId: UUID
    let date: Date
    let fire: Double
    let water: Double
    let air: Double
    let earth: Double
    let activities: [ElementalActivity]
}

struct DailyElement {
    let date: Date
    let primary: Element
    let secondary: Element
    let intensity: Double
    let lunarInfluence: String
    let practices: [Practice]
    let forecast: String
    let crystal: String
    let herb: String
    let color: String
}

struct MetalAffinity {
    let userId: UUID
    let gold: Double
    let silver: Double
    let mercury: Double
    let copper: Double
    let iron: Double
    let tin: Double
    let lead: Double
    let calculatedAt: Date
}

struct AlchemicalJourney {
    let userId: UUID
    let currentStage: AlchemicalStage
    let stageProgress: [AlchemicalStage: StageProgress]
    let startedAt: Date
    let lastActivityAt: Date
}

struct StageProgress {
    let stage: AlchemicalStage
    let isCompleted: Bool
    let completedAt: Date?
    let practiceCount: Int
    let reflections: [String]
}
```

---

## Content Assets Required

### Audio
- 12 Alchemical operation meditations (15-20 min each)
- 4 Elemental attunement tracks (10 min each)
- Metal resonance frequencies (7 tracks)
- Laboratory practice audio guides
- Background ambient: Fire crackling, water flowing, wind, earth sounds

### Visual
- Elemental symbols and animations
- Alchemical equipment diagrams
- Metal illustrations
- Stage visualization graphics
- Laboratory UI elements

### Text
- Element descriptions (500 words each)
- Principle deep dives (400 words each)
- Metal correspondences (300 words each)
- 12 Stage guides (600 words each)
- Practice instructions (200+ entries)
- Daily guidance templates

---

## Settings & Customization

```swift
struct AlchemySettings {
    var elementalNotifications: Bool = true
    var dailyElementTime: Date = Date(hour: 6, minute: 30)
    var weatherAlerts: Bool = true
    var practiceReminders: Bool = true
    var reminderFrequency: ReminderFrequency = .daily
    var showAdvancedStages: Bool = false
    var planetaryHourNotifications: Bool = false
    var laboratoryAnimations: Bool = true
    var audioQuality: AudioQuality = .high
}
```

---

## Future Enhancements

1. **AR Laboratory**: Visualize alchemical processes in augmented reality
2. **Community Transmutation**: Group challenges for collective elemental work
3. **Expert Series**: Guest alchemists share their practices
4. **Historical Texts**: Digital library of alchemical manuscripts
5. **Chemistry Connection**: Bridge to modern chemistry understanding
6. **Spagyrics Integration**: Herbal alchemy and plant medicine

---

*Document Version: 1.0*
*Last Updated: March 2025*
