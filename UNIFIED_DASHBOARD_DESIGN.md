# QodeX Unified Dashboard & Navigation Design

**Version:** 2.0  
**Date:** 2026-03-11  
**Status:** Design Specification  

---

## Executive Summary

This document outlines the transformation of QodeX from a numerology-focused app to a unified spiritual platform integrating 9 esoteric disciplines. The new architecture emphasizes cross-system insights, progressive discovery, and a cohesive sacred geometry visual language.

---

## 1. NEW MAIN NAVIGATION STRUCTURE

### 1.1 Bottom Tab Bar (5 Items)

```
┌─────────────────────────────────────────────────────────────┐
│  ☀️ Today    🔷 Blueprint    🔮 Explore    🧘 Practice    ⚙️  │
│   (0)          (1)            (2)          (3)         (4)   │
└─────────────────────────────────────────────────────────────┘
```

| Tab | Icon | Name | Purpose |
|-----|------|------|---------|
| 0 | `sun.max.fill` | **Today** | Unified daily reading & morning briefing |
| 1 | `hexagon.fill` | **My Blueprint** | Personal spiritual profile across all systems |
| 2 | `sparkles.square.fill.on.square` | **Explore** | All 9 disciplines grid |
| 3 | `lotus.fill` | **Practice** | Tools, meditations, exercises |
| 4 | `gearshape.fill` | **Profile** | Settings, subscription, account |

### 1.2 Tab Bar Specifications

```swift
struct UnifiedTabBar: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(0)
            
            BlueprintView()
                .tabItem {
                    Label("Blueprint", systemImage: "hexagon.fill")
                }
                .tag(1)
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "sparkles.square.fill.on.square")
                }
                .tag(2)
            
            PracticeView()
                .tabItem {
                    Label("Practice", systemImage: "lotus.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Profile", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(QXColor.gold)
        .onChange(of: selectedTab) { oldValue, newValue in
            QXHaptic.lightImpact()
        }
    }
}
```

### 1.3 Migration from Current Tabs

| Current Tab | New Location | Migration Path |
|-------------|--------------|----------------|
| Home (Dashboard) | **Today** | Merge daily insight + expand to unified reading |
| Qode (Calculator) | **Explore** → Numerology card | Deep-link to calculator |
| Learn (Library) | **Practice** → Teachings | Reorganize content by discipline |
| Circle (Community) | **Blueprint** → Community insights | Premium feature highlight |
| Profile | **Profile** | Enhanced with Blueprint preview |

---

## 2. "TODAY" TAB - UNIFIED DAILY EXPERIENCE

### 2.1 Overview

The Today tab delivers a morning briefing synthesizing insights from all activated spiritual systems. It functions as the user's daily spiritual compass.

### 2.2 Screen Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  🌅 Good Morning, [Name]                        [Date]      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐    │
│  │  ☀️ TODAY'S SYNTHESIS                              │    │
│  │                                                     │    │
│  │  🔢 Personal Day 7    🌙 Moon in Scorpio           │    │
│  │  🃏 The Chariot        🎵 852 Hz                   │    │
│  │                                                     │    │
│  │  "Perfect day for introspection and                │    │
│  │   spiritual work"                                   │    │
│  │                                                     │    │
│  │  [✨ 3 Synchronicities Found]                       │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│  📊 YOUR SYSTEMS                                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │Numerology│ │Astrology │ │  Tarot   │ │Frequency │       │
│  │  Active  │ │  Locked  │ │  Locked  │ │  Locked  │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
├─────────────────────────────────────────────────────────────┤
│  ⭐ TODAY'S HIGHLIGHTS                                      │
│  • Numerology: 7 day = introspection, analysis              │
│  • Astrology: Moon-Pluto trine deepens emotional insight    │
│  • Tarot: The Chariot = willpower, determination            │
│  • Frequency: 852 Hz awakens intuition                      │
├─────────────────────────────────────────────────────────────┤
│  🎯 RECOMMENDED PRACTICE                                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🧘 15-Min Intuition Meditation (852 Hz)            │    │
│  │     Aligns with your 7 day + Chariot energy         │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Component Specifications

#### 2.3.1 Daily Synthesis Card

```swift
struct DailySynthesisCard: View {
    let synthesis: DailySynthesis
    @State private var isExpanded = false
    
    var body: some View {
        PremiumGlassCard {
            VStack(spacing: QXSpacing.lg) {
                // Header with date and cosmic weather
                HStack {
                    Label("Today's Synthesis", systemImage: "sparkles")
                        .font(QXFont.headline)
                        .foregroundStyle(QXColor.gold)
                    
                    Spacer()
                    
                    Text(synthesis.date.formatted(.dateTime.month().day()))
                        .font(QXFont.caption)
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
                
                // Active systems grid
                FlowLayout(spacing: 12) {
                    ForEach(synthesis.activeInsights) { insight in
                        SystemPill(insight: insight)
                    }
                }
                
                // Personalized message
                Text(synthesis.personalizedMessage)
                    .font(QXFont.body)
                    .foregroundStyle(QXColor.starlight.opacity(0.9))
                    .lineSpacing(6)
                
                // Synchronicities badge (if any)
                if synthesis.synchronicities.count > 0 {
                    SynchronicityBadge(count: synthesis.synchronicities.count)
                }
                
                // Expand for details
                DisclosureGroup("Detailed Insights") {
                    DetailedInsightsList(synthesis: synthesis)
                }
                .tint(QXColor.gold)
            }
        }
    }
}
```

#### 2.3.2 System Activation Grid

```swift
struct SystemActivationGrid: View {
    @EnvironmentObject var blueprintManager: BlueprintManager
    
    let systems: [SpiritualSystem] = [
        .numerology, .astrology, .tarot, .kabbalah,
        .sacredGeometry, .frequency, .alchemy, .playingCards, .sacredMath
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: QXSpacing.md) {
            Text("Your Systems")
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(systems) { system in
                    SystemActivationCard(
                        system: system,
                        isActive: blueprintManager.isSystemActive(system),
                        progress: blueprintManager.systemProgress(system)
                    )
                }
            }
        }
    }
}

struct SystemActivationCard: View {
    let system: SpiritualSystem
    let isActive: Bool
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isActive ? system.color.opacity(0.2) : QXColor.deepVoid)
                    .frame(width: 56, height: 56)
                
                Image(systemName: system.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isActive ? system.color : QXColor.starlight.opacity(0.3))
                
                if isActive && progress < 1.0 {
                    CircularProgressView(progress: progress)
                        .frame(width: 56, height: 56)
                }
                
                if !isActive {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                        .offset(x: 16, y: 16)
                }
            }
            
            Text(system.displayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isActive ? QXColor.starlight : QXColor.starlight.opacity(0.4))
                .lineLimit(1)
        }
    }
}
```

### 2.4 Data Model

```swift
struct DailySynthesis: Identifiable {
    let id: String
    let date: Date
    let activeInsights: [SystemInsight]
    let personalizedMessage: String
    let synchronicities: [Synchronicity]
    let recommendedPractice: RecommendedPractice?
}

struct SystemInsight: Identifiable {
    let id: String
    let system: SpiritualSystem
    let title: String
    let value: String
    let description: String
    let icon: String
}

struct Synchronicity: Identifiable {
    let id: String
    let type: SynchronicityType
    let systems: [SpiritualSystem]
    let message: String
    let significance: SignificanceLevel
}

enum SynchronicityType {
    case numberAlignment      // Same number across systems
    case elementalResonance   // Element matches
    case planetaryHarmony     // Planetary correspondence
    case archetypeMatch       // Same archetype (e.g., The Magician = Mercury)
}
```

---

## 3. "MY BLUEPRINT" TAB - PERSONAL PROFILE

### 3.1 Overview

My Blueprint is the user's complete spiritual profile, aggregating data from all 9 systems. It serves as their esoteric identity document and the foundation for cross-system insights.

### 3.2 Screen Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  🔷 MY BLUEPRINT                               [Edit]       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐    │
│  │  👤 [Avatar]                                        │    │
│  │  Sarah Chen                                         │    │
│  │  Born: March 15, 1985                               │    │
│  │                                                     │    │
│  │  🔢 Life Path 7  |  🌙 Scorpio Moon  |  🃏 Chariot   │    │
│  │                                                     │    │
│  │  [View Full Chart] [Share]                          │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│  🔗 CROSS-SYSTEM INSIGHTS                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Your 7 Life Path resonates with:                   │    │
│  │  • Saturn (discipline, wisdom)                      │    │
│  │  • Binah (understanding)                            │    │
│  │  • The Chariot (spiritual victory)                  │    │
│  │  • 852 Hz frequency                                 │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│  📋 COMPLETE PROFILE                                        │
│                                                             │
│  🔢 NUMEROLOGY                    [View Full]               │
│  • Life Path: 7 (The Seeker)                                │
│  • Expression: 9 (The Humanitarian)                         │
│  • Soul Urge: 3 (The Creative)                              │
│                                                             │
│  🌟 ASTROLOGY                     [Unlock]                  │
│  • Sun: Pisces  |  Moon: Scorpio  |  Rising: Virgo          │
│  • Personal planets calculated                              │
│                                                             │
│  🌳 KABBALAH                      [Unlock]                  │
│  • Personal Sephirot: Tiferet                               │
│  • Pathworking: Available                                   │
│                                                             │
│  🃏 TAROT                         [Unlock]                  │
│  • Birth Cards: Chariot / Tower                             │
│  • Soul Card: The Hermit                                    │
│                                                             │
│  🔥 ALCHEMY                       [Unlock]                  │
│  • Dominant Element: Water                                  │
│  • Magnum Opus Stage: Calcination                           │
│                                                             │
│  [Additional systems...]                                    │
├─────────────────────────────────────────────────────────────┤
│  📊 PROFILE COMPLETION: 35%                                 │
│  Add birth time for astrology → +20%                        │
│  Complete alchemy assessment → +15%                         │
└─────────────────────────────────────────────────────────────┘
```

### 3.3 Component Specifications

#### 3.3.1 Blueprint Header

```swift
struct BlueprintHeader: View {
    @EnvironmentObject var blueprintManager: BlueprintManager
    
    var body: some View {
        PremiumGlassCard {
            VStack(spacing: QXSpacing.lg) {
                // Avatar with sacred geometry ring
                ZStack {
                    // Animated geometry ring
                    SacredGeometryRing()
                        .frame(width: 120, height: 120)
                    
                    // Avatar
                    Circle()
                        .fill(QXColor.sacredGeometry)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(blueprintManager.userInitials)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(QXColor.gold)
                        )
                    
                    // Completion badge
                    CompletionBadge(percentage: blueprintManager.completionPercentage)
                        .offset(x: 35, y: 35)
                }
                
                // User info
                VStack(spacing: 4) {
                    Text(blueprintManager.userName)
                        .font(QXFont.title)
                        .foregroundStyle(QXColor.starlight)
                    
                    Text("Born: \(blueprintManager.formattedBirthDate)")
                        .font(QXFont.body)
                        .foregroundStyle(QXColor.starlight.opacity(0.6))
                }
                
                // Primary signatures
                FlowLayout(spacing: 8) {
                    PrimarySignatureChip(
                        icon: "number.circle.fill",
                        value: "Life Path \(blueprintManager.lifePathNumber)",
                        color: .cosmicPurple
                    )
                    
                    if let moonSign = blueprintManager.moonSign {
                        PrimarySignatureChip(
                            icon: "moon.fill",
                            value: "\(moonSign) Moon",
                            color: .nebulaBlue
                        )
                    }
                    
                    if let birthCard = blueprintManager.birthCard {
                        PrimarySignatureChip(
                            icon: "suit.club.fill",
                            value: birthCard.name,
                            color: .gold
                        )
                    }
                }
                
                // Action buttons
                HStack(spacing: QXSpacing.md) {
                    Button("View Full Chart") {
                        // Navigate to detailed chart
                    }
                    .buttonStyle(QXSecondaryButtonStyle())
                    
                    Button("Share") {
                        // Share blueprint
                    }
                    .buttonStyle(QXSecondaryButtonStyle())
                }
            }
            .padding()
        }
    }
}
```

#### 3.3.2 Cross-System Insights

```swift
struct CrossSystemInsightsCard: View {
    @EnvironmentObject var correspondenceEngine: CorrespondenceEngine
    let primaryNumber: Int
    
    var body: some View {
        PremiumGlassCard {
            VStack(alignment: .leading, spacing: QXSpacing.md) {
                Label("Cross-System Insights", systemImage: "link")
                    .font(QXFont.headline)
                    .foregroundStyle(QXColor.gold)
                
                Text("Your \(primaryNumber) Life Path resonates with:")
                    .font(QXFont.body)
                    .foregroundStyle(QXColor.starlight.opacity(0.8))
                
                let correspondences = correspondenceEngine.correspondences(forNumber: primaryNumber)
                
                VStack(alignment: .leading, spacing: QXSpacing.sm) {
                    CorrespondenceRow(
                        icon: "circle.hexagongrid.fill",
                        label: "Planet",
                        value: correspondences.planet.name
                    )
                    
                    CorrespondenceRow(
                        icon: "tree.fill",
                        label: "Sephira",
                        value: correspondences.sephira.name
                    )
                    
                    CorrespondenceRow(
                        icon: "suit.club.fill",
                        label: "Tarot",
                        value: correspondences.tarotCard.name
                    )
                    
                    CorrespondenceRow(
                        icon: "waveform",
                        label: "Frequency",
                        value: correspondences.frequency.hzFormatted
                    )
                    
                    CorrespondenceRow(
                        icon: "flame.fill",
                        label: "Element",
                        value: correspondences.element.name
                    )
                }
            }
            .padding()
        }
    }
}
```

### 3.4 Data Model

```swift
struct Blueprint: Identifiable, Codable {
    let id: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    // Core birth data
    let birthDate: Date
    let birthTime: Date?
    let birthLocation: Location?
    
    // System-specific profiles
    var numerologyProfile: NumerologyProfile?
    var astrologyProfile: AstrologyProfile?
    var kabbalahProfile: KabbalahProfile?
    var tarotProfile: TarotProfile?
    var alchemyProfile: AlchemyProfile?
    var sacredGeometryProfile: SacredGeometryProfile?
    var frequencyProfile: FrequencyProfile?
    var playingCardsProfile: PlayingCardsProfile?
    var sacredMathProfile: SacredMathProfile?
}

struct NumerologyProfile: Codable {
    let lifePathNumber: Int
    let expressionNumber: Int
    let soulUrgeNumber: Int
    let personalityNumber: Int
    let birthdayNumber: Int
    let maturityNumber: Int
    let personalYear: Int
    let personalMonth: Int
    let personalDay: Int
    let challengeNumbers: [Int]
    let pinnacleNumbers: [Int]
}

struct AstrologyProfile: Codable {
    let sunSign: ZodiacSign
    let moonSign: ZodiacSign
    let risingSign: ZodiacSign
    let mercurySign: ZodiacSign
    let venusSign: ZodiacSign
    let marsSign: ZodiacSign
    let jupiterSign: ZodiacSign
    let saturnSign: ZodiacSign
    let houses: [HousePlacement]
    let aspects: [Aspect]
    let natalChartSVG: String?
}
```

---

## 4. "EXPLORE" TAB - ALL DISCIPLINES

### 4.1 Overview

Explore presents all 9 disciplines as a unified grid, with progress tracking and quick access to each system's core features.

### 4.2 Screen Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  🔮 EXPLORE                                                 │
│  Discover the 9 paths to spiritual insight                  │
├─────────────────────────────────────────────────────────────┤
│  🔥 FEATURED: SACRED GEOMETRY                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  [Sacred Geometry Animation]                        │    │
│  │  Unlock the patterns that shape reality             │    │
│  │  [Start Learning]                                   │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│  📚 ALL DISCIPLINES                                         │
│                                                             │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐              │
│  │   🔢       │ │    🌟      │ │    🌳      │              │
│  │Numerology  │ │ Astrology  │ │  Kabbalah  │              │
│  │            │ │            │ │            │              │
│  │ ★ Included │ │   🔒 Pro   │ │   🔒 Pro   │              │
│  └────────────┘ └────────────┘ └────────────┘              │
│                                                             │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐              │
│  │    🃏      │ │     ✦      │ │    🎵      │              │
│  │   Tarot    │ │Sacred Geo  │ │  Frequency │              │
│  │            │ │            │ │            │              │
│  │   🔒 Pro   │ │   🔒 Pro   │ │   🔒 Pro   │              │
│  └────────────┘ └────────────┘ └────────────┘              │
│                                                             │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐              │
│  │    π       │ │    🔥      │ │    🂡      │              │
│  │Sacred Math │ │  Alchemy   │ │Playing C.  │              │
│  │            │ │            │ │            │              │
│  │   🔒 Pro   │ │   🔒 Pro   │ │   🔒 Pro   │              │
│  └────────────┘ └────────────┘ └────────────┘              │
├─────────────────────────────────────────────────────────────┤
│  🎯 QUICK ACTIONS                                           │
│  [Calculate] [Daily Draw] [Meditate] [Journal]              │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Component Specifications

#### 4.3.1 Discipline Grid

```swift
struct ExploreView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = ExploreViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: QXSpacing.xl) {
                // Featured discipline
                FeaturedDisciplineCard(
                    discipline: viewModel.featuredDiscipline
                )
                
                // All disciplines grid
                VStack(alignment: .leading, spacing: QXSpacing.md) {
                    Text("All Disciplines")
                        .font(QXFont.headline)
                        .foregroundStyle(QXColor.starlight)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(SpiritualSystem.allCases) { system in
                            DisciplineCard(
                                system: system,
                                isIncluded: system.isIncluded,
                                isLocked: !subscriptionManager.canAccessSystem(system),
                                progress: viewModel.progress(for: system)
                            )
                        }
                    }
                }
                
                // Quick actions
                QuickActionsBar()
            }
            .padding()
        }
        .background(QXColor.cosmicBlack.ignoresSafeArea())
    }
}

struct DisciplineCard: View {
    let system: SpiritualSystem
    let isIncluded: Bool
    let isLocked: Bool
    let progress: Double
    
    var body: some View {
        Button(action: {
            if isLocked {
                // Show paywall
            } else {
                // Navigate to system
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isIncluded ? system.color.opacity(0.2) : QXColor.deepVoid)
                        .frame(height: 100)
                    
                    Image(systemName: system.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(isIncluded ? system.color : QXColor.starlight.opacity(0.4))
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(QXColor.starlight.opacity(0.6))
                            .offset(x: 30, y: -30)
                    }
                    
                    if progress > 0 && !isLocked {
                        CircularProgressView(progress: progress)
                            .frame(width: 100, height: 100)
                    }
                }
                
                Text(system.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isIncluded ? QXColor.starlight : QXColor.starlight.opacity(0.5))
                
                // Status badge
                Text(isIncluded ? "Included" : (isLocked ? "Pro" : "Active"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isIncluded ? QXColor.gold : (isLocked ? QXColor.starlight.opacity(0.4) : system.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isIncluded ? QXColor.gold.opacity(0.2) : (isLocked ? QXColor.deepVoid : system.color.opacity(0.2)))
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

### 4.4 Discipline Specifications

| # | System | Icon | Color | Included In | Unlock Tier |
|---|--------|------|-------|-------------|-------------|
| 1 | Numerology | `number.circle.fill` | Cosmic Purple | Free | — |
| 2 | Astrology | `star.circle.fill` | Nebula Blue | Pro | Seeker+ |
| 3 | Kabbalah | `tree.fill` | Emerald | Pro | Seeker+ |
| 4 | Tarot | `suit.club.fill` | Gold | Pro | Seeker+ |
| 5 | Sacred Geometry | `hexagon.fill` | Violet | Pro | Initiate+ |
| 6 | Frequency Work | `waveform` | Cyan | Pro | Initiate+ |
| 7 | Sacred Mathematics | `function` | Amber | Pro | Initiate+ |
| 8 | Alchemy | `flame.fill` | Rust | Pro | Initiate+ |
| 9 | Playing Cards | `rectangle.on.rectangle` | Teal | Pro | Seeker+ |

---

## 5. "PRACTICE" TAB - TOOLS

### 5.1 Overview

Practice is the user's toolkit for spiritual work—meditations, card draws, calculators, and journaling—all organized by function rather than discipline.

### 5.2 Screen Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  🧘 PRACTICE                                                │
│  Tools for your spiritual journey                           │
├─────────────────────────────────────────────────────────────┤
│  🔥 CONTINUE PRACTICE                                       │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🎵 852 Hz Meditation (In Progress - 8:32/15:00)    │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│  🎯 DAILY PRACTICES                                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │  🧘‍♀️     │ │  🫁      │ │  👁️      │ │  ✍️      │       │
│  │Meditate  │ │ Breathe  │ │Visualize │ │ Journal  │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
├─────────────────────────────────────────────────────────────┤
│  ⚡ QUICK TOOLS                                             │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🃏 Card Draw                                         │    │
│  │     Tarot, Oracle, Playing Cards                      │    │
│  │     [Daily Card] [Three Card] [Celtic Cross]          │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🎵 Frequency Player                                  │    │
│  │     Solfeggio & planetary tones                       │    │
│  │     [174 Hz] [417 Hz] [528 Hz] [639 Hz] [741 Hz] [852 Hz]│
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🔢 Calculators                                       │    │
│  │     • Numerology Calculator                           │    │
│  │     • Planetary Hours                                 │    │
│  │     • Compatibility Check                             │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│  📚 GUIDED PRACTICES                                        │
│  • Morning Alignment Ritual (15 min)                        │
│  • Evening Release Meditation (20 min)                      │
│  • Full Moon Ceremony Guide                                 │
│  • Mercury Retrograde Survival Kit                          │
└─────────────────────────────────────────────────────────────┘
```

### 5.3 Component Specifications

#### 5.3.1 Meditation Library

```swift
struct MeditationLibraryView: View {
    @StateObject private var viewModel = MeditationLibraryViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: QXSpacing.lg) {
            Text("Meditation Library")
                .font(QXFont.headline)
                .foregroundStyle(QXColor.starlight)
            
            // Filter by category
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(title: "All", isSelected: viewModel.selectedCategory == nil)
                    ForEach(MeditationCategory.allCases) { category in
                        FilterChip(
                            title: category.displayName,
                            isSelected: viewModel.selectedCategory == category
                        )
                    }
                }
            }
            
            // Meditation grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.filteredMeditations) { meditation in
                    MeditationCard(meditation: meditation)
                }
            }
        }
    }
}

enum MeditationCategory: String, CaseIterable, Identifiable {
    case frequency = "frequency"
    case elemental = "elemental"
    case sephira = "sephira"
    case planetary = "planetary"
    case tarot = "tarot"
    case chakra = "chakra"
    
    var displayName: String {
        switch self {
        case .frequency: return "By Frequency"
        case .elemental: return "By Element"
        case .sephira: return "By Sephira"
        case .planetary: return "By Planet"
        case .tarot: return "By Tarot"
        case .chakra: return "By Chakra"
        }
    }
}
```

#### 5.3.2 Frequency Player

```swift
struct FrequencyPlayerView: View {
    @StateObject private var player = FrequencyPlayer()
    
    let frequencies = [
        Frequency(hz: 174, name: "Pain Relief", element: .earth, chakra: .root),
        Frequency(hz: 285, name: "Healing Tissue", element: .earth, chakra: .sacral),
        Frequency(hz: 396, name: "Liberation", element: .earth, chakra: .root),
        Frequency(hz: 417, name: "Change", element: .water, chakra: .sacral),
        Frequency(hz: 528, name: "Miracle", element: .fire, chakra: .solarPlexus),
        Frequency(hz: 639, name: "Connection", element: .air, chakra: .heart),
        Frequency(hz: 741, name: "Expression", element: .ether, chakra: .throat),
        Frequency(hz: 852, name: "Intuition", element: .light, chakra: .thirdEye),
        Frequency(hz: 963, name: "Enlightenment", element: .light, chakra: .crown)
    ]
    
    var body: some View {
        VStack(spacing: QXSpacing.xl) {
            // Visualizer
            FrequencyVisualizer(
                isPlaying: player.isPlaying,
                frequency: player.currentFrequency
            )
            .frame(height: 200)
            
            // Current frequency display
            VStack(spacing: 8) {
                Text("\(player.currentFrequency?.hz ?? 0) Hz")
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundStyle(QXColor.starlight)
                
                Text(player.currentFrequency?.name ?? "Select a frequency")
                    .font(QXFont.headline)
                    .foregroundStyle(QXColor.gold)
                
                if let frequency = player.currentFrequency {
                    HStack(spacing: 16) {
                        Label(frequency.element.name, systemImage: "flame.fill")
                        Label(frequency.chakra.name, systemImage: "circle.fill")
                    }
                    .font(QXFont.caption)
                    .foregroundStyle(QXColor.starlight.opacity(0.6))
                }
            }
            
            // Frequency grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(frequencies) { freq in
                    FrequencyButton(
                        frequency: freq,
                        isActive: player.currentFrequency?.id == freq.id,
                        isPlaying: player.isPlaying
                    ) {
                        player.selectFrequency(freq)
                    }
                }
            }
            
            // Playback controls
            HStack(spacing: QXSpacing.xl) {
                Button(action: { player.previous() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 24))
                }
                
                Button(action: { player.togglePlay() }) {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                }
                
                Button(action: { player.next() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 24))
                }
            }
            .foregroundStyle(QXColor.gold)
        }
        .padding()
    }
}
```

---

## 6. UNIFIED CONTENT SYSTEM

### 6.1 Correspondence Engine

The Correspondence Engine is the core intelligence layer mapping relationships between all 9 systems.

#### 6.1.1 Master Correspondence Table

| Number | Planet | Sephira | Tarot Card | Frequency | Element | Chakra | Zodiac | Alchemical |
|--------|--------|---------|------------|-----------|---------|--------|--------|------------|
| 0 | Pluto | Da'at | Fool | — | Void | — | Scorpio | Prima Materia |
| 1 | Sun | Kether | Magician | 528 Hz | Fire | Solar Plexus | Leo | Calcination |
| 2 | Moon | Chokmah | High Priestess | 417 Hz | Water | Sacral | Cancer | Dissolution |
| 3 | Jupiter | Binah | Empress | 528 Hz | Fire/Water | Solar Plexus | Sag/Pisces | Separation |
| 4 | Uranus | Chesed | Emperor | 639 Hz | Air | Heart | Aquarius | Conjunction |
| 5 | Mercury | Geburah | Hierophant | 741 Hz | Ether | Throat | Gemini/Virgo | Fermentation |
| 6 | Venus | Tiferet | Lovers | 639 Hz | Air/Earth | Heart | Taurus/Libra | Distillation |
| 7 | Saturn | Netzach | Chariot | 852 Hz | Light | Third Eye | Capricorn | Coagulation |
| 8 | Mars | Hod | Strength | 852 Hz | Fire | Solar Plexus | Aries/Scorpio | — |
| 9 | Neptune | Yesod | Hermit | 174 Hz | Water | Sacral | Pisces | — |
| 10 | — | Malkuth | Wheel of Fortune | — | Earth | Root | — | Philosopher's Stone |
| 11 | — | — | Justice | — | — | — | — | — |
| 12 | — | — | Hanged Man | — | — | — | — | — |

#### 6.1.2 Implementation

```swift
class CorrespondenceEngine: ObservableObject {
    static let shared = CorrespondenceEngine()
    
    // Master correspondence database
    private let correspondences: [Int: SystemCorrespondence] = [
        1: SystemCorrespondence(
            number: 1,
            planet: .sun,
            sephira: .kether,
            tarotCard: .magician,
            frequency: 528,
            element: .fire,
            chakra: .solarPlexus,
            zodiacSigns: [.leo],
            keywords: ["beginning", "creation", "individuality", "leadership"],
            affirmation: "I am the creator of my reality."
        ),
        2: SystemCorrespondence(
            number: 2,
            planet: .moon,
            sephira: .chokmah,
            tarotCard: .highPriestess,
            frequency: 417,
            element: .water,
            chakra: .sacral,
            zodiacSigns: [.cancer],
            keywords: ["duality", "balance", "intuition", "receptivity"],
            affirmation: "I trust my inner wisdom."
        ),
        // ... additional correspondences
    ]
    
    func correspondence(forNumber number: Int) -> SystemCorrespondence? {
        return correspondences[number]
    }
    
    func correspondence(forPlanet planet: Planet) -> SystemCorrespondence? {
        return correspondences.values.first { $0.planet == planet }
    }
    
    func correspondence(forSephira sephira: Sephira) -> SystemCorrespondence? {
        return correspondences.values.first { $0.sephira == sephira }
    }
    
    func correspondence(forTarotCard card: TarotCard) -> SystemCorrespondence? {
        return correspondences.values.first { $0.tarotCard == card }
    }
    
    func findSynchronicities(in blueprint: Blueprint) -> [Synchronicity] {
        var synchronicities: [Synchronicity] = []
        
        // Check for number alignment
        if let numerology = blueprint.numerologyProfile {
            let numbers = [
                numerology.lifePathNumber,
                numerology.expressionNumber,
                numerology.soulUrgeNumber
            ]
            
            for number in Set(numbers) {
                let count = numbers.filter { $0 == number }.count
                if count >= 2 {
                    synchronicities.append(Synchronicity(
                        id: UUID().uuidString,
                        type: .numberAlignment,
                        systems: [.numerology],
                        message: "Your \(number) appears \(count) times in your core numbers, amplifying its influence.",
                        significance: count == 3 ? .major : .minor
                    ))
                }
            }
        }
        
        // Check cross-system correspondences
        if let numerology = blueprint.numerologyProfile,
           let astrology = blueprint.astrologyProfile {
            if let numCorrespondence = correspondence(forNumber: numerology.lifePathNumber),
               numCorrespondence.planet.rulingSigns.contains(astrology.sunSign) {
                synchronicities.append(Synchronicity(
                    id: UUID().uuidString,
                    type: .planetaryHarmony,
                    systems: [.numerology, .astrology],
                    message: "Your Life Path \(numerology.lifePathNumber) and Sun in \(astrology.sunSign) share \(numCorrespondence.planet.name) energy.",
                    significance: .major
                ))
            }
        }
        
        return synchronicities
    }
    
    func generateInsight(for item: CorrespondenceItem) -> String {
        switch item {
        case .number(let n):
            guard let corr = correspondence(forNumber: n) else { return "" }
            return "\(n) corresponds to: \(corr.planet.name), \(corr.sephira.name), \(corr.tarotCard.displayName), \(corr.frequency) Hz, \(corr.element.name) element, \(corr.chakra.name) chakra"
        case .planet(let p):
            guard let corr = correspondence(forPlanet: p) else { return "" }
            return "\(p.name) corresponds to Number \(corr.number), \(corr.sephira.name), \(corr.tarotCard.displayName), \(corr.frequency) Hz"
        case .tarotCard(let c):
            guard let corr = correspondence(forTarotCard: c) else { return "" }
            return "\(c.displayName) corresponds to Number \(corr.number), \(corr.planet.name), \(corr.sephira.name), \(corr.frequency) Hz"
        default:
            return ""
        }
    }
}

struct SystemCorrespondence {
    let number: Int
    let planet: Planet
    let sephira: Sephira
    let tarotCard: TarotCard
    let frequency: Int
    let element: Element
    let chakra: Chakra
    let zodiacSigns: [ZodiacSign]
    let keywords: [String]
    let affirmation: String
}
```

### 6.2 Insight Generator

```swift
struct InsightGenerator {
    static func generateDailyInsight(for blueprint: Blueprint, on date: Date) -> String {
        let numerology = blueprint.numerologyProfile
        let astrology = blueprint.astrologyProfile
        
        var components: [String] = []
        
        // Numerology component
        if let personalDay = numerology?.personalDay {
            components.append("Today is a \(personalDay) Personal Day")
        }
        
        // Astrology component
        if let moonSign = astrology?.moonSign {
            components.append("Moon in \(moonSign.displayName)")
        }
        
        // Tarot component
        let dayCard = calculateDayCard(for: date)
        components.append("your card is \(dayCard.displayName)")
        
        // Frequency component
        if let personalDay = numerology?.personalDay,
           let corr = CorrespondenceEngine.shared.correspondence(forNumber: personalDay) {
            components.append("recommended frequency \(corr.frequency) Hz")
        }
        
        // Activity recommendation
        let activity = recommendActivity(for: numerology?.personalDay, moonSign: astrology?.moonSign)
        
        return components.joined(separator: ", ") + ". " + activity
    }
    
    private static func recommendActivity(for personalDay: Int?, moonSign: ZodiacSign?) -> String {
        guard let day = personalDay else { return "Trust your intuition today." }
        
        switch day {
        case 1, 5, 9:
            return "A powerful day for new beginnings and taking initiative."
        case 2, 6:
            return "Perfect for partnerships, nurturing, and emotional connection."
        case 3, 7:
            return "Ideal for introspection, spiritual work, and creative expression."
        case 4, 8:
            return "Focus on building foundations and practical achievements."
        default:
            return "Trust your intuition today."
        }
    }
}
```

---

## 7. UI/UX DESIGN SPECIFICATIONS

### 7.1 Visual Design System

#### 7.1.1 Sacred Geometry Visual Theme

The app uses sacred geometry as the unifying visual language:

- **Primary motif**: Flower of Life pattern (subtle background)
- **Dividers**: Golden ratio spirals or vesica piscis
- **Icons**: Hexagonal containers for tab icons
- **Cards**: Subtle corner radii based on φ (1.618)
- **Animations**: Rotating Metatron's cube for loading states

```swift
// Sacred geometry background pattern
struct SacredGeometryBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                QXColor.cosmicBlack
                
                // Subtle flower of life pattern
                FlowerOfLifePattern()
                    .stroke(QXColor.gold.opacity(0.03), lineWidth: 0.5)
                    .frame(width: geo.size.width * 2, height: geo.size.width * 2)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.3)
                    .rotationEffect(.degrees(0))
                
                // Rotating outer ring
                RotatingRing()
                    .stroke(QXColor.gold.opacity(0.05), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .frame(width: geo.size.width * 1.5, height: geo.size.width * 1.5)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.3)
            }
        }
        .ignoresSafeArea()
    }
}
```

#### 7.1.2 Color Palette

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Background | Cosmic Black | `#0A0A0F` | Primary background |
| Card | Deep Void | `#14141B` | Card backgrounds |
| Accent | Gold | `#D4AF37` | Primary accent, CTA |
| Accent glow | Gold Glow | `#F0E68C` | Highlights, glows |
| Text primary | Starlight | `#F5F5F7` | Primary text |
| Text secondary | Moon Dust | `#8B8B9E` | Secondary text |
| System: Numerology | Cosmic Purple | `#6B4EE6` | Numerology elements |
| System: Astrology | Nebula Blue | `#4ECDC4` | Astrology elements |
| System: Kabbalah | Emerald | `#50C878` | Kabbalah elements |
| System: Tarot | Royal Gold | `#C9A961` | Tarot elements |
| System: Sacred Geo | Violet | `#8B5CF6` | Sacred geometry |
| System: Frequency | Cyan | `#00D4AA` | Frequency elements |
| System: Alchemy | Rust | `#B7410E` | Alchemy elements |

### 7.2 Animation Specifications

#### 7.2.1 Transitions Between Systems

```swift
// Cross-system navigation transition
extension AnyTransition {
    static var sacredTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)),
            removal: .opacity.combined(with: .scale(scale: 1.05))
        )
    }
}

// System-specific color morphing
struct SystemColorTransition: ViewModifier {
    let fromSystem: SpiritualSystem
    let toSystem: SpiritualSystem
    @State private var progress: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        fromSystem.color.opacity(1 - progress),
                        toSystem.color.opacity(progress)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    progress = 1
                }
            }
    }
}
```

#### 7.2.2 Micro-interactions

```swift
// Correspondence highlight animation
struct CorrespondenceHighlight: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(QXColor.gold.opacity(isPulsing ? 0.8 : 0), lineWidth: 2)
            )
            .scaleEffect(isPulsing ? 1.02 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

// Sacred geometry reveal animation
struct SacredReveal: ViewModifier {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    rotation = 0
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}
```

### 7.3 Progressive Disclosure Pattern

```swift
struct ProgressiveDisclosure<Simple: View, Detailed: View>: View {
    @State private var isExpanded = false
    @ViewBuilder let simpleView: () -> Simple
    @ViewBuilder let detailedView: () -> Detailed
    
    var body: some View {
        VStack(spacing: 0) {
            simpleView()
            
            if isExpanded {
                detailedView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? "Show Less" : "Learn More")
                        .font(QXFont.caption)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundStyle(QXColor.gold)
            }
            .padding(.top, 8)
        }
    }
}
```

---

## 8. SUBSCRIPTION GATING STRATEGY

### 8.1 Feature Matrix by Tier

| Feature | Free | Seeker | Initiate | Master |
|---------|------|--------|----------|--------|
| **Numerology** | | | | |
| Life Path Number | ✅ | ✅ | ✅ | ✅ |
| Expression Number | ✅ | ✅ | ✅ | ✅ |
| Personal Year/Month/Day | ✅ | ✅ | ✅ | ✅ |
| Full Birth Chart | — | ✅ | ✅ | ✅ |
| Compatibility Analysis | 1/month | Unlimited | Unlimited | Unlimited |
| **Astrology** | | | | |
| Sun Sign Only | ✅ | — | — | — |
| Full Natal Chart | — | ✅ | ✅ | ✅ |
| Transit Reports | — | Daily | Daily | Daily |
| Synastry | — | — | ✅ | ✅ |
| **Kabbalah** | | | | |
| Personal Sephira | — | ✅ | ✅ | ✅ |
| Pathworking | — | — | ✅ | ✅ |
| Tree of Life Explorer | — | — | ✅ | ✅ |
| **Tarot** | | | | |
| Birth Cards | — | ✅ | ✅ | ✅ |
| Daily Card | ✅ | ✅ | ✅ | ✅ |
| Full Readings | — | 3/day | Unlimited | Unlimited |
| **Sacred Geometry** | | | | |
| Basic Shapes | Preview | ✅ | ✅ | ✅ |
| Full Library | — | — | ✅ | ✅ |
| Interactive Generator | — | — | — | ✅ |
| **Frequency** | | | | |
| 3 Frequencies | ✅ | All | All | All |
| Custom Binaural | — | — | ✅ | ✅ |
| **Sacred Math** | — | — | ✅ | ✅ |
| **Alchemy** | — | — | ✅ | ✅ |
| **Playing Cards** | — | ✅ | ✅ | ✅ |
| **Practice Tools** | | | | |
| Meditations | 3 | Full | Full | Full |
| Journal | ✅ | ✅ | ✅ | ✅ |
| AI Chat | — | — | ✅ | ✅ |
| **Today Tab** | | | | |
| Numerology Only | ✅ | — | — | — |
| 2 Systems | — | ✅ | — | — |
| All Systems | — | — | ✅ | ✅ |

### 8.2 Gating UI Patterns

#### 8.2.1 Locked State Card

```swift
struct LockedFeatureCard: View {
    let system: SpiritualSystem
    let requiredTier: MembershipTier
    
    var body: some View {
        ZStack {
            // Blurred preview
            RoundedRectangle(cornerRadius: 20)
                .fill(QXColor.deepVoid)
            
            VStack(spacing: QXSpacing.md) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                
                Text("Unlock \(system.displayName)")
                    .font(QXFont.headline)
                    .foregroundStyle(QXColor.starlight)
                
                Text("Available with \(requiredTier.displayName)")
                    .font(QXFont.body)
                    .foregroundStyle(QXColor.starlight.opacity(0.6))
                    .multilineTextAlignment(.center)
                
                Button("Upgrade") {
                    // Show paywall
                }
                .buttonStyle(QXPrimaryButtonStyle())
            }
            .padding()
        }
        .frame(height: 200)
    }
}
```

#### 8.2.2 Upgrade Prompt Modal

```swift
struct SystemUnlockPrompt: View {
    let system: SpiritualSystem
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        VStack(spacing: QXSpacing.xl) {
            // System icon with glow
            ZStack {
                Circle()
                    .fill(system.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: system.icon)
                    .font(.system(size: 56))
                    .foregroundStyle(system.color)
            }
            
            VStack(spacing: QXSpacing.sm) {
                Text("Unlock \(system.displayName)")
                    .font(QXFont.title)
                    .foregroundStyle(QXColor.starlight)
                
                Text(system.description)
                    .font(QXFont.body)
                    .foregroundStyle(QXColor.starlight.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Feature list
            VStack(alignment: .leading, spacing: QXSpacing.sm) {
                ForEach(system.premiumFeatures) { feature in
                    Label(feature, systemImage: "checkmark")
                        .foregroundStyle(QXColor.starlight.opacity(0.8))
                }
            }
            
            // CTA
            Button("Unlock with \(subscriptionManager.requiredTier(for: system).displayName)") {
                // Show paywall
            }
            .buttonStyle(QXPrimaryButtonStyle())
            
            Button("Maybe Later") {
                // Dismiss
            }
            .buttonStyle(QXTextButtonStyle())
        }
        .padding()
        .background(QXColor.cosmicBlack)
    }
}
```

### 8.3 Paywall Integration Points

| Trigger Point | Context | Upsell Target |
|---------------|---------|---------------|
| Tap locked system in Explore | Browse all disciplines | Relevant tier for that system |
| Try to access full astrology | Has birth date, no time | "Add birth time for full chart" |
| Daily synthesis with locked systems | Today tab shows preview | "See complete daily reading" |
| Cross-system insight generation | Blueprint reveals connections | "Unlock full correspondence engine" |
| Meditation category locked | Try to filter by frequency | "Unlock all meditation categories" |
| Journal analysis | AI-powered insights | Initiate tier upsell |
| Save 3rd reading today | Tarot daily limit hit | Unlimited readings upgrade |

---

## 9. IMPLEMENTATION ROADMAP

### 9.1 Phase 1: Foundation (Weeks 1-2)

- [ ] Implement new tab bar structure
- [ ] Create Today tab with basic numerology only
- [ ] Build Blueprint tab shell with completion tracking
- [ ] Redesign Explore as discipline grid
- [ ] Migrate existing tools to Practice tab

### 9.2 Phase 2: Integration (Weeks 3-4)

- [ ] Implement Correspondence Engine
- [ ] Build cross-system insight generator
- [ ] Add synchronicity detection
- [ ] Create progressive disclosure components
- [ ] Implement sacred geometry visual theme

### 9.3 Phase 3: Expansion (Weeks 5-6)

- [ ] Add Astrology system (Seeker+)
- [ ] Add Tarot system (Seeker+)
- [ ] Add Kabbalah system (Seeker+)
- [ ] Expand Today tab with multi-system synthesis
- [ ] Implement subscription gating for new systems

### 9.4 Phase 4: Advanced (Weeks 7-8)

- [ ] Add Sacred Geometry (Initiate+)
- [ ] Add Frequency Work (Initiate+)
- [ ] Add Alchemy (Initiate+)
- [ ] Add Sacred Mathematics (Initiate+)
- [ ] Add Playing Cards (Seeker+)

### 9.5 Phase 5: Polish (Weeks 9-10)

- [ ] Implement all animations
- [ ] Add haptic feedback throughout
- [ ] Optimize performance
- [ ] Accessibility audit
- [ ] User testing & iteration

---

## 10. TECHNICAL CONSIDERATIONS

### 10.1 Architecture

```
QodeX/
├── App/
│   └── UnifiedTabView.swift          # New main navigation
├── Features/
│   ├── Today/
│   │   ├── TodayView.swift
│   │   ├── DailySynthesisCard.swift
│   │   └── SynchronicityBadge.swift
│   ├── Blueprint/
│   │   ├── BlueprintView.swift
│   │   ├── CrossSystemInsightsCard.swift
│   │   └── ProfileCompletionView.swift
│   ├── Explore/
│   │   ├── ExploreView.swift
│   │   ├── DisciplineCard.swift
│   │   └── FeaturedDisciplineCard.swift
│   ├── Practice/
│   │   ├── PracticeView.swift
│   │   ├── FrequencyPlayerView.swift
│   │   ├── MeditationLibraryView.swift
│   │   └── QuickToolsGrid.swift
│   └── [SystemModules]/              # 9 discipline modules
│       ├── Numerology/
│       ├── Astrology/
│       ├── Kabbalah/
│       ├── Tarot/
│       ├── SacredGeometry/
│       ├── Frequency/
│       ├── Alchemy/
│       ├── SacredMath/
│       └── PlayingCards/
├── Core/
│   ├── Correspondence/
│   │   ├── CorrespondenceEngine.swift
│   │   ├── SynchronicityDetector.swift
│   │   └── InsightGenerator.swift
│   └── Models/
│       ├── Blueprint.swift
│       ├── SpiritualSystem.swift
│       └── CorrespondenceModels.swift
└── DesignSystem/
    ├── SacredGeometry/
    │   ├── FlowerOfLife.swift
    │   ├── MetatronsCube.swift
    │   └── SacredTransitions.swift
    └── Components/
        ├── PremiumGlassCard.swift
        └── ProgressiveDisclosure.swift
```

### 10.2 Data Sync Strategy

- Blueprint data stored in Firestore with offline caching
- Correspondence engine runs locally (static dataset)
- Daily synthesis computed on-device for privacy
- Subscription status synced via RevenueCat

### 10.3 Performance Targets

- Tab switch: < 100ms
- Daily synthesis generation: < 500ms
- Synchronicity detection: < 200ms
- App launch to Today tab: < 2s

---

## 11. SUCCESS METRICS

| Metric | Target | Measurement |
|--------|--------|-------------|
| Tab engagement | 3+ tabs used weekly | Analytics |
| Cross-system discovery | 50% of users unlock 3+ systems | Subscription data |
| Today tab retention | 70% daily return rate | Session analytics |
| Blueprint completion | 60% complete birth data | Profile data |
| Subscription conversion | 15% free-to-paid | RevenueCat |
| Upgrade rate (multi-system) | 40% of paid users upgrade tier | RevenueCat |

---

**Document End**

*Reference: This design draws inspiration from the layered navigation of Apple's Fitness app, the progressive disclosure patterns in Headspace, and the cross-connection visualization of The Pattern app—all unified through a sacred geometry visual language inspired by Alex Grey's visionary art.*
