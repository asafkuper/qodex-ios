# QodeX Astrology Module — Technical Specification

> **Version:** 1.0  
> **Status:** Draft  
> **Last Updated:** 2026-03-11  
> **Owner:** QodeX Product Team

---

## 1. Overview

The Astrology Module extends QodeX beyond numerology into the celestial realm, providing members with personalized astrological insights that integrate seamlessly with their existing numerology profile. This module bridges ancient wisdom traditions with modern UX.

**Design Reference:** *The Pattern* for insights + *Co-Star* for visual language + *Sanctuary* for accessibility

---

## 2. Core Concepts

### 2.1 Natal Chart (Birth Chart)
A snapshot of planetary positions at birth, comprising:
- **Sun Sign** — Core identity, ego, life force
- **Moon Sign** — Emotional landscape, subconscious needs
- **Rising Sign (Ascendant)** — First impression, outward personality
- **Planets** — Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto
- **Houses** — 12 life sectors (career, relationships, home, etc.)
- **Aspects** — Angular relationships between planets (conjunctions, squares, trines, oppositions)

### 2.2 Transits
Current planetary positions relative to natal chart:
- Daily planetary movements
- Retrograde periods
- Major transits (Saturn return, Jupiter expansion, etc.)

### 2.3 Numerology-Astrology Bridge
| Number | Planet | Significance |
|--------|--------|--------------|
| 1 | Sun | Leadership, creativity, vitality |
| 2 | Moon | Intuition, receptivity, cycles |
| 3 | Jupiter | Expansion, optimism, growth |
| 4 | Uranus | Innovation, disruption, freedom |
| 5 | Mercury | Communication, adaptability, learning |
| 6 | Venus | Love, beauty, harmony |
| 7 | Neptune | Spirituality, dreams, transcendence |
| 8 | Saturn | Structure, karma, discipline |
| 9 | Mars | Action, desire, assertion |

---

## 3. Feature Specifications

### 3.1 Natal Chart Generation

#### 3.1.1 Birth Data Capture
```swift
struct BirthData {
    let date: Date
    let time: TimeInterval? // Optional for unknown birth times
    let timezone: TimeZone
    let latitude: Double
    let longitude: Double
    let locationName: String
}
```

**UI Flow:**
1. **Birth Date Picker** — Native iOS date picker with custom cosmic styling
2. **Time Input** — Optional with "Unknown Birth Time" toggle
3. **Location Search** — Google Places API integration with coordinate capture
4. **Confirmation Screen** — Visual preview of captured data with celestial background

**Validation Rules:**
- Date range: 1900–present (expandable via backend config)
- Location required for accurate house calculations
- Unknown time falls back to Sun sign only (no houses)

#### 3.1.2 Chart Calculation Engine

**Algorithm Requirements:**
- Swiss Ephemeris library integration (or modern Swift alternative like AstroSwift)
- House system: Placidus (default) with option for Whole Sign, Koch, Equal
- Ayanamsa: Tropical (default) with sidereal option
- Precision: Arc-second level for accurate aspects

**Calculation Pipeline:**
```
Birth Data → Julian Day Conversion → Planet Positions → 
House Cusps Calculation → Aspect Detection → Chart Rendering
```

**Performance Targets:**
- Chart generation: < 500ms on iPhone 12+
- Cached results for 24 hours minimum
- Background pre-calculation for daily transits

#### 3.1.3 Interactive Chart Wheel

**Visual Design:**
- Diameter: 280pt (iPhone) / 400pt (iPad)
- 12-house wheel with zodiac ring
- Planet glyphs positioned by degree
- Aspect lines (color-coded by type)
- Tap-to-explore interaction model

**Interaction States:**
- **Default:** Full wheel with subtle aspect lines
- **Planet Tap:** Highlight planet, show aspects to that planet, display info card
- **House Tap:** Highlight house sector, show house ruler and sign
- **Aspect Tap:** Highlight aspect line, show exact degree and interpretation

**Zoom & Pan:**
- Pinch to zoom (1x–3x)
- Rotation gesture to orient wheel
- Double-tap to reset view

---

### 3.2 Daily Transit Updates

#### 3.2.1 Transit Feed

**Content Structure:**
```swift
struct TransitReading {
    let id: UUID
    let date: Date
    let planet: Planet
    let aspect: AspectType
    let target: CelestialBody
    let exactTime: Date
    let orb: Double // degrees from exact
    let interpretation: TransitInterpretation
    let intensity: TransitIntensity // 1-5
    let duration: TransitDuration // fleeting, brief, moderate, extended
}
```

**Feed Layout:**
- Card-based vertical scroll
- Priority ordering by intensity + exactness
- Grouping by planet (e.g., "Mars Transits This Week")
- Visual indicators: 🔥 Major, ⭐ Significant, 💫 Subtle

**Daily Summary Card:**
- Top of feed, single-sentence "Weather Report"
- Example: "Mercury stations retrograde in your 3rd house — review communications"
- Moon phase icon with current sign

#### 3.2.2 Retrograde Alerts

**Alert Triggers:**
- Pre-retrograde shadow (2 weeks before)
- Station retrograde (exact day)
- Retrograde period (ongoing)
- Station direct (exact day)
- Post-retrograde shadow (2 weeks after)

**Notification Strategy:**
- Permission-based push notifications
- In-app badge on Astrology tab
- Calendar integration (optional)

**Content Template:**
```
🪐 {Planet} Retrograde in {Sign}
{Date Range} · {House} House

{Personalized interpretation based on natal chart}

Shadow periods: {Pre-shadow date} – {Post-shadow date}
```

---

### 3.3 Moon Phase Tracking

#### 3.3.1 Moon Visualizer
- Real-time moon phase rendering
- Current zodiac sign
- Exact illumination percentage
- Next phase with countdown timer

#### 3.3.2 Moon Calendar
- Monthly grid view
- Phase icons for each day
- Void-of-course moon indicators
- Eclipses highlighted

#### 3.3.3 Moon Ritual Suggestions
- New Moon: Intention setting prompts
- Full Moon: Release ceremonies
- Quarter Moons: Action/reflection prompts
- Personalized to user's natal moon sign

---

### 3.4 Planetary Hours

#### 3.4.1 Daily Hour Calculation
```swift
struct PlanetaryHour {
    let planet: Planet
    let startTime: Date
    let endTime: Date
    let isDayHour: Bool // vs. night hour
}
```

**Calculation Logic:**
1. Calculate sunrise/sunset for location
2. Divide daylight into 12 equal parts (day hours)
3. Divide nighttime into 12 equal parts (night hours)
4. Hour ruler cycles through Chaldean order: Saturn→Jupiter→Mars→Sun→Venus→Mercury→Moon

#### 3.4.2 Current Hour Display
- Large planet glyph with name
- Countdown to next hour
- Suggested activities for current planetary energy

---

### 3.5 Compatibility Synastry

#### 3.5.1 Partner Chart Input
- Same birth data capture as natal
- Optional nickname/relationship type
- Chart comparison saved for future reference

#### 3.5.2 Synastry Analysis
**Comparison Points:**
- Sun-Moon compatibility (emotional harmony)
- Venus-Mars chemistry
- Mercury-Mercury communication style
- House overlays (where partner's planets fall in your chart)
- Composite chart (relationship entity)

**Output Format:**
- Overall compatibility score (1-100)
- Strength areas (top 3)
- Growth areas (top 3)
- Detailed aspect-by-aspect breakdown

#### 3.5.3 Relationship Timing
- Composite transit tracking
- Significant dates for the relationship
- Synastry-based date recommendations

---

### 3.6 Progressions

#### 3.6.1 Secondary Progressions
- Calculated: Day-for-year (1 day after birth = 1 year of life)
- Progressed Sun, Moon, planets
- Progressed Ascendant
- Major life phase indicators

#### 3.6.2 Progressed Moon Cycle
- 28-year progressed moon cycle tracking
- Current progressed sign
- Progressed house position
- Key dates for major shifts

---

### 3.7 Transit + Numerology Insights (Fusion Feature)

**The Bridge:** Combined readings that weave astrological transits with numerology cycles.

**Algorithm:**
```swift
func generateFusionInsight(
    transit: TransitReading,
    personalYear: Int,
    lifePath: Int
) -> FusionInsight {
    // Cross-reference planetary ruler with numerology number
    let transitPlanetNumber = numerologyMapping[transit.planet]
    let combinedEnergy = (transitPlanetNumber + lifePath) % 9 || 9
    
    return FusionInsight(
        transit: transit,
        numerologyContext: personalYear,
        combinedTheme: combinedThemes[combinedEnergy],
        guidance: generateGuidance(transit, personalYear)
    )
}
```

**Example Outputs:**

| Transit + Numerology | Fusion Reading |
|---------------------|----------------|
| Saturn in 7th house + Life Path 7 | "Relationship lessons (Saturn/7th) align with your spiritual path (Life Path 7). This is a karmic time for authentic partnerships." |
| Jupiter in 2nd house + Personal Year 3 | "Expansion (Jupiter) meets creativity (Year 3). Financial opportunities through self-expression." |
| Mars square Sun + Challenge Number 9 | "Friction (Mars) activating your humanitarian drive. Channel anger into service." |

---

## 4. UI/UX Specifications

### 4.1 Navigation Structure

```
Astrology Tab
├── Dashboard (Today)
│   ├── Moon Phase
│   ├── Current Transit Highlight
│   ├── Planetary Hour
│   └── Quick Natal Chart Access
├── Transits Feed
│   ├── Daily View
│   ├── Weekly View
│   └── Monthly Overview
├── Natal Chart
│   ├── Interactive Wheel
│   ├── Planet Meanings
│   ├── House Meanings
│   └── Aspect Grid
├── Compatibility
│   ├── Saved Comparisons
│   └── New Comparison
└── Settings
    ├── House System
    ├── Zodiac System
    └── Notification Preferences
```

### 4.2 Visual Design System

**Color Palette (Astrology Specific):**
```swift
enum AstrologyColors {
    static let ariesRed = Color(hex: "#FF4444")
    static let taurusGreen = Color(hex: "#44AA44")
    static let geminiYellow = Color(hex: "#FFDD44")
    static let cancerSilver = Color(hex: "#C0C0C0")
    static let leoGold = Color(hex: "#FFD700")
    static let virgoBrown = Color(hex: "#8B7355")
    static let libraPink = Color(hex: "#FFB6C1")
    static let scorpioMaroon = Color(hex: "#800000")
    static let sagittariusPurple = Color(hex: "#9966CC")
    static let capricornGray = Color(hex: "#707070")
    static let aquariusElectric = Color(hex: "#00CCFF")
    static let piscesSea = Color(hex: "#66CCCC")
    
    // Element colors
    static let fire = Color(hex: "#FF6B35")
    static let earth = Color(hex: "#5D4E37")
    static let air = Color(hex: "#87CEEB")
    static let water = Color(hex: "#1E3A5F")
}
```

**Typography:**
- Sign names: Custom serif (Cinzel or similar)
- Planet names: SF Pro Display Medium
- Interpretations: SF Pro Text, 16pt, 1.5 line height
- Aspect glyphs: Astro font

**Icons & Glyphs:**
- Zodiac symbols: Unicode ♈︎ ♉︎ ♊︎ etc.
- Planet symbols: Unicode ☉ ☽ ♂ ♀ etc.
- Aspect symbols: ☌ □ △ ☍

### 4.3 Animation Specifications

**Chart Wheel:**
- Initial draw: 1.5s clockwise reveal
- Planet entry: Staggered 100ms per planet
- Aspect lines: Fade in after planets settle
- Tap feedback: Scale 1.1 → 1.0 with spring

**Transit Cards:**
- Entrance: Slide up + fade, 300ms, ease-out
- Priority highlight: Subtle pulse on high-intensity transits
- Pull-to-refresh: Custom cosmic swirl animation

---

## 5. Data Models

### 5.1 Core Entities

```swift
// MARK: - Natal Chart
struct NatalChart: Codable, Identifiable {
    let id: UUID
    let birthData: BirthData
    let createdAt: Date
    let calculatedAt: Date
    
    let sun: PlanetPosition
    let moon: PlanetPosition
    let mercury: PlanetPosition
    let venus: PlanetPosition
    let mars: PlanetPosition
    let jupiter: PlanetPosition
    let saturn: PlanetPosition
    let uranus: PlanetPosition
    let neptune: PlanetPosition
    let pluto: PlanetPosition
    
    let ascendant: Degree
    let midheaven: Degree
    let houses: [House] // 12 houses
    let aspects: [Aspect]
}

struct PlanetPosition: Codable {
    let planet: Planet
    let sign: ZodiacSign
    let degree: Degree // 0-29.999
    let house: Int // 1-12
    let isRetrograde: Bool
    let speed: Double // degrees per day
}

struct Aspect: Codable {
    let planet1: Planet
    let planet2: Planet
    let type: AspectType
    let orb: Double // degrees from exact
    let isApplying: Bool // approaching exact vs. separating
}

enum AspectType: String, Codable {
    case conjunction = 0 // 0°
    case semiSextile = 30 // 30°
    case semiSquare = 45 // 45°
    case sextile = 60 // 60°
    case quintile = 72 // 72°
    case square = 90 // 90°
    case trine = 120 // 120°
    case sesquiquadrate = 135 // 135°
    case biquintile = 144 // 144°
    case quincunx = 150 // 150°
    case opposition = 180 // 180°
}

// MARK: - Transits
struct TransitCollection: Codable {
    let date: Date
    let transits: [TransitReading]
    let dailyTheme: String
    let moonPhase: MoonPhase
}

// MARK: - Compatibility
struct SynastryReading: Codable {
    let chart1: NatalChart
    let chart2: NatalChart
    let compositeChart: CompositeChart
    let compatibilityScore: Int
    let strengthAreas: [CompatibilityFactor]
    let growthAreas: [CompatibilityFactor]
    let aspectInterplay: [SynastryAspect]
}
```

### 5.2 API Contracts

**GET /astrology/natal-chart**
```json
{
  "birthData": {
    "date": "1990-05-15T08:30:00Z",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "timezone": "America/New_York"
  }
}
```

**Response:**
```json
{
  "id": "uuid",
  "planets": {
    "sun": { "sign": "taurus", "degree": 24.5, "house": 10, "retrograde": false },
    "moon": { "sign": "cancer", "degree": 12.3, "house": 12, "retrograde": false }
    // ... other planets
  },
  "houses": [
    { "number": 1, "sign": "leo", "degree": 15.0 },
    // ... 12 houses
  ],
  "aspects": [
    { "planet1": "sun", "planet2": "moon", "type": "sextile", "orb": 2.5, "applying": true }
  ]
}
```

**GET /astrology/transits/{userId}**
```json
{
  "date": "2026-03-11",
  "transits": [
    {
      "planet": "mercury",
      "aspect": "conjunction",
      "target": "natal_sun",
      "exactTime": "2026-03-11T14:30:00Z",
      "orb": 0.5,
      "interpretation": "Mental clarity and self-expression are heightened...",
      "intensity": 4,
      "duration": "brief"
    }
  ],
  "dailyTheme": "A day for clear communication and mental focus",
  "moonPhase": { "phase": "waning_crescent", "sign": "aquarius", "illumination": 15 }
}
```

---

## 6. Integration Points

### 6.1 Numerology Integration
| Integration Point | Description |
|------------------|-------------|
| Profile Bridge | Natal chart linked to existing numerology profile |
| Fusion Insights | Combined transit + numerology readings (see 3.7) |
| Daily Card | Astrology component in daily numerology card |
| Yearly Forecast | Astrology transits woven into Personal Year reading |
| Compatibility | Synastry + numerology compatibility scoring |

### 6.2 Content System Integration
| Integration Point | Description |
|------------------|-------------|
| Teachings Library | Filter content by current transits |
| Live Sessions | Host astrology Q&A sessions |
| Journal | Transit-aware journal prompts |
| Challenges | Astrology-based 7-day challenges |

### 6.3 Notification System
- Daily transit digest (morning push)
- Retrograde alerts (permission-based)
- Moon phase reminders (New/Full Moon)
- Major transit warnings (Saturn returns, eclipses)

### 6.4 Widget Support
- Home Screen: Current moon phase + today's transit
- Lock Screen: Planetary hour widget
- WatchOS: Quick transit glance

---

## 7. Content Structure

### 7.1 Interpretation Database

**Database Schema:**
```sql
CREATE TABLE planet_sign_interpretations (
    id UUID PRIMARY KEY,
    planet VARCHAR(20) NOT NULL,
    sign VARCHAR(20) NOT NULL,
    short_description TEXT, -- 1 sentence
    full_description TEXT, -- 3-5 paragraphs
    keywords TEXT[], -- Array of keywords
    created_at TIMESTAMP
);

CREATE TABLE aspect_interpretations (
    id UUID PRIMARY KEY,
    planet1 VARCHAR(20) NOT NULL,
    planet2 VARCHAR(20) NOT NULL,
    aspect_type VARCHAR(20) NOT NULL,
    natal_interpretation TEXT,
    transit_interpretation TEXT,
    orb_tolerance DECIMAL(3,1)
);

CREATE TABLE transit_interpretations (
    id UUID PRIMARY KEY,
    planet VARCHAR(20) NOT NULL,
    house INT NOT NULL,
    interpretation_template TEXT, -- With {{variable}} placeholders
    intensity_score INT,
    duration_category VARCHAR(20)
);
```

### 7.2 Content Templates

**Natal Planet in Sign:**
```
# {{Planet}} in {{Sign}}

## Core Energy
[2-3 sentences on fundamental meaning]

## In Your Chart
[Personalized based on house position]

## Shadow Expression
[Challenging manifestations]

## Growth Path
[How to evolve this placement]

## Famous Examples
[3-5 notable people with same placement]
```

**Transit Interpretation:**
```
# {{Planet}} {{Aspect}} Your Natal {{Target}}

## The Energy
[What this transit brings]

## For You Personally
[Based on house position]

## How to Work With It
[Practical guidance]

## Timing
[Exact dates, duration, peaks]

## Integration
[How this connects to your numerology]
```

---

## 8. Technical Implementation

### 8.1 Dependencies
```swift
// Package.swift dependencies
.target(
    name: "QodeX",
    dependencies: [
        .package(url: "https://github.com/quephird/AstroSwift", from: "1.0.0"),
        .package(url: "https://github.com/google/GooglePlaces", from: "7.0.0"),
    ]
)
```

### 8.2 Architecture
```
Astrology/
├── Core/
│   ├── ChartCalculationService.swift
│   ├── TransitService.swift
│   └── EphemerisManager.swift
├── Models/
│   ├── NatalChart.swift
│   ├── Transit.swift
│   └── Compatibility.swift
├── Views/
│   ├── ChartWheelView.swift
│   ├── TransitFeedView.swift
│   ├── MoonPhaseView.swift
│   └── CompatibilityView.swift
├── ViewModels/
│   ├── NatalChartViewModel.swift
│   ├── TransitFeedViewModel.swift
│   └── CompatibilityViewModel.swift
└── Resources/
    ├── interpretations.json
    └── glyphs/
```

### 8.3 Caching Strategy
```swift
protocol AstrologyCache {
    func cacheChart(_ chart: NatalChart, for birthData: BirthData)
    func getChart(for birthData: BirthData) -> NatalChart?
    func cacheTransits(_ transits: TransitCollection, for date: Date)
    func getTransits(for date: Date) -> TransitCollection?
}

// Implementation: Core Data + Memory cache
// TTL: Charts = permanent, Transits = 6 hours
```

### 8.4 Offline Support
- Pre-calculate 30 days of transits
- Download interpretation content on-demand
- Cache frequently accessed readings
- Queue sync for new birth data

---

## 9. Testing Requirements

### 9.1 Calculation Accuracy
- Validate against Swiss Ephemeris reference data
- Test with known celebrity charts
- Verify house system variations
- Test edge cases (polar regions, DST transitions)

### 9.2 Known Test Charts
| Name | Birth Data | Verification Source |
|------|-----------|---------------------|
| Steve Jobs | Feb 24, 1955, 19:15, San Francisco, CA | Multiple astrology databases |
| Oprah Winfrey | Jan 29, 1954, 04:30, Kosciusko, MS | Astro.com |
| Albert Einstein | Mar 14, 1879, 11:30, Ulm, Germany | Historical records |

### 9.3 UI Testing
- Chart wheel rotation and zoom
- Transit feed scroll performance
- Moon phase accuracy
- Notification delivery

---

## 10. Future Enhancements

### 10.1 V2 Features
- Solar return charts
- Lunar return charts
- Electional astrology (best timing)
- Horary astrology (question answering)
- Fixed stars analysis
- Asteroid support (Chiron, Lilith, etc.)

### 10.2 Advanced Integrations
- Astrocartography (location astrology)
- Medical astrology insights
- Financial astrology (crypto timing)
- Sports astrology (event prediction)

### 10.3 AI Enhancements
- GPT-powered personalized interpretations
- Conversational astrology chat
- Pattern recognition across user base
- Predictive modeling

---

## 11. Appendix

### 11.1 Glossary
| Term | Definition |
|------|-----------|
| Ascendant | Eastern horizon at birth; rising sign |
| Cusp | Boundary between houses or signs |
| Ephemeris | Table of planetary positions |
| Orb | Degrees of allowance from exact aspect |
| Retrograde | Apparent backward motion of planet |
| Station | When planet appears to change direction |
| Zodiac | 12-sign belt along ecliptic |

### 11.2 House Meanings Quick Reference
| House | Life Area |
|-------|-----------|
| 1st | Self, body, appearance |
| 2nd | Money, values, resources |
| 3rd | Communication, siblings, local travel |
| 4th | Home, family, roots |
| 5th | Creativity, romance, children |
| 6th | Work, health, daily routines |
| 7th | Partnerships, marriage, contracts |
| 8th | Transformation, shared resources, death |
| 9th | Higher learning, travel, philosophy |
| 10th | Career, reputation, public life |
| 11th | Friends, groups, hopes |
| 12th | Secrets, spirituality, undoing |

---

*Document Version History:*
- v1.0 (2026-03-11) — Initial specification
