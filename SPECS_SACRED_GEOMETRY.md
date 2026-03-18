# QodeX Sacred Geometry Module — Technical Specification

## Overview

The Sacred Geometry Module extends QodeX's esoteric toolkit with interactive visualizations of universal mathematical patterns. This module connects users to the geometric foundations of existence, offering personalized insights based on birth data and daily cosmic alignments.

**Module Status**: Planned for V3.2 (Post-launch)
**Complexity**: High (requires Metal/SceneKit rendering)
**Dependencies**: Core Numerology, User Profile, Notifications

---

## Core Concepts

### Sacred Patterns

| Pattern | Description | Symbolism | Mathematical Basis |
|---------|-------------|-----------|-------------------|
| **Seed of Life** | 7 overlapping circles | Creation, potential, beginnings | 6 circles around 1 center |
| **Flower of Life** | 19+ overlapping circles | Unity, interconnectedness, cosmic order | Sacred geometric tessellation |
| **Tree of Life** | 10 sephirot + 22 paths | Kabbalistic energy flow, spiritual ascent | 3 pillars, 4 worlds |
| **Platonic Solids** | 5 perfect 3D shapes | Elements, cosmic building blocks | Tetrahedron, Cube, Octahedron, Dodecahedron, Icosahedron |
| **Metatron's Cube** | 13 circles with lines | Archangel Metatron, divine protection | Contains all 5 Platonic solids |
| **Golden Spiral** | Logarithmic spiral | Growth, evolution, divine proportion | Fibonacci sequence, φ (1.618) |

### Elemental Correspondences

| Solid | Element | Properties | Associated Numbers |
|-------|---------|------------|-------------------|
| Tetrahedron | Fire | Transformation, willpower, passion | 1, 9 |
| Cube (Hexahedron) | Earth | Stability, foundation, material | 4, 8 |
| Octahedron | Air | Intellect, communication, balance | 3, 5 |
| Dodecahedron | Ether/Spirit | Cosmic connection, transcendence | 7, 11 |
| Icosahedron | Water | Emotion, intuition, flow | 2, 6 |

---

## Feature Specifications

### 1. Interactive Sacred Geometry Visualizations

#### 1.1 Pattern Library Screen

**Layout**: 
- Grid of 6 pattern cards (2x3 on iPhone, 3x2 on iPad)
- Each card shows animated preview of the geometry
- Gold border glows on user's "personal pattern"

**Pattern Card Components**:
```
┌─────────────────────────────┐
│  [Animated Geometry Preview] │
│        200x200pt             │
│                              │
│   Flower of Life             │
│   ━━━━━━━━━━━━━━            │
│   Unity • Creation           │
│                              │
│   [View Interactive]         │
└─────────────────────────────┘
```

**Animation Specs**:
- Preview: Subtle breathing animation (scale 0.95-1.05, 4s loop)
- Interactive: Full 360° rotation with pinch-to-zoom
- Rotation speed: 0.5°/second default, user-adjustable
- Haptic feedback on each complete rotation

#### 1.2 Interactive Viewer

**Controls**:
- **Rotate**: Pan gesture (360° X/Y axis)
- **Zoom**: Pinch gesture (0.5x - 3.0x)
- **Speed**: Slider for auto-rotation (0-10 RPM)
- **Layers**: Toggle individual circles/lines
- **Colors**: Theme selector (Gold, Silver, Rose Gold, Cosmic)

**Visual Themes**:
| Theme | Background | Geometry Color | Accent |
|-------|------------|----------------|--------|
| Celestial Gold | #0A0A0F | #D4AF37 | #FFE5A0 |
| Lunar Silver | #0A0A0F | #C0C0C0 | #E8E8E8 |
| Rose Mystery | #0A0A0F | #FFB6C1 | #FFD1DC |
| Cosmic Nebula | #0A0A0F | #6B4EE6 | #00D4AA |

#### 1.3 Pattern Detail View

**Content Sections**:
1. **Sacred Meaning** (scrollable text)
2. **Historical Origins** (timeline)
3. **Mathematical Properties** (interactive diagrams)
4. **Personal Connection** (if calculated)
5. **Meditation Guide** (audio + visual)

---

### 2. Personal Geometry

#### 2.1 Birth-Based Geometry Calculation

**Algorithm**:

```swift
struct PersonalGeometry {
    let lifePathNumber: Int
    let dominantSolid: PlatonicSolid
    let secondarySolid: PlatonicSolid
    let sacredPattern: SacredPattern
    let elementalBalance: [Element: Double]
    
    static func calculate(from birthDate: Date, name: String) -> PersonalGeometry {
        let lifePath = NumerologyCalculator.lifePath(from: birthDate)
        let expression = NumerologyCalculator.expression(from: name)
        
        // Primary solid from Life Path
        let dominant = platonicSolidForNumber(lifePath)
        
        // Secondary from Expression
        let secondary = platonicSolidForNumber(expression)
        
        // Sacred pattern from combination
        let pattern = sacredPatternForPair(lifePath, expression)
        
        // Elemental balance from all core numbers
        let balance = calculateElementalBalance(birthDate, name)
        
        return PersonalGeometry(...)
    }
}
```

**Number-to-Solid Mapping**:

| Life Path | Primary Solid | Secondary Solid | Sacred Pattern |
|-----------|---------------|-----------------|----------------|
| 1 | Tetrahedron (Fire) | Octahedron (Air) | Seed of Life |
| 2 | Icosahedron (Water) | Cube (Earth) | Flower of Life |
| 3 | Octahedron (Air) | Dodecahedron (Ether) | Tree of Life |
| 4 | Cube (Earth) | Icosahedron (Water) | Metatron's Cube |
| 5 | Octahedron (Air) | Tetrahedron (Fire) | Golden Spiral |
| 6 | Icosahedron (Water) | Dodecahedron (Ether) | Flower of Life |
| 7 | Dodecahedron (Ether) | Cube (Earth) | Tree of Life |
| 8 | Cube (Earth) | Tetrahedron (Fire) | Metatron's Cube |
| 9 | Tetrahedron (Fire) | Dodecahedron (Ether) | Seed of Life |
| 11 | Dodecahedron (Ether) | Octahedron (Air) | All Patterns* |
| 22 | Cube (Earth) | Dodecahedron (Ether) | All Patterns* |
| 33 | Icosahedron (Water) | Octahedron (Air) | All Patterns* |

*Master Numbers have access to all patterns but highlighted recommendations

#### 2.2 Personal Geometry Dashboard

**Layout**:
```
┌─────────────────────────────────┐
│  YOUR SACRED GEOMETRY           │
│                                 │
│     [3D Rotating Solid]         │
│        250x250pt                │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Life Path 7             │   │
│  │ Dominant: Dodecahedron  │   │
│  │ Element: Ether/Spirit   │   │
│  └─────────────────────────┘   │
│                                 │
│  Elemental Balance:            │
│  ████████░░ Fire (25%)         │
│  ████░░░░░░ Earth (15%)        │
│  ███░░░░░░░ Air (12%)          │
│  ██████░░░░ Water (20%)        │
│  ██████████ Ether (28%)        │
│                                 │
│  [View My Patterns] [AR Mode]  │
└─────────────────────────────────┘
```

#### 2.3 Geometry Birth Chart

**Visual**: 3D wheel with:
- Center: Dominant Platonic Solid (rotating)
- Inner ring: Elemental affinities (colored segments)
- Outer ring: Sacred patterns (touchable icons)
- Lines connecting related geometries

---

### 3. Daily Geometry Meditation

#### 3.1 Daily Geometric Alignment

**Calculation**:
```swift
func dailyGeometry(for date: Date, user: User) -> DailyGeometry {
    let personal = user.personalGeometry
    let dayNumber = NumerologyCalculator.personalDay(for: date, birthDate: user.birthDate)
    let universalDay = NumerologyCalculator.universalDay(for: date)
    
    // Today's resonant solid
    let dailySolid = platonicSolidForNumber((dayNumber + universalDay) % 9 + 1)
    
    // Pattern alignment
    let alignmentScore = calculateAlignment(personal.dominantSolid, dailySolid)
    
    // Recommended meditation
    let meditation = meditationForSolid(dailySolid, score: alignmentScore)
    
    return DailyGeometry(...)
}
```

**Daily Card UI**:
```
┌─────────────────────────────────┐
│  TODAY'S SACRED ALIGNMENT       │
│  Wednesday, March 11            │
│                                 │
│     [Animated Octahedron]       │
│                                 │
│  Today: Octahedron (Air)        │
│  Alignment: ████████░░ 82%      │
│                                 │
│  "A day for clear communication │
│   and intellectual pursuits"    │
│                                 │
│  [Start Meditation] [Learn]    │
└─────────────────────────────────┘
```

#### 3.2 Guided Meditation Flow

**Structure** (10-15 minutes):

| Phase | Duration | Visual | Audio |
|-------|----------|--------|-------|
| Grounding | 2 min | Breathing circle | Binaural beats (432Hz) |
| Introduction | 1 min | Pattern appears | Narrator explains geometry |
| Contemplation | 5 min | Slow rotation | Ambient tones + guidance |
| Integration | 2 min | Pattern glows brighter | Affirmations |
| Closing | 1 min | Fade to center point | Gentle bell |

**Voice**: Same narrator as numerology teachings (Shani or AI-cloned voice)

#### 3.3 Meditation Library

**Categories**:
- **By Pattern**: Seed of Life, Flower of Life, etc.
- **By Solid**: Element-specific meditations
- **By Intention**: Calm, Energy, Clarity, Connection
- **By Duration**: 5min, 10min, 15min, 20min

---

### 4. AR Geometry Overlay

#### 4.1 AR Mode Features

**Core Functionality**:
- Place sacred geometry in real environment
- Scale from 0.1m to 10m
- Lock to surface or free-float
- Screenshot/video capture
- Share to social media

**Placements**:
- Wall overlay (poster-like)
- Floor mandala
- Ceiling projection
- Floating in space
- Body aura overlay (front camera)

#### 4.2 AR UI Flow

```
┌─────────────────────────────────┐
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │    [Camera Preview]     │   │
│  │    with AR Geometry     │   │
│  │                         │   │
│  └─────────────────────────┘   │
│                                 │
│  [Pattern] [Size] [Lock] [📷]  │
│                                 │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐  │
│  │Seed│ │Flower│ │Tree│ │Meta│  │
│  └────┘ └────┘ └────┘ └────┘  │
└─────────────────────────────────┘
```

#### 4.3 AR Meditation Experience

**Immersive Mode**:
- Full-screen AR with guided meditation
- Geometry responds to breath (if Apple Watch connected)
- Spatial audio positioning
- Haptic feedback on phone

**Requirements**:
- ARKit 6.0+
- LiDAR preferred (better placement)
- iPhone 12+ or iPad Pro recommended

---

### 5. Geometry-Based Numerology

#### 5.1 Sacred Geometry Life Path Overlay

**Concept**: Visual representation of user's Life Path as geometric journey

**Visualization**:
- Life Path number determines starting geometry
- Major life events (user-inputted) as nodes on the path
- Current position highlighted
- Future potential paths shown as faint lines

**Interactive Elements**:
- Tap node → see life event + numerological significance
- Drag timeline → watch geometry evolve
- Pinch → zoom out to see full life pattern

#### 5.2 Numerology-Geometry Correspondence Table

| Core Number | Geometry | Interpretation |
|-------------|----------|----------------|
| Life Path | Dominant Solid | Soul's primary structure |
| Expression | Secondary Solid | How you manifest |
| Soul Urge | Internal pattern | Hidden desires |
| Personality | External pattern | How others see you |
| Birthday | Daily alignment | Special day energy |
| Maturity | Evolving solid | Growth trajectory |

---

### 6. Wallpaper/Background Generator

#### 6.1 Generator Features

**Input Options**:
- Personal geometry settings
- Color theme selection
- Complexity level (simple/medium/complex)
- Animation preference (still/subtle/dynamic)
- Aspect ratio (phone/tablet/desktop)

**Generation Options**:
- Static wallpaper (PNG)
- Live wallpaper (iOS Live Photo)
- Dynamic wallpaper (video loop)
- Watch face (Apple Watch)

#### 6.2 Preset Templates

| Template | Description | Best For |
|----------|-------------|----------|
| Minimal | Single solid, clean background | Focus, productivity |
| Cosmic | Pattern with starfield | Dreaming, inspiration |
| Mandala | Symmetrical, detailed | Meditation background |
| Flow | Golden spiral, organic | Creativity, movement |
| Portal | Tunnel effect | Deep meditation |

#### 6.3 Export Options

- Save to Photos
- Set directly as wallpaper
- Share to Instagram Stories (optimized format)
- Export for desktop (4K)
- Print-quality PDF (for physical meditation aids)

---

## Data Models

### Core Entities

```swift
// MARK: - Sacred Pattern
struct SacredPattern: Codable, Identifiable {
    let id: String // seed-of-life, flower-of-life, etc.
    let name: String
    let nameLocalized: [String: String]
    let description: String
    let symbolism: [String]
    let history: String
    let mathematics: MathematicalProperties
    let meditations: [MeditationID]
    let elementalResonance: [Element: Int] // 0-100
    let associatedNumbers: [Int]
    let arAsset: String // USDZ filename
    let previewAnimation: String // Lottie/MP4
}

// MARK: - Platonic Solid
struct PlatonicSolid: Codable, Identifiable {
    let id: String // tetrahedron, cube, octahedron, dodecahedron, icosahedron
    let name: String
    let element: Element
    let faces: Int
    let edges: Int
    let vertices: Int
    let description: String
    let properties: [String]
    let associatedNumbers: [Int]
    let arModel: String // USDZ filename
    let color: String // Hex color
}

// MARK: - Personal Geometry
struct PersonalGeometry: Codable {
    let userId: String
    let calculatedAt: Date
    let dominantSolid: PlatonicSolid
    let secondarySolid: PlatonicSolid
    let affinityScore: Double // 0.0-1.0 between primary/secondary
    let sacredPatterns: [SacredPatternAffinity]
    let elementalBalance: ElementalBalance
    let recommendedMeditations: [MeditationID]
    let birthChart: GeometryBirthChart
}

struct SacredPatternAffinity: Codable {
    let pattern: SacredPattern
    let affinityScore: Double // 0.0-1.0
    let reason: String // Why this pattern resonates
}

struct ElementalBalance: Codable {
    let fire: Double
    let earth: Double
    let air: Double
    let water: Double
    let ether: Double
    
    var dominant: Element {
        max(fire, earth, air, water, ether) // returns element with highest value
    }
}

// MARK: - Daily Geometry
struct DailyGeometry: Codable {
    let date: Date
    let universalSolid: PlatonicSolid
    let personalAlignment: PersonalAlignment
    let meditation: Meditation
    let affirmation: String
    let insight: String
}

struct PersonalAlignment: Codable {
    let score: Int // 0-100
    let description: String
    let recommendedAction: String
}

// MARK: - Geometry Meditation
struct GeometryMeditation: Codable, Identifiable {
    let id: String
    let title: String
    let pattern: SacredPattern?
    let solid: PlatonicSolid?
    let element: Element?
    let duration: TimeInterval
    let audioUrl: String
    let transcript: String
    let visualSequence: [VisualCue]
    let intention: String
    let difficulty: Difficulty
}

struct VisualCue: Codable {
    let timestamp: TimeInterval
    let animation: AnimationType
    let duration: TimeInterval
    let parameters: [String: Double]
}
```

---

## Integration Points

### With Numerology Module

| Integration | Description |
|-------------|-------------|
| Life Path → Solid | Core mapping for personal geometry |
| Daily Qode | Geometry aligned with daily numerology |
| Birth Chart | Geometry wheel alongside numerology wheel |
| Compatibility | Geometric compatibility between users |
| Forecasts | Geometry predictions alongside numerology |

### With User Profile

| Integration | Description |
|-------------|-------------|
| Birth Data | Reuses stored birth date/name |
| Avatar | Option to use sacred pattern as profile background |
| Stats | Track meditation minutes, patterns viewed |
| Achievements | "Geometry Master", "Meditation Streak" badges |

### With Notifications

| Notification Type | Trigger | Content |
|-------------------|---------|---------|
| Daily Geometry | 7:00 AM | Today's sacred alignment + meditation suggestion |
| Meditation Reminder | User-set | Time for your geometry practice |
| Pattern of the Day | 9:00 AM | Learn about a new sacred pattern |
| AR Discovery | Weekly | New AR placement suggestion |

### With Community

| Feature | Description |
|---------|-------------|
| Share Geometry | Post personal geometry to community |
| Group Meditations | Synchronized geometry meditations |
| Geometry Compatibility | Compare sacred patterns with friends |
| Challenges | "7 Days of Sacred Geometry" group challenge |

### With Subscription Tiers

| Feature | Free | Inner Circle | Initiate | Master |
|---------|------|--------------|----------|--------|
| View Patterns | 2 | All | All | All |
| Interactive 3D | Limited | Full | Full | Full |
| Personal Geometry | Basic | Full | Full | Full |
| Daily Meditation | 1/day | Unlimited | Unlimited | Unlimited |
| AR Mode | ❌ | ✅ | ✅ | ✅ |
| Wallpaper Gen | 1/week | Unlimited | Unlimited | Unlimited |
| Custom Colors | ❌ | ✅ | ✅ | ✅ |
| Export 4K | ❌ | ❌ | ✅ | ✅ |
| Live Wallpapers | ❌ | ❌ | ✅ | ✅ |

---

## Content Structure

### Content Inventory

| Content Type | Count | Format | Source |
|--------------|-------|--------|--------|
| Sacred Patterns | 6 | Interactive 3D | Procedural + USDZ |
| Platonic Solids | 5 | Interactive 3D | USDZ models |
| Guided Meditations | 30+ | Audio + Visual | Shani-recorded |
| Pattern Descriptions | 6 | Rich text | Shani-written |
| Historical Content | 6 | Scrollable timeline | Research-based |
| AR Placements | 10+ | USDZ + Anchors | Pre-configured |
| Wallpaper Templates | 20+ | Generative | Procedural |

### Content Management

**CMS Fields**:
- Pattern name (localized)
- Description (rich text)
- Symbolism (bullet list)
- History (markdown)
- Mathematics (interactive data)
- Meditation audio upload
- AR asset upload
- Color themes

---

## Technical Requirements

### Frameworks

| Framework | Purpose |
|-----------|---------|
| SceneKit | 3D geometry rendering |
| ARKit | Augmented reality features |
| Metal | Shader effects, particle systems |
| Core Animation | UI transitions, Lottie-style animations |
| ReplayKit | Screen recording for sharing |

### Performance Targets

| Metric | Target |
|--------|--------|
| 3D Rendering | 60fps on iPhone 12+ |
| AR Initialization | < 3 seconds |
| Pattern Load | < 1 second |
| Meditation Audio | Instant playback |
| Wallpaper Generation | < 5 seconds |

### Storage Requirements

| Asset Type | Size (MB) | CDN |
|------------|-----------|-----|
| 3D Models (USDZ) | 50 | Required |
| Audio Files | 100 | Required |
| Video Previews | 30 | Required |
| Generated Wallpapers | User device | N/A |

---

## UI/UX Specifications

### Navigation Structure

```
Sacred Geometry (Tab)
├── Explore (Default)
│   ├── Pattern Grid
│   ├── Interactive Viewer
│   └── Pattern Detail
├── My Geometry
│   ├── Personal Dashboard
│   ├── Birth Chart
│   └── Elemental Balance
├── Daily
│   ├── Today's Alignment
│   ├── Meditation Player
│   └── History
├── AR Mode
│   ├── Camera View
│   ├── Placement Tools
│   └── Gallery
└── Studio
    ├── Wallpaper Generator
    ├── Templates
    └── My Creations
```

### Color Application

| UI Element | Color | Notes |
|------------|-------|-------|
| Background | #0A0A0F | Consistent with app |
| Cards | #12121A | Slight lift |
| Primary Geometry | Dynamic | Based on element |
| Fire | #FF6B35 | Orange-red glow |
| Earth | #8B7355 | Brown-gold |
| Air | #E0E0E0 | Silver-white |
| Water | #4A90E2 | Blue-cyan |
| Ether | #D4AF37 | Gold (primary brand) |
| CTAs | #D4AF37 | Gold button |

### Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Screen Title | SF Pro Display | 28pt | Bold |
| Pattern Name | SF Pro Display | 24pt | Semibold |
| Section Header | SF Pro Text | 17pt | Semibold |
| Body Text | SF Pro Text | 15pt | Regular |
| Caption | SF Pro Text | 13pt | Regular |
| Geometry Labels | SF Pro Rounded | 20pt | Medium |

### Animations

| Interaction | Animation |
|-------------|-----------|
| Pattern Select | Scale 0.95 → 1.0, glow pulse |
| 3D Rotation | Smooth interpolation, momentum |
| Meditation Start | Fade in, geometry grows from center |
| AR Place | Scale up from 0, settle with bounce |
| Daily Refresh | Card flip, number count-up |

---

## Success Metrics

### Engagement

| Metric | Target |
|--------|--------|
| Weekly Active Users (Geometry) | 40% of total WAU |
| Avg Session Duration | 8 minutes |
| Meditations Completed/Week | 3 per user |
| AR Mode Usage | 20% of users try it |
| Wallpapers Generated | 2 per user/week |

### Retention

| Metric | Target |
|--------|--------|
| Daily Geometry Check | 30% of users |
| Meditation Streak (7+ days) | 15% of users |
| Return within 7 days | 60% |

### Business

| Metric | Target |
|--------|--------|
| Conversion to Paid (from free) | 8% |
| Premium Feature Usage | 70% of paid users |
| Social Shares | 1 per 5 users |
| Store Rating Impact | +0.2 stars |

---

## Future Enhancements (V3.3+)

1. **Sacred Sound**: Cymatics visualization (geometry from sound)
2. **Collaborative AR**: Multiple users see same geometry in shared space
3. **Geometry Therapy**: AI-guided sessions based on emotional state
4. **Custom Patterns**: User-generated sacred geometries
5. **Wearable Integration**: Haptic patterns matching geometries
6. **Print Integration**: Order physical sacred geometry prints

---

## Implementation Phases

### Phase 1: Foundation (Weeks 1-4)
- [ ] 3D rendering engine setup
- [ ] 6 sacred pattern models
- [ ] 5 platonic solid models
- [ ] Basic interactive viewer

### Phase 2: Personalization (Weeks 5-8)
- [ ] Personal geometry calculation
- [ ] Birth chart visualization
- [ ] Daily alignment algorithm
- [ ] Pattern detail screens

### Phase 3: Meditation (Weeks 9-12)
- [ ] Audio player integration
- [ ] 10 guided meditations
- [ ] Visual meditation sequences
- [ ] Progress tracking

### Phase 4: AR & Studio (Weeks 13-16)
- [ ] ARKit integration
- [ ] Placement system
- [ ] Wallpaper generator
- [ ] Export/sharing features

### Phase 5: Polish (Weeks 17-20)
- [ ] Performance optimization
- [ ] Accessibility audit
- [ ] Content completion (30 meditations)
- [ ] Beta testing

---

**Document Version**: 1.0
**Last Updated**: March 2026
**Author**: QodeX Product Team
**Reviewers**: Shani Ben-David, Asaf Kali
