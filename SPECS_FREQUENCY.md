# QodeX Frequency Work Module — Technical Specification

> **Version:** 1.0  
> **Status:** Draft  
> **Last Updated:** 2026-03-11  
> **Owner:** QodeX Product Team

---

## 1. Overview

The Frequency Work Module brings sound healing and vibrational therapy into the QodeX ecosystem. Members can access precisely-tuned frequencies for meditation, sleep, energy work, and personal alignment — all synchronized with their numerology and astrological profiles.

**Design Reference:** *Endel* for audio-first UI + *Insight Timer* for session depth + *Sonic Geometry* for visual aesthetics

---

## 2. Core Concepts

### 2.1 Solfeggio Frequencies
Ancient six-tone scale used in sacred music:

| Hz | Note | Chakra | Effect | Numerology |
|----|------|--------|--------|------------|
| 396 | Ut | Root | Liberating guilt & fear | 1 |
| 417 | Re | Sacral | Undoing situations & facilitating change | 2 |
| 528 | Mi | Solar Plexus | Transformation & miracles | 3 |
| 639 | Fa | Heart | Connecting & relationships | 4 |
| 741 | Sol | Throat | Expression & solutions | 5 |
| 852 | La | Third Eye | Returning to spiritual order | 6 |
| 963 | Si | Crown | Divine connection | 7 |

### 2.2 Binaural Beats
- Two slightly different frequencies played in each ear
- Brain perceives difference as a pulse
- Entrainment to specific brainwave states:
  - **Delta (0.5–4 Hz)** — Deep sleep, healing
  - **Theta (4–8 Hz)** — Meditation, creativity
  - **Alpha (8–13 Hz)** — Relaxation, flow
  - **Beta (13–30 Hz)** — Focus, alertness
  - **Gamma (30–100 Hz)** — Peak cognition

### 2.3 Schumann Resonance
- Earth's electromagnetic frequency: **7.83 Hz**
- Known as "Earth's heartbeat"
- Grounding and calming effects
- Associated with alpha brainwave state

### 2.4 Planetary Frequencies
Calculated frequencies based on orbital periods (using Cosmic Octave method by Hans Cousto):

| Planet | Frequency | Association | Numerology |
|--------|-----------|-------------|------------|
| Sun | 126.22 Hz | Light, vitality | 1 |
| Moon | 210.42 Hz | Emotions, cycles | 2 |
| Mercury | 141.27 Hz | Communication | 5 |
| Venus | 221.23 Hz | Love, beauty | 6 |
| Earth | 194.18 Hz | Grounding, centering | 4 |
| Mars | 144.72 Hz | Energy, action | 9 |
| Jupiter | 183.58 Hz | Expansion, growth | 3 |
| Saturn | 147.85 Hz | Structure, discipline | 8 |
| Uranus | 207.36 Hz | Innovation, awakening | 4 |
| Neptune | 211.44 Hz | Dreams, intuition | 7 |
| Pluto | 140.25 Hz | Transformation | 9 |

### 2.5 Numerology-Frequency Bridge
Each Life Path number has a resonant frequency profile:

| Life Path | Primary Frequency | Secondary | Chakra Focus |
|-----------|------------------|-----------|--------------|
| 1 | 396 Hz / 528 Hz | Sun (126.22 Hz) | Solar Plexus/Root |
| 2 | 417 Hz / 639 Hz | Moon (210.42 Hz) | Sacral/Heart |
| 3 | 528 Hz / 741 Hz | Jupiter (183.58 Hz) | Solar Plexus/Throat |
| 4 | 639 Hz / 852 Hz | Uranus (207.36 Hz) | Heart/Third Eye |
| 5 | 741 Hz / 396 Hz | Mercury (141.27 Hz) | Throat/Root |
| 6 | 852 Hz / 417 Hz | Venus (221.23 Hz) | Third Eye/Sacral |
| 7 | 963 Hz / 528 Hz | Neptune (211.44 Hz) | Crown/Solar Plexus |
| 8 | 396 Hz / 147.85 Hz | Saturn (147.85 Hz) | Root/(Earth) |
| 9 | 417 Hz / 144.72 Hz | Mars (144.72 Hz) | Sacral/(Action) |

---

## 3. Feature Specifications

### 3.1 Frequency Player

#### 3.1.1 Core Player Interface

```swift
struct FrequencyPlayerConfig {
    let frequency: Frequency
    let waveform: WaveformType // .sine, .square, .triangle, .sawtooth
    let volume: Double // 0.0 - 1.0
    let pan: Double // -1.0 (left) to 1.0 (right)
    let fadeInDuration: TimeInterval
    let fadeOutDuration: TimeInterval
}

enum FrequencyType {
    case solfeggio(SolfeggioFrequency)
    case binaural(BinauralConfig)
    case planetary(PlanetaryFrequency)
    case schumann
    case chakra(ChakraFrequency)
    case custom(Double) // User-defined Hz
}
```

**UI Components:**
- **Frequency Display:** Large Hz readout with animated waveform
- **Visual Feedback:** Sacred geometry visualization responding to audio
- **Playback Controls:** Play/Pause, timer preset buttons
- **Volume Slider:** With boost option (up to 150% system volume)
- **Background Mode:** Continue playing when app backgrounded

#### 3.1.2 Visual Visualization

**Sacred Geometry Modes:**
1. **Flower of Life** — Pulsing with bass frequencies
2. **Cymatics Patterns** — Simulated sand patterns
3. **Chakra Wheels** — Spinning colored wheels
4. **Planetary Orbits** — Animated orbital paths
5. **Waveform** — Real-time frequency visualization

**Visual Parameters:**
- Color coding by frequency range
- Pulse rate synced to binaural beat (if applicable)
- Intensity responsive to volume
- Optional: AR mode projecting visualization into space

#### 3.1.3 Timer System

```swift
struct PlaybackTimer {
    let duration: TimeInterval // 0 = infinite
    let fadeOutAtEnd: Bool
    let autoLockScreen: Bool
    let endAction: EndAction // .stop, .fade, .loop, .nextTrack
}

enum PresetDuration: TimeInterval {
    case quick = 300 // 5 min
    case short = 600 // 10 min
    case medium = 1200 // 20 min
    case long = 1800 // 30 min
    case deep = 3600 // 60 min
    case sleep = 28800 // 8 hours
}
```

**Timer UI:**
- Circular countdown timer
- Quick preset buttons (5, 10, 20, 30, 60 min)
- Custom duration picker
- "Until I stop" infinite mode
- Sleep timer with gradual fade

#### 3.1.4 Background Playback

**Capabilities:**
- Audio continues when app backgrounded
- Control Center integration (play/pause, skip)
- Lock screen widget with current frequency
- AirPlay support
- Bluetooth headphone optimization

**Battery Optimization:**
- Low-power mode reduces visualization
- Audio continues at minimum CPU usage
- Pause on headphone disconnect (optional)

---

### 3.2 Personal Frequency Profile

#### 3.2.1 Life Path Frequency Mapping

**Calculation:**
```swift
struct PersonalFrequencyProfile {
    let lifePath: Int
    let primaryFrequency: Frequency
    let secondaryFrequencies: [Frequency]
    let supportingChakra: Chakra
    let planetaryResonance: Planet
    let recommendedCombinations: [FrequencyCombo]
    
    static func generate(from numerologyProfile: NumerologyProfile) -> PersonalFrequencyProfile {
        let lifePath = numerologyProfile.lifePathNumber
        return PersonalFrequencyProfile(
            lifePath: lifePath,
            primaryFrequency: lifePathPrimaryMap[lifePath],
            secondaryFrequencies: lifePathSecondaryMap[lifePath],
            supportingChakra: lifePathChakraMap[lifePath],
            planetaryResonance: lifePathPlanetMap[lifePath],
            recommendedCombinations: generateCombos(for: lifePath)
        )
    }
}
```

#### 3.2.2 Profile Display

**UI Layout:**
```
┌─────────────────────────────────┐
│  Your Frequency Signature       │
│                                 │
│  [Animated Sacred Geometry]     │
│                                 │
│  Primary: 528 Hz (Mi)          │
│  Life Path 3 · Solar Plexus    │
│                                 │
│  ───────────────────────────   │
│  Supporting Frequencies:        │
│  • 741 Hz - Expression          │
│  • 183.58 Hz - Jupiter          │
│  • 7.83 Hz - Schumann           │
│                                 │
│  [Play My Signature]            │
└─────────────────────────────────┘
```

**Daily Recommendation:**
- "Today's Frequency" based on:
  - Personal profile
  - Current astrological transits
  - Moon phase
  - Day of week (numerology)

---

### 3.3 Chakra Balancing Sessions

#### 3.3.1 Chakra Assessment

**Self-Assessment Quiz:**
- 7 questions, one per chakra
- Rated 1-5 (blocked to open)
- Results generate imbalance score

**Chakra Quick Check:**
```swift
struct ChakraStatus {
    let chakra: Chakra
    let status: ChakraState // .blocked, .underactive, .balanced, .overactive
    let userRating: Int // 1-5
    let recommendedFrequencies: [Frequency]
    let color: Color
    let affirmation: String
}
```

#### 3.3.2 Balancing Session Types

**1. Single Chakra Focus (10-20 min)**
- One frequency continuously
- Matching color breathing exercise
- Chakra-specific affirmation

**2. Chakra Journey (30-60 min)**
- Sequential through all 7 chakras
- 4-5 minutes per chakra
- Gentle frequency transitions
- Guided visualization audio overlay

**3. Custom Balancing**
- User selects which chakras to address
- Custom time allocation
- Save favorite combinations

#### 3.3.3 Session Structure

```swift
struct ChakraSession {
    let name: String
    let description: String
    let sequence: [ChakraSegment]
    let totalDuration: TimeInterval
    let backgroundTrack: BackgroundTrack?
    let voiceGuidance: VoiceGuidance?
}

struct ChakraSegment {
    let chakra: Chakra
    let frequency: Frequency
    let duration: TimeInterval
    let color: Color
    let affirmation: String
    let breathingPattern: BreathingPattern?
}
```

---

### 3.4 Sleep Frequencies

#### 3.4.1 Sleep Programs

**Delta Deep Sleep (0.5–4 Hz binaural)**
- Drift-off mode: Gradual volume increase then sustained
- 8-hour continuous play
- No screen visualization (dark mode)
- Smart alarm: Wake during light sleep phase

**Sleep Enhancement Stack:**
```
Layer 1: 174 Hz (pain reduction, physical relaxation)
Layer 2: Delta binaural beat (3 Hz)
Layer 3: Pink noise (brain sync)
Layer 4: Optional: Schumann resonance (7.83 Hz)
```

**Dream Enhancement (Theta 4-8 Hz)**
- For lucid dreaming practice
- REM cycle optimization
- Dream journal integration

#### 3.4.2 Sleep Timer Features

- Fade out over last 10 minutes
- Auto-stop after set hours
- Resume on wake (if before alarm)
- Sleep quality rating in morning

---

### 3.5 Meditation Frequencies

#### 3.5.1 Meditation Presets

| Preset | Frequency | Duration | Purpose |
|--------|-----------|----------|---------|
| Grounding | 396 Hz + Schumann | 10 min | Earth connection |
| Creativity | 417 Hz + Theta | 15 min | Unlock blocks |
| Heart Opening | 639 Hz | 20 min | Compassion |
| Intuition | 852 Hz + Neptune | 15 min | Psychic development |
| Transcendence | 963 Hz + Crown | 30 min | Spiritual connection |

#### 3.5.2 Guided + Frequency

- Voice guidance overlay option
- Background music option (volumes mixable)
- Bell sounds at interval marks
- Silent gaps for personal meditation

---

### 3.6 Planetary Tuning

#### 3.6.1 Planetary Hour Alignment

**Integration with Astrology Module:**
- Current planetary hour detection
- Suggested planetary frequency for that hour
- "Tune into Saturn hour" notifications

**Planetary Day Associations:**
| Day | Planet | Frequency |
|-----|--------|-----------|
| Sunday | Sun | 126.22 Hz |
| Monday | Moon | 210.42 Hz |
| Tuesday | Mars | 144.72 Hz |
| Wednesday | Mercury | 141.27 Hz |
| Thursday | Jupiter | 183.58 Hz |
| Friday | Venus | 221.23 Hz |
| Saturday | Saturn | 147.85 Hz |

#### 3.6.2 Transit-Based Frequencies

- Saturn transit → Saturn frequency for grounding
- Mercury retrograde → Mercury frequency for clarity
- Full moon → Moon frequency for emotional balance
- Solar eclipse → Sun frequency for empowerment

---

### 3.7 Daily Recommended Frequency

#### 3.7.1 Algorithm

```swift
func calculateDailyFrequency(
    personalProfile: PersonalFrequencyProfile,
    astrology: DailyAstrology,
    dayOfWeek: DayOfWeek,
    userHistory: [FrequencySession]
) -> FrequencyRecommendation {
    
    // Base: Personal Life Path frequency
    var scores: [Frequency: Double] = [:]
    scores[personalProfile.primaryFrequency] = 1.0
    
    // Adjust for current transits
    for transit in astrology.majorTransits {
        let planetFreq = transit.planet.frequency
        scores[planetFreq, default: 0] += transit.intensity * 0.3
    }
    
    // Day of week numerology
    let dayNumber = dayOfWeek.numerologyNumber
    let dayFreq = Frequency.forNumber(dayNumber)
    scores[dayFreq, default: 0] += 0.5
    
    // Moon phase influence
    scores[astrology.moonPhase.suggestedFrequency, default: 0] += 0.4
    
    // Avoid recent frequencies (variety)
    for recent in userHistory.last(7) {
        scores[recent.frequency, default: 0] *= 0.8
    }
    
    let recommended = scores.max(by: { $0.value < $1.value })!.key
    
    return FrequencyRecommendation(
        frequency: recommended,
        reason: generateReason(scores, astrology),
        duration: suggestedDuration(for: recommended),
        context: buildContext(astrology, personalProfile)
    )
}
```

#### 3.7.2 Daily Card UI

```
┌─────────────────────────────────┐
│  Today's Frequency               │
│                                 │
│  [Sacred Geometry Animation]    │
│                                 │
│  639 Hz · Heart Chakra          │
│  Fa · Connecting & Healing      │
│                                 │
│  Why today:                     │
│  Venus transits your 7th house  │
│  + Personal Year 6 energy       │
│                                 │
│  Suggested: 15 minutes          │
│                                 │
│  [Play Now]  [Schedule]         │
└─────────────────────────────────┘
```

---

### 3.8 Offline Capability

#### 3.8.1 Asset Preloading

**Downloadable Content:**
- All base frequency tones (sine waves, generated locally)
- Background ambient tracks (compressed audio)
- Voice guidance tracks
- Sacred geometry visualization assets

**Storage Management:**
- Estimated size: ~500MB for full library
- Selective download by category
- Auto-delete unused after 30 days
- Priority: Personal profile frequencies first

#### 3.8.2 Offline Functionality

- Generate all frequencies locally (no streaming)
- Cached recommendations
- Last 7 days of daily suggestions
- Saved sessions playable without network

---

## 4. Audio Engineering Specifications

### 4.1 Tone Generation

#### 4.1.1 Solfeggio Tone Engine

```swift
import AVFoundation

class FrequencyEngine {
    private var audioEngine: AVAudioEngine
    private var toneGenerators: [Frequency: AVAudioSourceNode]
    
    func playFrequency(_ frequency: Double, waveform: WaveformType) {
        let sampleRate = audioEngine.mainMixerNode.outputFormat.sampleRate
        let phase = 0.0
        
        let sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                let time = Double(frame) / sampleRate
                let value = self.generateSample(
                    frequency: frequency,
                    time: time,
                    waveform: waveform
                )
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = Float(value)
                }
            }
            return noErr
        }
        
        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: audioEngine.mainMixerNode, format: format)
    }
    
    private func generateSample(frequency: Double, time: Double, waveform: WaveformType) -> Double {
        let phase = 2.0 * .pi * frequency * time
        
        switch waveform {
        case .sine:
            return sin(phase)
        case .square:
            return sin(phase) > 0 ? 1.0 : -1.0
        case .triangle:
            return asin(sin(phase)) * (2.0 / .pi)
        case .sawtooth:
            return 2.0 * (phase / (2.0 * .pi) - floor(phase / (2.0 * .pi) + 0.5))
        }
    }
}
```

#### 4.1.2 Binaural Beat Generation

```swift
struct BinauralConfig {
    let carrierFrequency: Double // Base frequency (usually 200-400 Hz)
    let beatFrequency: Double // Target brainwave frequency
    
    var leftFrequency: Double { carrierFrequency }
    var rightFrequency: Double { carrierFrequency + beatFrequency }
}

class BinauralEngine {
    func playBinaural(config: BinauralConfig) {
        // Generate left channel
        playFrequency(config.leftFrequency, channel: .left)
        // Generate right channel
        playFrequency(config.rightFrequency, channel: .right)
    }
}
```

### 4.2 Audio Quality

**Technical Specs:**
- Sample rate: 48kHz (native iOS)
- Bit depth: 32-bit float
- Frequency accuracy: ±0.01 Hz
- THD: < 0.1% (sine waves)

**Output Modes:**
- Standard: Single frequency, mono or stereo
- Binaural: Separate frequencies per ear (requires headphones)
- Isochronic: Pulsed single frequency (works on speakers)

### 4.3 Volume & Safety

**Safety Features:**
- Maximum volume limiter (85 dB SPL estimate)
- Hearing health warnings for extended use
- Rest reminders every 60 minutes
- Automatic volume reduction after 30 min at high levels

**Volume Controls:**
- System volume integration
- In-app gain control (-20 dB to +6 dB)
- Left/right balance for binaural
- Per-frequency volume memory

---

## 5. UI/UX Specifications

### 5.1 Navigation Structure

```
Frequency Tab
├── Today
│   ├── Daily Recommended Frequency
│   ├── Recently Played
│   └── Quick Access Grid
├── Library
│   ├── Solfeggio Frequencies
│   ├── Binaural Beats
│   ├── Planetary Tones
│   ├── Chakra Sessions
│   └── Sleep Programs
├── My Profile
│   ├── Personal Frequency Signature
│   ├── Session History
│   ├── Favorites
│   └── Stats
└── Player (Full Screen)
    ├── Visual Visualization
    ├── Frequency Info
    ├── Timer Controls
    └── Background/Settings
```

### 5.2 Visual Design

**Color Coding by Frequency:**
```swift
extension Frequency {
    var color: Color {
        switch self {
        case 174: return Color(hex: "#8B0000") // Deep red
        case 285: return Color(hex: "#FF4500") // Orange-red
        case 396: return Color(hex: "#FF0000") // Red
        case 417: return Color(hex: "#FF8C00") // Orange
        case 528: return Color(hex: "#FFD700") // Gold
        case 639: return Color(hex: "#00FF00") // Green
        case 741: return Color(hex: "#0080FF") // Blue
        case 852: return Color(hex: "#4B0082") // Indigo
        case 963: return Color(hex: "#9400D3") // Violet
        default: return Color(hex: "#FFFFFF") // White
        }
    }
    
    var chakraColor: Color {
        // Same as above mapped to chakras
    }
}
```

**Animation Principles:**
- Smooth, meditative pacing (no jarring movements)
- Breathing rhythm sync option (4-7-8 or custom)
- Particle effects responding to frequency
- Mandala rotation speed tied to Hz

### 5.3 Player Screen Layout

```
┌─────────────────────────────────────┐
│  Status Bar                          │
├─────────────────────────────────────┤
│                                     │
│                                     │
│     [Sacred Geometry Visualization] │
│     (Full screen, animated)         │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  528 Hz                             │
│  Solfeggio · Solar Plexus · Mi      │
│  🎵 417 Hz layered                  │
├─────────────────────────────────────┤
│  ◀◀  │  ●  │  ▶▶                   │
│                                     │
│  ━━━━━━━━━━━━●──── 15:32 / 20:00   │
├─────────────────────────────────────┤
│  [5m] [10m] [20m] [30m] [∞]        │
├─────────────────────────────────────┤
│  [Visual] [Mix] [Share] [Save]     │
└─────────────────────────────────────┘
```

---

## 6. Integration Points

### 6.1 Numerology Integration

| Integration | Implementation |
|-------------|----------------|
| Personal Profile | Auto-generate from Life Path number |
| Daily Frequency | Weight algorithm with Personal Year |
| Session Insights | Post-session reflection prompts based on numbers |
| Progress Tracking | Numerology-based milestones |

### 6.2 Astrology Integration

| Integration | Implementation |
|-------------|----------------|
| Planetary Hours | Auto-suggest current planetary frequency |
| Transit Alerts | "Saturn Retrograde → Tune to 147.85 Hz" |
| Moon Phases | Moon frequency on Full/New Moon |
| Natal Chart | Chakra imbalances based on chart aspects |

### 6.3 Journal Integration

- Post-session reflection prompt
- Mood tracking before/after
- Frequency-mood correlation insights
- "This frequency helped me..." entries

### 6.4 Community Integration

- Share frequency sessions
- Group listening rooms
- "Frequency of the day" discussions
- User-created frequency combinations

### 6.5 Health App Integration

- Mindful Minutes tracking
- Sleep analysis correlation
- Heart rate during sessions (if Apple Watch)
- Meditation streaks

---

## 7. Data Models

### 7.1 Core Entities

```swift
// MARK: - Frequency
struct Frequency: Codable, Hashable {
    let hz: Double
    let name: String
    let type: FrequencyType
    let description: String
    let benefits: [String]
    let chakra: Chakra?
    let numerologyNumber: Int?
    let planet: Planet?
    
    static let solfeggio396 = Frequency(
        hz: 396,
        name: "Ut",
        type: .solfeggio,
        description: "Liberating guilt and fear",
        benefits: ["Releases guilt", "Grounds energy", "Supports root chakra"],
        chakra: .root,
        numerologyNumber: 1,
        planet: .mars
    )
    // ... other static instances
}

// MARK: - Session
struct FrequencySession: Codable, Identifiable {
    let id: UUID
    let frequency: Frequency
    let startTime: Date
    let duration: TimeInterval
    let endReason: EndReason // .timer, .manual, .interruption
    let moodBefore: MoodRating?
    let moodAfter: MoodRating?
    let notes: String?
    let location: LocationContext?
}

// MARK: - Personal Profile
struct FrequencyProfile: Codable {
    let userId: String
    let lifePathNumber: Int
    let primaryFrequency: Frequency
    let secondaryFrequencies: [Frequency]
    let chakraAffinities: [Chakra: AffinityLevel]
    let planetaryResonances: [Planet: ResonanceStrength]
    let preferredWaveform: WaveformType
    let defaultDuration: TimeInterval
    let createdAt: Date
    let updatedAt: Date
}
```

### 7.2 API Contracts

**GET /frequency/profile/{userId}**
```json
{
  "lifePathNumber": 7,
  "primaryFrequency": {
    "hz": 963,
    "name": "Si",
    "chakra": "crown",
    "description": "Divine connection and enlightenment"
  },
  "secondaryFrequencies": [
    { "hz": 528, "name": "Mi", "chakra": "solar_plexus" },
    { "hz": 852, "name": "La", "chakra": "third_eye" }
  ],
  "planetaryResonance": {
    "planet": "neptune",
    "frequency": 211.44,
    "strength": "strong"
  }
}
```

**POST /frequency/session**
```json
{
  "frequencyHz": 528,
  "duration": 1200,
  "startTime": "2026-03-11T18:00:00Z",
  "moodBefore": 3,
  "moodAfter": 5,
  "context": "evening_meditation"
}
```

**GET /frequency/daily/{userId}**
```json
{
  "date": "2026-03-11",
  "recommendedFrequency": {
    "hz": 639,
    "name": "Fa",
    "chakra": "heart",
    "reason": "Venus in your 7th house + Personal Year 6 energy"
  },
  "alternativeOptions": [
    { "hz": 221.23, "name": "Venus Tone", "context": "For love and relationships" }
  ],
  "suggestedDuration": 900,
  "astrologyContext": {
    "transit": "venus_7th_house",
    "moonPhase": "waxing_gibbous"
  }
}
```

---

## 8. Technical Implementation

### 8.1 Dependencies

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/syedhali/AudioKit", from: "5.6.0"),
    .package(url: "https://github.com/airbnb/lottie-spm", from: "4.0.0"),
]
```

### 8.2 Audio Architecture

```
FrequencyWork/
├── Audio/
│   ├── FrequencyEngine.swift
│   ├── BinauralEngine.swift
│   ├── ToneGenerator.swift
│   └── AudioSessionManager.swift
├── Playback/
│   ├── PlayerViewModel.swift
│   ├── TimerManager.swift
│   └── BackgroundPlaybackManager.swift
├── Visualization/
│   ├── SacredGeometryView.swift
│   ├── WaveformView.swift
│   └── ChakraWheelView.swift
├── Sessions/
│   ├── SessionManager.swift
│   ├── ChakraSessionBuilder.swift
│   └── SleepProgramManager.swift
└── Profile/
    ├── FrequencyProfileService.swift
    ├── RecommendationEngine.swift
    └── SessionHistoryManager.swift
```

### 8.3 Audio Session Configuration

```swift
class AudioSessionManager {
    func configureForFrequencyPlayback() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetooth, .allowAirPlay]
            )
            try session.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }
    
    func configureForSleepPlayback() {
        // Disable screen, optimize for overnight
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
```

### 8.4 Caching & Storage

```swift
protocol FrequencyCache {
    func cacheSession(_ session: FrequencySession)
    func getSessionHistory(limit: Int) -> [FrequencySession]
    func cacheDailyRecommendation(_ recommendation: FrequencyRecommendation)
    func getLastRecommendation() -> FrequencyRecommendation?
}

// Core Data implementation
// Sync with backend when online
```

---

## 9. Content Structure

### 9.1 Frequency Descriptions

**Template:**
```markdown
# {{Frequency Name}} — {{Hz}} Hz

## Essence
[One sentence defining the frequency]

## Historical Context
[Origin and traditional use]

## Scientific Notes
[Research, studies, documented effects]

## Energetic Properties
- Chakra: {{Chakra}}
- Element: {{Element}}
- Planet: {{Planet}}
- Numerology: {{Number}}

## Benefits
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

## When to Use
[Appropriate contexts and situations]

## Pairing Suggestions
[Other frequencies that complement]

## Affirmation
"{{Matching affirmation}}"

## Duration Guidelines
- Quick reset: 5-10 minutes
- Deep work: 20-30 minutes
- Transformation: 60+ minutes
```

### 9.2 Session Scripts

**Chakra Journey Script:**
```
Welcome to your Chakra Balancing Journey.

We'll move through each energy center, spending about 
four minutes at each frequency.

[Root Chakra - 396 Hz]
Feel your connection to the earth beneath you...
Breathe in stability, breathe out tension...

[Sacral Chakra - 417 Hz]
Allow creativity to flow through you...
Embrace change and fluidity...

[Continue through all 7 chakras...]

Take a moment to feel the harmonized energy 
throughout your entire being...

Namaste.
```

---

## 10. Testing Requirements

### 10.1 Audio Testing

| Test | Method |
|------|--------|
| Frequency Accuracy | Frequency counter, spectrum analyzer |
| Binaural Separation | Isolated channel testing |
| Volume Consistency | SPL meter, consistent output |
| Battery Usage | Profile 1-hour session |
| Background Stability | 8-hour sleep session test |

### 10.2 Device Compatibility

- iPhone 12 and newer (primary)
- iPhone SE (performance baseline)
- iPad (optimized layout)
- AirPods/Bluetooth headphones
- External speakers

### 10.3 Accessibility

- VoiceOver support for all controls
- Dynamic Type support
- High contrast mode
- Reduce Motion option
- Hearing aid compatibility

---

## 11. Safety & Compliance

### 11.1 Health Disclaimers

**Required Disclaimers:**
- "Frequency therapy is complementary, not medical treatment"
- "Consult healthcare provider for medical conditions"
- "Do not use while driving or operating machinery"
- "Discontinue if discomfort occurs"

### 11.2 Volume Safety

- Default volume: 60% system
- Warning at 80% for >30 minutes
- Maximum: 90% with explicit override
- Hearing health tips in onboarding

### 11.3 Photosensitive Seizure Warning

- Warning for visualizations
- Option to disable animations
- Static mode available

---

## 12. Future Enhancements

### 12.1 V2 Features

- Custom frequency creator
- Frequency layering (up to 4 tones)
- User-generated sessions
- Biofeedback integration (Heart Rate)
- Haptic frequency (Taptic Engine patterns)
- Spatial Audio support

### 12.2 Advanced Audio

- Isochronic tones
- Monaural beats
- Polyphonic frequency compositions
- Entrainment progressions (start at X Hz, end at Y Hz over Z minutes)

### 12.3 Hardware Integration

- Apple Watch haptic feedback
- Oura Ring sleep correlation
- External EEG devices (Muse, etc.)
- Smart speaker integration (HomePod)

---

## 13. Appendix

### 13.1 Frequency Reference Tables

**Extended Solfeggio (9-tone):**
| Hz | Name | Purpose |
|----|------|---------|
| 174 | | Pain reduction, physical healing |
| 285 | | Tissue healing, energy field |
| 396 | Ut | Liberating guilt/fear |
| 417 | Re | Facilitating change |
| 528 | Mi | Transformation, DNA repair |
| 639 | Fa | Relationships, connection |
| 741 | Sol | Expression, solutions |
| 852 | La | Spiritual order |
| 963 | Si | Divine consciousness |

**Brainwave Entrainment Ranges:**
| State | Frequency | Best For |
|-------|-----------|----------|
| Epsilon | < 0.5 Hz | Deep meditation |
| Delta | 0.5–4 Hz | Sleep, healing |
| Theta | 4–8 Hz | Creativity, intuition |
| Alpha | 8–13 Hz | Relaxation, learning |
| Beta | 13–30 Hz | Focus, alertness |
| Gamma | 30–100 Hz | Peak performance |

### 13.2 Glossary

| Term | Definition |
|------|-----------|
| Binaural | Two different frequencies, one per ear |
| Carrier | Base frequency for binaural beat |
| Chakra | Energy center in subtle body |
| Entrainment | Synchronization to external rhythm |
| Hz | Hertz, cycles per second |
| Isochronic | Pulsed single-tone beats |
| Monaural | Mixed binaural tones, both ears |
| Solfeggio | Six-tone ancient musical scale |

---

*Document Version History:*
- v1.0 (2026-03-11) — Initial specification

