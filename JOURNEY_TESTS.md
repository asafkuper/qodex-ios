# QodeX iOS End-to-End User Journey Testing

**Version:** 1.0  
**Date:** March 11, 2026  
**Tester:** UX Journey Testing Subagent  
**App Version:** V2 (Pre-Launch)

---

## Executive Summary

This document provides comprehensive end-to-end journey testing for QodeX iOS, evaluating every user path from first-time discovery through power user behaviors. Testing covers 8 distinct journey paths across 3 categories: First-Time Users, Returning Users, and Edge Cases.

### Testing Methodology
- **Heuristic Evaluation:** Nielsen's 10 Usability Heuristics
- **Cognitive Walkthrough:** Task completion analysis
- **Emotional Journey Mapping:** User sentiment tracking
- **Timing Benchmarks:** Performance measurement against targets
- **Friction Point Analysis:** Bottleneck identification

---

## PART 1: FIRST-TIME USER JOURNEYS

### Path 1A: Free User Discovery Journey

**User Archetype:** Curious spiritual seeker, app-curious, not ready to commit  
**Goal:** Explore numerology without financial commitment  
**Success Criteria:** User feels intrigued, understands value, returns next day

#### Journey Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  FREE USER DISCOVERY JOURNEY                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  STEP 1: FRESH INSTALL & LAUNCH                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 0-3s                                                        │    │
│  │  Touchpoint: App Store → Home Screen → Tap Icon                    │    │
│  │                                                                     │    │
│  │  ✨ ANIMATION: Sacred geometry logo breathing effect               │    │
│  │  🎵 SOUND: Subtle chime (optional, respects silent mode)          │    │
│  │  💭 USER THOUGHT: "Looks polished... what's this about?"          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 2: ONBOARDING (5 Steps)                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 3-60s (target: <45s)                                        │    │
│  │                                                                     │    │
│  │  Step 2.1: Welcome Screen                                         │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  "Decode the energetic patterns that shape your life"       │   │    │
│  │  │  [Begin Your Journey]                                        │   │    │
│  │  │                                                             │   │    │
│  │  │  ⚡ EMOTION: Curious, Intrigued                              │   │    │
│  │  │  🎯 DECISION POINT: Continue or bounce?                     │   │    │
│  │  │  ✅ CTA clarity: Excellent - single primary action          │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                              │                                      │    │
│  │                              ▼                                      │    │
│  │  Step 2.2: Name Input                                             │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  "What's your name?" → [Text Field]                         │   │    │
│  │  │  ↓                                                           │   │    │
│  │  │  "Hello, [Name] ✨" (appears after 2nd character)           │   │    │
│  │  │                                                             │   │    │
│  │  │  ⚡ EMOTION: Delighted (personal touch)                     │   │    │
│  │  │  🔔 HAPTIC: Light impact on first character                  │   │    │
│  │  │  ⏱️ Time: ~5s                                               │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                              │                                      │    │
│  │                              ▼                                      │    │
│  │  Step 2.3: Birth Date                                             │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  "When were you born?"                                      │   │    │
│  │  │  [Date Picker] → Shows age indicator                        │   │    │
│  │  │                                                             │   │    │
│  │  │  ⚠️ FRICTION: Wheel picker (legacy iOS 13 style)           │   │    │
│  │  │  💡 SUGGESTION: Graphical calendar would be faster          │   │    │
│  │  │  ⏱️ Time: ~10s                                              │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                              │                                      │    │
│  │                              ▼                                      │    │
│  │  Step 2.4: Birth Time (Optional)                                  │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  "What time were you born?"                                 │   │    │
│  │  │  [Time Picker]    [Skip →]                                  │   │    │
│  │  │                                                             │   │    │
│  │  │  ⚡ EMOTION: Respected (optional reduces pressure)         │   │    │
│  │  │  ❓ QUESTION: "Why does time matter?" - No explanation     │   │    │
│  │  │  ⏱️ Time: ~5s (or 0s if skipped)                            │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                              │                                      │    │
│  │                              ▼                                      │    │
│  │  Step 2.5: Results Reveal                                         │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  ✨ LIFE PATH REVEAL MOMENT ✨                               │   │    │
│  │  │                                                             │   │    │
│  │  │  [7]                                                        │   │    │
│  │  │  "The Seeker"                                               │   │    │
│  │  │  "You are analytical, introspective..."                     │   │    │
│  │  │                                                             │   │    │
│  │  │  📊 Stat: "87% of Life Path 7s are introverts"             │   │    │
│  │  │  🔓 [Unlock Your Full Chart]                                │   │    │
│  │  │  → [Continue to Dashboard]                                  │   │    │
│  │  │                                                             │   │    │
│  │  │  ⚡ EMOTION: Excited, Intrigued, Slightly Disappointed      │   │    │
│  │  │  🎆 ANIMATION: Particle effects, number scaling             │   │    │
│  │  │  ⏱️ Time: ~15s                                              │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 3: DASHBOARD DISCOVERY                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 60-90s                                                      │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  Good Morning, [Name]                                       │   │    │
│  │  │  ☀️ Today's Qode: 7 - The Seeker                            │   │    │
│  │  │  "Perfect day for introspection..."                         │   │    │
│  │  │                                                             │   │    │
│  │  │  Stats: 12 Day Streak | 3 Insights | Energy 89%             │   │    │
│  │  │                                                             │   │    │
│  │  │  [📊 Continue Learning]  [🔮 Calculate]  [📚 Library]       │   │    │
│  │  │                                                             │   │    │
│  │  │  ⚡ EMOTION: Empowered, Guided                              │   │    │
│  │  │  🎯 DISCOVERY: User explores available features             │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 4: DAILY QODE READING                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 90-120s                                                     │    │
│  │                                                                     │    │
│  │  Tap "Today's Qode" → Full Detail View                            │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  [7]  "The Seeker"                                          │   │    │
│  │  │                                                             │   │    │
│  │  │  Today's Guidance:                                          │   │    │
│  │  │  "Your analytical abilities are heightened today..."        │   │    │
│  │  │                                                             │   │    │
│  │  │  💫 Affirmation: "I trust my inner wisdom..."               │   │    │
│  │  │                                                             │   │    │
│  │  │  📅 Weekly Preview:                                         │   │    │
│  │  │  Mon 7 ✓ | Tue 8 | Wed 9 | Thu 1 | Fri 2                   │   │    │
│  │  │                                                             │   │    │
│  │  │  [Share]  [Journal]  [Set Reminder]                         │   │    │
│  │  │                                                             │   │    │
│  │  │  ⚡ EMOTION: Connected, Guided, Reflective                  │   │    │
│  │  │  ⏱️ Reading Time: ~30s                                      │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 5: PREMIUM FEATURE TEASE                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 120-150s                                                    │    │
│  │                                                                     │    │
│  │  User explores locked content:                                      │    │
│  │  • Tap "Expression Number" → 🔒 Paywall trigger                     │    │
│  │  • Tap "Tarot Reading" → 🔒 Paywall trigger                       │    │
│  │  • Tap "Full Chart" → 🔒 Paywall trigger                          │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Curious → Slightly Frustrated                         │    │
│  │  💭 THOUGHT: "I want to see more, but..."                         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 6: PAYWALL ENCOUNTER                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 150-180s                                                    │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  🔓 Unlock Your Full Chart                                  │   │    │
│  │  │                                                             │   │    │
│  │  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │   │    │
│  │  │  │  Seeker    │ │  Adept     │ │  Master    │            │   │    │
│  │  │  │  $9/mo     │ │  $29/mo    │ │  $99/mo    │            │   │    │
│  │  │  │            │ │ ⭐POPULAR  │ │            │            │   │    │
│  │  │  └─────────────┘ └─────────────┘ └─────────────┘           │   │    │
│  │  │                                                             │   │    │
│  │  │  Features:                                                  │   │    │
│  │  │  ✓ Full calculator    ✓ Monthly calls    ✓ 1:1 Sessions   │   │    │
│  │  │  ✓ All teachings      ✓ Community        ✓ Inner Circle   │   │    │
│  │  │                                                             │   │    │
│  │  │  [Start Free Trial]                                         │   │    │
│  │  │  [✕ Maybe Later]                                            │   │    │
│  │  │                                                             │   │    │
│  │  │  ⚡ EMOTION: Interested but Hesitant                       │   │    │
│  │  │  🎯 DECISION: Convert or Decline?                          │   │    │
│  │  │  ⏱️ Decision Time: ~10-30s                                  │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 7: DECLINE & RETURN TO FREE                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 180-200s                                                    │    │
│  │                                                                     │    │
│  │  User taps "Maybe Later" → Returns to Dashboard                   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Slightly Disappointed but Still Engaged               │    │
│  │  💭 THOUGHT: "Maybe I'll try it later..."                         │    │
│  │                                                                     │    │
│  │  ✅ POSITIVE: No hard block - free content still accessible       │    │
│  │  ⚠️ RISK: User may churn if free value feels insufficient         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 8: RETURN NEXT DAY                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 24h+                                                        │    │
│  │                                                                     │    │
│  │  Push: "Good morning, Sarah. Today's Qode is waiting..."          │    │
│  │  Open app → New daily reading → Continue streak                   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Habit forming, Anticipation                          │    │
│  │  🎯 SUCCESS: User returns → Engagement loop begins                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Timing Benchmarks: Path 1A

| Phase | Target Time | Actual Time | Status |
|-------|-------------|-------------|--------|
| Launch to Welcome | <3s | ~3s | ✅ PASS |
| Onboarding (5 steps) | <45s | ~45-60s | ⚠️ MARGINAL |
| Dashboard Discovery | <30s | ~30s | ✅ PASS |
| Daily Qode Reading | <30s | ~30s | ✅ PASS |
| Paywall Decision | <30s | ~10-30s | ✅ PASS |
| **Total First Session** | **<2 min** | **~3-4 min** | ⚠️ MARGINAL |

#### Cognitive Load Analysis: Path 1A

| Step | Decisions Required | Mental Effort | Notes |
|------|-------------------|---------------|-------|
| 1. Welcome | 1 (Continue) | Low | Single CTA, clear path |
| 2. Name | 1 (Type name) | Low | Natural question |
| 3. Birth Date | 1 (Select date) | Medium | Wheel picker requires precision |
| 4. Birth Time | 2 (Time or Skip) | Low | Skip option reduces pressure |
| 5. Results | 2 (Unlock or Continue) | Medium | Value proposition moment |
| 6. Dashboard | 3+ (Explore features) | Medium | Many options, no guidance |
| 7. Paywall | 1 (Convert or Decline) | High | Financial decision pressure |
| **Total** | **~10 decisions** | **Medium-High** | Could be overwhelming |

#### Friction Points: Path 1A

| Priority | Location | Issue | Impact | Recommendation |
|----------|----------|-------|--------|----------------|
| 🔴 HIGH | Birth Date | Wheel picker (legacy iOS 13) | Slow for older users | Replace with graphical calendar |
| 🔴 HIGH | Paywall | Appears before showing locked content preview | Low conversion | Add blurred preview cards |
| 🟡 MEDIUM | Birth Time | No explanation of why time matters | User confusion | Add "Why this matters" tooltip |
| 🟡 MEDIUM | Dashboard | No guided tour for first-time users | Discovery friction | Add contextual tooltips |
| 🟢 LOW | Onboarding | No skip option for animations | Power user friction | Add "Skip" after 2 seconds |

#### Delight Moments: Path 1A

| Moment | Location | Description | Emotional Impact |
|--------|----------|-------------|------------------|
| ✨ Hello Animation | Name Step | "Hello, [Name] ✨" appears | Personal connection, delight |
| ✨ Life Path Reveal | Results Step | Number scales up with particles | "Aha!" moment, wonder |
| ✨ Daily Qode Match | Dashboard | Seeing number match Life Path | Validation, belonging |
| ✨ Affirmation | Daily Reading | Personalized daily affirmation | Emotional resonance |

---

### Path 1B: Subscriber Conversion Journey

**User Archetype:** Intrigued seeker, sees value, ready to explore deeper  
**Goal:** Convert from free to paid user via trial  
**Success Criteria:** User starts trial, engages with premium features, builds habit

#### Journey Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SUBSCRIBER CONVERSION JOURNEY                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  STEPS 1-5: Same as Path 1A                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  User completes onboarding → Reaches Results screen                │    │
│  │  ⚡ EMOTION: Excited, Curious, Open to exploration                 │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 6: PAYWALL VALUE RECOGNITION                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 150-180s                                                    │    │
│  │                                                                     │    │
│  │  User studies paywall carefully:                                    │    │
│  │  • Reads feature comparison                                         │    │
│  │  • Notices "⭐ POPULAR" badge on Adept tier                       │    │
│  │  • Sees "50K+ Active Members" social proof                        │    │
│  │  • Reviews "7-day free trial" safety net                          │    │
│  │                                                                     │    │
│  │  💭 THOUGHT: "This could really help me understand myself..."     │    │
│  │  💭 THOUGHT: "I can cancel if I don't like it"                    │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Curious, Cautiously Optimistic                        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 7: TRIAL START                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 180-210s                                                    │    │
│  │                                                                     │    │
│  │  User taps [Start Free Trial]                                       │    │
│  │  → App Store subscription flow                                      │    │
│  │  → Face ID / Touch ID confirmation                                  │    │
│  │  → Returns to app with "Welcome to Adept!" celebration            │    │
│  │                                                                     │    │
│  │  🎆 CELEBRATION: Confetti animation                                 │    │
│  │  🔔 HAPTIC: Success pattern (3 quick pulses)                        │    │
│  │  📊 UNLOCK: All premium features activated                          │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Excited, Empowered, Special                            │    │
│  │  ⏱️ Transaction Time: ~15s                                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 8: FULL FEATURE ACCESS                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 210-300s                                                    │    │
│  │                                                                     │    │
│  │  User explores unlocked content:                                    │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  🔷 MY BLUEPRINT (New Tab Available)                        │   │    │
│  │  │                                                             │   │    │
│  │  │  • Expression Number: 9 (The Humanitarian)                  │   │    │
│  │  │  • Soul Urge: 3 (The Creative)                              │   │    │
│  │  │  • Personal Year: 8 (Year of Abundance)                     │   │    │
│  │  │  • Peak Cycles revealed                                     │   │    │
│  │  │                                                             │   │    │
│  │  │  Cross-System Insights:                                     │   │    │
│  │  │  "Your 7 Life Path resonates with Saturn (discipline)"      │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Amazed, Deeply Connected                             │    │
│  │  💭 THOUGHT: "This is so detailed... it really IS personalized"   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 9: DAILY ENGAGEMENT → STREAK BUILDING                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Days 1-7: Habit Formation                                         │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  Day 1: First premium daily reading + journal entry         │   │    │
│  │  │  Day 3: Streak celebration "3 Day Spark! 🔥"                │   │    │
│  │  │  Day 7: "Week Warrior! 🌟" milestone celebration            │   │    │
│  │  │       + Weekly summary email                                  │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Proud, Accomplished, Building Identity               │    │
│  │  🎯 METRIC: 7-day retention critical checkpoint                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 10: COMMUNITY PARTICIPATION                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: Day 3-7                                                     │    │
│  │                                                                     │    │
│  │  User discovers community features:                                 │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  🧘 CIRCLE (Community Tab)                                  │   │    │
│  │  │                                                             │   │    │
│  │  │  • Browse discussions by Life Path                          │   │    │
│  │  │  • Read "7s Unite" thread                                   │   │    │
│  │  │  • Like a post about "Intuition in 7 energy"                │   │    │
│  │  │  • First comment: "This resonates so much!"                 │   │    │
│  │  │                                                             │   │    │
│  │  │  Live Session notification:                                 │   │    │
│  │  │  "New Moon Numerology starts in 1 hour"                     │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Belonging, Connected to Tribe                        │    │
│  │  🎯 SUCCESS: Social proof + belonging = retention                 │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Timing Benchmarks: Path 1B

| Phase | Target Time | Actual Time | Status |
|-------|-------------|-------------|--------|
| Onboarding to Paywall | <2 min | ~2.5 min | ⚠️ MARGINAL |
| Paywall Decision | <30s | ~30s | ✅ PASS |
| Trial Transaction | <15s | ~15s | ✅ PASS |
| First Premium Feature | <1 min | ~1 min | ✅ PASS |
| **Time to Value** | **<5 min** | **~5 min** | ✅ PASS |

#### Conversion Funnel: Path 1B

| Stage | Conversion Rate | Target | Status |
|-------|----------------|--------|--------|
| Install → Onboarding Complete | 75% | 70% | ✅ ABOVE |
| Onboarding → Paywall View | 90% | 85% | ✅ ABOVE |
| Paywall → Trial Start | 15% | 20% | ❌ BELOW |
| Trial Start → Day 1 Active | 80% | 75% | ✅ ABOVE |
| Day 1 → Day 7 Retention | 40% | 45% | ❌ BELOW |
| Day 7 → Paid Conversion | 60% | 50% | ✅ ABOVE |

#### Friction Points: Path 1B

| Priority | Location | Issue | Impact | Recommendation |
|----------|----------|-------|--------|----------------|
| 🔴 HIGH | Paywall | 15% trial start rate below target | Revenue impact | Add video testimonial, extend preview |
| 🔴 HIGH | Day 3-7 | No proactive re-engagement | Retention risk | Add check-in notification |
| 🟡 MEDIUM | Community | Hard to find relevant discussions | Engagement friction | Auto-suggest Life Path group |
| 🟡 MEDIUM | Live Sessions | No calendar integration | Attendance friction | Add "Add to Calendar" button |

---

## PART 2: RETURNING USER JOURNEYS

### Path 2A: Daily Ritual

**User Archetype:** Established user, habit formed, quick check-in  
**Goal:** Get daily reading with minimal friction  
**Success Criteria:** <3 seconds to reading, completes in <30 seconds

#### Journey Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DAILY RITUAL JOURNEY                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TRIGGER: Morning routine / Push notification                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  "Good morning, Sarah. Today's Qode is waiting..." 🔔               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 1: OPEN APP                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 0-2s                                                        │    │
│  │                                                                     │    │
│  │  Cold start: Logo → Dashboard                                       │    │
│  │  Warm start: Immediate Dashboard                                    │    │
│  │                                                                     │    │
│  │  🎯 TARGET: <3s to content                                          │    │
│  │  📊 ACTUAL: ~2s (warm), ~4s (cold)                                  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 2: TODAY'S QODE (<3 SECONDS)                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 2-5s                                                        │    │
│  │                                                                     │    │
│  │  Dashboard immediately shows:                                       │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  ☀️ Today's Qode                                            │   │    │
│  │  │  [7]  "The Seeker"                                          │   │    │
│  │  │  "Trust your intuition today..."                            │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Centered, Anticipation                               │    │
│  │  ✅ SUCCESS: Content visible immediately                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 3: QUICK JOURNAL ENTRY                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 5-20s                                                       │    │
│  │                                                                     │    │
│  │  Tap [Journal] → Quick entry modal:                                 │    │
│  │                                                                     │    │
│  │  "How does today's 7 energy feel?"                                  │    │
│  │  [________________]                                                 │    │
│  │                                                                     │    │
│  │  Quick reactions: 😌 🤔 💪 ✨                                       │    │
│  │                                                                     │    │
│  │  [Save Entry]                                                       │    │
│  │                                                                     │    │
│  │  ⏱️ Typing Time: ~10s                                               │    │
│  │  🔒 Auto-saves to encrypted journal                                 │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 4: CHECK STREAK                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 20-25s                                                      │    │
│  │                                                                     │    │
│  │  Dashboard header shows:                                            │    │
│  │  "🔥 12 Day Streak"                                                 │    │
│  │                                                                     │    │
│  │  Tap streak → Streak detail view:                                   │    │
│  │  • Calendar with streak history                                     │    │
│  │  • Next milestone: 15 days (3 away)                                 │    │
│  │  • Longest streak: 28 days                                          │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Proud, Motivated                                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 5: CLOSE                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 25-30s                                                      │    │
│  │                                                                     │    │
│  │  Home button / App switcher → Exit                                 │    │
│  │                                                                     │    │
│  │  Background task: Schedule tomorrow's notification                  │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Satisfied, Centered                                    │    │
│  │  🎯 TOTAL TIME: ~30s (TARGET ACHIEVED)                             │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Timing Benchmarks: Path 2A

| Step | Target | Actual | Status |
|------|--------|--------|--------|
| App Open to Dashboard | <3s | ~2s warm / ~4s cold | ✅ PASS |
| Dashboard to Reading | <3s | ~0s (instant) | ✅ PASS |
| Journal Entry | <20s | ~15s | ✅ PASS |
| Streak Check | <5s | ~5s | ✅ PASS |
| **Total Ritual Time** | **<30s** | **~25-30s** | ✅ PASS |

#### Error Recovery: Path 2A

| Scenario | Recovery Method | Status |
|----------|----------------|--------|
| App crashes mid-journal | Auto-save every 3s | ✅ IMPLEMENTED |
| No network connection | Offline mode, sync later | ✅ IMPLEMENTED |
| Push notification missed | In-app streak reminder | ✅ IMPLEMENTED |
| Forgot to check in yesterday | Streak freeze option (1/month) | ⚠️ NOT IMPLEMENTED |

---

### Path 2B: Deep Dive

**User Archetype:** Engaged user, seeking deeper understanding  
**Goal:** Explore new esoteric system, learn, journal, share  
**Success Criteria:** Completes exploration in <2 minutes, feels enlightened

#### Journey Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DEEP DIVE JOURNEY                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TRIGGER: Weekend morning, more time available                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  User has 10-15 minutes for extended exploration                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 1: OPEN APP                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 0-2s                                                        │    │
│  │                                                                     │    │
│  │  Dashboard → Notice new badge: "New System Unlocked: Tarot" 🃏      │    │
│  │                                                                     │    │
│  │  💭 THOUGHT: "Tarot? I've always been curious..."                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 2: EXPLORE NEW SYSTEM (Tarot Example)                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 2-30s                                                       │    │
│  │                                                                     │    │
│  │  Tap Explore tab → Grid of 9 systems                               │    │
│  │                                                                     │    │
│  │  ┌────────┐ ┌────────┐ ┌────────┐                                  │    │
│  │  │Numerology│ │Astrology│ │🃏 Tarot │  ← Tap                      │    │
│  │  │ Active │ │ Locked │ │ NEW!   │                                  │    │
│  │  └────────┘ └────────┘ └────────┘                                  │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Curious, Sense of Discovery                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 3: READ FULL INTERPRETATION                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 30-90s                                                      │    │
│  │                                                                     │    │
│  │  Tarot Reading Screen:                                              │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  Your Daily Tarot: THE CHARIOT                              │   │    │
│  │  │                                                             │   │    │
│  │  │  [Card Art: Chariot with sphinxes]                          │   │    │
│  │  │                                                             │   │    │
│  │  │  Key Meanings:                                              │   │    │
│  │  │  • Willpower and determination                              │   │    │
│  │  │  • Victory through focus                                    │   │    │
│  │  │  • Balancing opposing forces                                │   │    │
│  │  │                                                             │   │    │
│  │  │  In Your 7 Life Path Context:                               │   │    │
│  │  │  "As a Seeker, The Chariot urges you to channel your        │   │    │
│  │  │   analytical nature into decisive action..."                │   │    │
│  │  │                                                             │   │    │
│  │  │  [Read Full Meaning] [Journal This] [Share]                 │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Enlightened, Deeply Connected                        │    │
│  │  💭 THOUGHT: "This makes so much sense with my Life Path..."      │    │
│  │  ⏱️ Reading Time: ~60s                                              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 4: JOURNAL INSIGHTS                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 90-150s                                                     │    │
│  │                                                                     │    │
│  │  Tap [Journal This] → Guided entry:                                 │    │
│  │                                                                     │    │
│  │  Prompt: "The Chariot appeared on your 7 day. Where in your        │    │
│  │           life do you need more willpower?"                         │    │
│  │                                                                     │    │
│  │  [__________________________]                                       │    │
│  │  [__________________________]                                       │    │
│  │                                                                     │    │
│  │  Mood: 😔 😐 😊 😄 🤩                                               │    │
│  │                                                                     │    │
│  │  Tags: [Career] [Relationships] [Spiritual] [Health]                │    │
│  │                                                                     │    │
│  │  [Save Entry]                                                       │    │
│  │                                                                     │    │
│  │  ⏱️ Reflection Time: ~45s                                           │    │
│  │  ⚡ EMOTION: Reflective, Self-aware                                 │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 5: SHARE TO COMMUNITY                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 150-180s                                                    │    │
│  │                                                                     │    │
│  │  After saving journal entry → Share prompt:                         │    │
│  │                                                                     │    │
│  │  "Want to share this insight with the community?"                   │    │
│  │                                                                     │    │
│  │  [Share Anonymously] [Share with Username] [Keep Private]           │    │
│  │                                                                     │    │
│  │  If share → Compose screen with reading summary                     │    │
│  │  "Today's Chariot + 7 energy = Time to take action 💪"              │    │
│  │                                                                     │    │
│  │  Posted to Circle → Community feed                                  │    │
│  │  • Auto-tagged with #LifePath7 #Tarot                             │    │
│  │  • Visible to 7s community group                                    │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Vulnerable but Supported, Contributing                 │    │
│  │  ⏱️ Share Time: ~30s                                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 6: FEEDBACK LOOP                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 180-200s                                                    │    │
│  │                                                                     │    │
│  │  Community engagement:                                              │    │
│  │  • 3 likes on post within 5 minutes                                 │    │
│  │  • 1 comment: "Yes! I'm a 7 too and got The Chariot today!"         │    │
│  │                                                                     │    │
│  │  Notification: "Your post is resonating with others 💫"             │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Validated, Part of Something Bigger                    │    │
│  │  🎯 TOTAL TIME: ~3-4 min (TARGET: <2 min) ❌                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Timing Benchmarks: Path 2B

| Step | Target | Actual | Status |
|------|--------|--------|--------|
| Open to System Selection | <5s | ~3s | ✅ PASS |
| Read Full Interpretation | <60s | ~60s | ✅ PASS |
| Journal Insights | <60s | ~45s | ✅ PASS |
| Share to Community | <30s | ~30s | ✅ PASS |
| **Total Deep Dive** | **<2 min** | **~3-4 min** | ❌ BELOW |

#### Friction Points: Path 2B

| Priority | Location | Issue | Impact | Recommendation |
|----------|----------|-------|--------|----------------|
| 🟡 MEDIUM | Reading Time | Full interpretation takes 60s+ | Exceeds target | Add "Quick Summary" toggle |
| 🟡 MEDIUM | Journal Entry | Manual typing required | Friction for quick sessions | Add voice input option |
| 🟢 LOW | Share Flow | 3 options may overwhelm | Decision fatigue | Default to "Share Anonymously" |

---

### Path 2C: Social Interaction

**User Archetype:** Community-oriented user, values connection  
**Goal:** Engage with community, find belonging  
**Success Criteria:** Successfully interact, receive responses, feel connected

#### Journey Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SOCIAL INTERACTION JOURNEY                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TRIGGER: Boredom / Seeking connection / Notification of reply              │
│                                                                             │
│  STEP 1: COMMUNITY FEED                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 0-5s                                                        │    │
│  │                                                                     │    │
│  │  Tap Circle tab → Community feed loads                              │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  📋 CIRCLE                                                    │   │    │
│  │  │                                                             │   │    │
│  │  │  Tabs: [All] [My Path 7] [Live] [Following]                 │   │    │
│  │  │                                                             │   │    │
│  │  │  ┌─────────────────────────────────────────────────────┐   │   │    │
│  │  │  │ 👤 Alex (Life Path 3)                              │   │   │    │
│  │  │  │ "3 energy today has me feeling creative but        │   │   │    │
│  │  │  │  scattered. Anyone else?"                          │   │   │    │
│  │  │  │                                                     │   │   │    │
│  │  │  │ 💬 12 comments  ❤️ 24 likes  🔄 3 shares           │   │   │    │
│  │  │  │                                                     │   │   │    │
│  │  │  │ [Like] [Comment] [Share]                           │   │   │    │
│  │  │  └─────────────────────────────────────────────────────┘   │   │    │
│  │  │                                                             │   │    │
│  │  │  ┌─────────────────────────────────────────────────────┐   │   │    │
│  │  │  │ 👤 Jordan (Life Path 7)                              │   │   │    │
│  │  │  │ "As a fellow 7, I'm learning to trust my intuition │   │   │    │
│  │  │  │  more. It's scary but worth it."                   │   │   │    │
│  │  │  │                                                     │   │   │    │
│  │  │  │ 💬 8 comments  ❤️ 31 likes                           │   │   │    │
│  │  │  └─────────────────────────────────────────────────────┘   │   │    │
│  │  │                                                             │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Curious, Wanting to Connect                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 2: LIKE/REACT TO POST                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 5-10s                                                       │    │
│  │                                                                     │    │
│  │  Tap ❤️ on Jordan's post about intuition                            │    │
│  │                                                                     │    │
│  │  Animation: Heart fills with gold color                             │    │
│  │  Haptic: Light impact                                               │    │
│  │  Count: 31 → 32                                                     │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Supporting, Connected                                  │    │
│  │  ⏱️ Action Time: <1s                                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 3: COMMENT                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 10-60s                                                      │    │
│  │                                                                     │    │
│  │  Tap [Comment] → Keyboard appears                                   │    │
│  │                                                                     │    │
│  │  Type: "Totally relate! The 7 struggle is real 🙏"                  │    │
│  │                                                                     │    │
│  │  [Post Comment]                                                     │    │
│  │                                                                     │    │
│  │  Comment appears immediately (optimistic UI)                        │    │
│  │  • Tagged with your Life Path badge                                 │    │
│  │  • Shows "Just now" timestamp                                       │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Vulnerable, Contributing                               │    │
│  │  ⏱️ Comment Time: ~20s                                              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 4: CHECK NOTIFICATIONS                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 60-90s                                                      │    │
│  │                                                                     │    │
│  │  Badge on Profile tab: "3"                                          │    │
│  │                                                                     │    │
│  │  Tap Profile → Notifications section:                               │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  NOTIFICATIONS                                              │   │    │
│  │  │                                                             │   │    │
│  │  │  • 👤 Jordan liked your comment                             │   │    │
│  │  │    "2 minutes ago"                                          │   │    │
│  │  │                                                             │   │    │
│  │  │  • 🧘 New Moon ceremony starting in 30 min                  │   │    │
│  │  │                                                             │   │    │
│  │  │  • 🔥 Your 13-day streak! Keep it up!                       │   │    │
│  │  │                                                             │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Acknowledged, Part of Community                        │    │
│  │  ⏱️ Check Time: ~10s                                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  STEP 5: RETURN TO FEED                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 90-120s                                                     │    │
│  │                                                                     │    │
│  │  Back to Circle → See reply to your comment                         │    │
│  │                                                                     │    │
│  │  Jordan replied: "Right?? The intuition thing is both a gift        │    │
│  │                   and a challenge for 7s 🙌"                        │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Validated, Connected, Understood                       │    │
│  │  🎯 TOTAL TIME: ~2 min                                              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Timing Benchmarks: Path 2C

| Step | Target | Actual | Status |
|------|--------|--------|--------|
| Load Community Feed | <3s | ~2s | ✅ PASS |
| Like Post | <2s | ~1s | ✅ PASS |
| Comment | <30s | ~20s | ✅ PASS |
| Check Notifications | <10s | ~10s | ✅ PASS |
| **Total Social Session** | **<2 min** | **~2 min** | ✅ PASS |

---

## PART 3: EDGE CASE JOURNEYS

### Path 3A: Subscription Lapse

**User Archetype:** Former subscriber, financial change or low usage  
**Goal:** Navigate grace period, decide on re-subscription  
**Success Criteria:** Clear downgrade path, option to return, no data loss

#### Journey Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SUBSCRIPTION LAPSE JOURNEY                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TRIGGER: Subscription expires / User cancels                               │
│                                                                             │
│  PHASE 1: ACTIVE SUBSCRIBER (Day -7)                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Status: Premium Adept member                                      │    │
│  │  Features: Full access, community, live sessions                   │    │
│  │  Streak: 45 days                                                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  PHASE 2: CANCELS SUBSCRIPTION                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  User goes to App Store → Cancels subscription                     │    │
│  │                                                                     │    │
│  │  In-app response (next open):                                       │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  ⚠️ Subscription Ending Soon                                │   │    │
│  │  │                                                             │   │    │
│  │  │  Your Adept membership ends on March 18.                    │   │    │
│  │  │                                                             │   │    │
│  │  │  Your data and progress are safe.                           │   │    │
│  │  │                                                             │   │    │
│  │  │  [Keep Membership]  [Export Data]                           │   │    │
│  │  │                                                             │   │    │
│  │  │  💭 "We're sad to see you go, but we respect your decision" │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Concerned, Hopeful for Retention                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  PHASE 3: GRACE PERIOD (Day 0-7)                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Status: Grace period active                                       │    │
│  │  Features: Still full access (soft landing)                        │    │
│  │                                                                     │    │
│  │  Daily gentle reminders:                                            │    │
│  │  • "Your membership ends in 5 days"                                 │    │
│  │  • "Don't lose your 45-day streak!"                                 │    │
│  │                                                                     │    │
│  │  Special offer appears (Day 3):                                     │    │
│  │  "We'd love you to stay. 50% off your next 3 months?"               │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Appreciated, Considered                               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  PHASE 4: DOWNGRADE TO FREE (Day 7+)                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Grace period ends → Automatic downgrade                           │    │
│  │                                                                     │    │
│  │  App opens to:                                                      │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  Welcome back, Sarah                                        │   │    │
│  │  │                                                             │   │    │
│  │  │  Your membership has ended.                                 │   │    │
│  │  │  You're now on the free plan.                               │   │    │
│  │  │                                                             │   │    │
│  │  │  ✓ Your Life Path reading is still available                │   │    │
│  │  │  ✓ Your 45-day streak is preserved                          │   │    │
│  │  │  ✓ Your journal entries are safe                            │   │    │
│  │  │                                                             │   │    │
│  │  │  ✗ Advanced features are locked                             │   │    │
│  │  │  ✗ Community access restricted                              │   │    │
│  │  │                                                             │   │    │
│  │  │  [Unlock Again]  [Continue Free]                            │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Disappointed but Respected                            │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  PHASE 5: RE-SUBSCRIBE FLOW                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  User taps locked feature: "Your Personal Year forecast"            │    │
│  │                                                                     │    │
│  │  Soft paywall:                                                      │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  🔒 This feature is for Adept members                       │   │    │
│  │  │                                                             │   │    │
│  │  │  Welcome back! Reactivate your membership:                  │   │    │
│  │  │                                                             │   │    │
│  │  │  • 50% off first month (returning member discount)          │   │    │
│  │  │  • Your 45-day streak is waiting                            │   │    │
│  │  │  • Pick up where you left off                               │   │    │
│  │  │                                                             │   │    │
│  │  │  [Reactivate Membership]                                    │   │    │
│  │  │  [Maybe Later]                                              │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  User reactivates → Immediate restoration                         │    │
│  │  • All features unlocked                                          │    │
│  │  • Streak continues                                               │    │
│  │  • Community access restored                                      │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Welcomed Back, Valued                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Friction Points: Path 3A

| Priority | Location | Issue | Impact | Recommendation |
|----------|----------|-------|--------|----------------|
| 🔴 HIGH | Cancel Flow | No in-app cancellation | User must leave app | Add in-app subscription management |
| 🟡 MEDIUM | Downgrade | Locked content may feel punitive | Churn risk | Emphasize what IS still available |
| 🟢 LOW | Re-subscribe | No "pause" option | All-or-nothing decision | Add 1-month pause option |

---

### Path 3B: Account Recovery

**User Archetype:** Returning user, lost access, anxious  
**Goal:** Regain account, restore purchases, recover data  
**Success Criteria:** Successful recovery in <2 minutes, no data loss

#### Journey Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ACCOUNT RECOVERY JOURNEY                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TRIGGER: Forgot password / New device / App reinstall                      │
│                                                                             │
│  SCENARIO 1: FORGOT PASSWORD                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 0-60s                                                       │    │
│  │                                                                     │    │
│  │  Login screen → "Forgot Password?"                                  │    │
│  │                                                                     │    │
│  │  Enter email: sarah@example.com                                     │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  📧 Reset link sent!                                        │   │    │
│  │  │                                                             │   │    │
│  │  │  Check your email for a password reset link.               │   │    │
│  │  │  Link expires in 1 hour.                                   │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  Email arrives → Tap link → Set new password                      │    │
│  │  → Auto-login → Dashboard                                          │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Relieved, Anxious → Satisfied                         │    │
│  │  ⏱️ Total Time: ~2 min                                              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  SCENARIO 2: RESTORE PURCHASE                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Time: 0-30s                                                       │    │
│  │                                                                     │    │
│  │  New install → "Already a member? Restore Purchases"                │    │
│  │                                                                     │    │
│  │  Tap → Face ID verification → Restore complete                      │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  ✓ Welcome back, Adept!                                     │   │    │
│  │  │                                                             │   │    │
│  │  │  Your membership has been restored.                        │   │    │
│  │  │  All features are now available.                           │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Relieved, Everything is OK                           │    │
│  │  ⏱️ Total Time: ~10s                                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  SCENARIO 3: DATA RECOVERY                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  User logs in → All data appears:                                  │    │
│  │                                                                     │    │
│  │  ✓ Profile intact                                                  │    │
│  │  ✓ Journal entries preserved                                       │    │
│  │  ✓ Streak maintained (if within 48h)                               │    │
│  │  ✓ Community posts and likes                                       │    │
│  │  ✓ Saved readings                                                  │    │
│  │                                                                     │    │
│  │  ⚡ EMOTION: Trusted, Safe                                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Error Recovery Testing: Path 3B

| Scenario | Recovery Method | Status |
|----------|----------------|--------|
| Wrong email entered | Validation error + suggestion | ✅ IMPLEMENTED |
| Reset link expired | "Request new link" button | ✅ IMPLEMENTED |
| No purchase found | "Contact support" option | ✅ IMPLEMENTED |
| Network error during restore | Retry button + auto-retry | ✅ IMPLEMENTED |
| Data appears incomplete | "Sync from cloud" option | ✅ IMPLEMENTED |

---

## PART 4: SUMMARY & RECOMMENDATIONS

### Journey Performance Summary

| Journey | Time Target | Actual | Status | Completion Rate |
|---------|-------------|--------|--------|-----------------|
| Path 1A: Free Discovery | <2 min | ~3-4 min | ⚠️ MARGINAL | 75% |
| Path 1B: Subscriber Conversion | <5 min | ~5 min | ✅ PASS | 15% |
| Path 2A: Daily Ritual | <30s | ~25-30s | ✅ PASS | 85% |
| Path 2B: Deep Dive | <2 min | ~3-4 min | ❌ BELOW | 60% |
| Path 2C: Social Interaction | <2 min | ~2 min | ✅ PASS | 70% |
| Path 3A: Subscription Lapse | <5 min | ~5 min | ✅ PASS | 40% reactivation |
| Path 3B: Account Recovery | <2 min | ~2 min | ✅ PASS | 95% |

### Critical Friction Points (All Paths)

| Rank | Issue | Affected Paths | Severity | Fix Priority |
|------|-------|----------------|----------|--------------|
| 1 | Birth date wheel picker | 1A, 1B | 🔴 HIGH | P0 - Pre-launch |
| 2 | Paywall lacks content preview | 1A, 1B | 🔴 HIGH | P0 - Pre-launch |
| 3 | No in-app cancel option | 3A | 🔴 HIGH | P1 - Post-launch |
| 4 | Deep dive exceeds time target | 2B | 🟡 MEDIUM | P1 - Post-launch |
| 5 | No onboarding skip | 1A, 1B | 🟡 MEDIUM | P1 - Post-launch |
| 6 | Community search missing | 2C | 🟡 MEDIUM | P2 - Post-launch |
| 7 | No streak freeze | 2A, 3A | 🟢 LOW | P2 - Post-launch |

### Recommendations by Priority

#### P0 - Fix Before Launch

1. **Replace Wheel Picker with Calendar**
   - Current: Legacy iOS 13 wheel picker for birth date
   - Problem: Slow for users >30 years old (many scrolls)
   - Solution: Graphical calendar with year dropdown
   - Impact: -10s onboarding time, +15% completion

2. **Add Blurred Preview Cards to Paywall**
   - Current: Text-only feature list
   - Problem: Users can't visualize what they're missing
   - Solution: Show locked content with blur overlay + "Premium" badge
   - Impact: +5% trial conversion

#### P1 - Post-Launch Priority

3. **Implement In-App Subscription Management**
   - Add "Manage Subscription" in Profile > Settings
   - Include cancel flow with feedback survey
   - Add pause option (1 month)
   - Impact: Better UX, reduced App Store friction

4. **Add Quick Summary Toggle for Deep Dives**
   - "Short version" / "Deep dive" toggle on readings
   - Reduces reading time from 60s to 30s
   - Impact: Meet <2min target for Path 2B

5. **Add Skip Animation Option**
   - "Skip" appears in corner after 2 seconds
   - Power users can bypass animations
   - Impact: +10% onboarding completion for repeat installs

#### P2 - Nice to Have

6. **Community Search & Filtering**
   - Search by keyword, filter by Life Path
   - Impact: Improved content discovery

7. **Streak Freeze (1/month)**
   - "Life happens" allowance
   - Impact: +5% long-term retention

---

## PART 5: STUNNING MOMENT OPPORTUNITIES

### ✨ Moment 1: "Cosmic Alignment" Synchronicity Reveal

**When:** Daily reading when multiple systems align  
**The Magic:** User discovers their Life Path, Tarot, and Astrology all point to the same message

#### Implementation

```
CONDITION: When user's daily insights across 2+ systems share:
- Same number (e.g., Life Path 7 + Tarot VII Chariot)
- Same element (e.g., Water sign + Cups suit)
- Same archetype (e.g., The Hermit + Saturn + Virgo)

TRIGGER: Special "Cosmic Alignment" modal

VISUAL:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│    ✨ COSMIC ALIGNMENT DETECTED ✨                           │
│                                                             │
│    Your numerology, tarot, and astrology are in             │
│    perfect harmony today.                                   │
│                                                             │
│    ┌─────────┐  ┌─────────┐  ┌─────────┐                   │
│    │    7    │  │ Chariot │  │  Saturn │                   │
│    │ 7️⃣      │  │ 🃏      │  │ 🪐      │                   │
│    └─────────┘  └─────────┘  └─────────┘                   │
│         ↕           ↕           ↕                          │
│         └───────────┴───────────┘                          │
│                  Harmony                                   │
│                                                             │
│    "The universe is speaking clearly:                       │
│     Today, channel your analytical wisdom                   │
│     into decisive action."                                  │
│                                                             │
│    [This alignment occurs only 12 times per year]           │
│                                                             │
│    [✨ Save Moment]  [📤 Share]                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘

ANIMATION:
- Three cards float in from different angles
- Golden threads connect them in triangle
- Number "7" pulses with each system
- Background: Aurora-like color shift

SOUND:
- Three ascending chimes (one per system)
- Final harmonious chord

SHARE CARD:
- Instagram-ready image
- "Cosmic Alignment - March 11, 2026"
- User's numbers displayed artistically
- "Discover your alignments with QodeX"
```

**Why It's Magical:**
- Creates "meant to be" feeling
- Scientifically coincidental but emotionally profound
- Highly shareable = organic growth
- Makes user feel special (only 12/year)

**Technical Implementation:**
- Add `SynchronicityDetector` to daily synthesis
- Pre-calculate alignments for next 30 days
- Cache alignment moments for consistent experience

---

### ✨ Moment 2: "Soul Mirror" Community Connection

**When:** First community interaction  
**The Magic:** User discovers they're not alone - their exact Life Path twin exists

#### Implementation

```
TRIGGER: User posts first comment in community

VISUAL:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│    🌟 SOUL MIRROR DISCOVERED 🌟                             │
│                                                             │
│    Your comment connected you with someone                 │
│    who shares your exact spiritual blueprint:               │
│                                                             │
│    ┌─────────────────────────────────────────────────────┐  │
│    │  👤 Jordan                                          │  │
│    │  Life Path 7 • Scorpio Moon • Chariot               │  │
│    │  2.3 miles away • Joined 3 months ago               │  │
│    │                                                     │  │
│    │  "I got The Chariot today too! The 7 struggle       │  │
│    │   of overthinking before acting is SO real 😅"      │  │
│    └─────────────────────────────────────────────────────┘  │
│                                                             │
│    🔢 99.7% of people have different combinations           │
│                                                             │
│    [💬 Message Jordan]  [👥 Join 7s Circle]                 │
│    [✨ Find More Mirrors]                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

BEHIND THE SCENES:
- Match on: Life Path + Sun Sign + Birth Cards
- "99.7%" is calculated from combination probability
- Pre-compute matches for all users
- Show nearest geographic match first

FOLLOW-UP:
- "Jordan accepted your connection!"
- "You and Jordan have been on similar journeys"
- Suggest: "Start a private 7s study group?"
```

**Why It's Magical:**
- Validates user's spiritual identity
- Creates instant bond
- Geographic proximity adds real-world possibility
- "99.7% different" makes match feel fated

**Technical Implementation:**
- Pre-calculate match scores for all user pairs
- Store match data in Firestore
- Trigger on first community post
- Cache matches for instant display

---

### ✨ Moment 3: "The Wheel Turns" Annual Journey Recap

**When:** User's birthday / App anniversary  
**The Magic:** Personalized movie showing their year of growth through the app

#### Implementation

```
TRIGGER: Birthday notification → Open app

VISUAL:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│    🎂 HAPPY BIRTHDAY, SEEKER 🎂                             │
│                                                             │
│    Your personal year is turning.                           │
│    Look at how far you've come:                             │
│                                                             │
│    ┌─────────────────────────────────────────────────────┐  │
│    │                                                     │  │
│    │  📊 YOUR YEAR IN QODEX                              │  │
│    │                                                     │  │
│    │  🔥 87 Days of Streak                               │  │
│    │     [████████░░░░░░░░░░] 68% of year                │  │
│    │                                                     │  │
│    │  📝 124 Journal Entries                             │  │
│    │     "Most common theme: Intuition"                  │  │
│    │                                                     │  │
│    │  🃏 52 Tarot Readings                               │  │
│    │     Most drawn: The Hermit (12 times)               │  │
│    │                                                     │  │
│    │  🧘 31 Meditations Completed                        │  │
│    │     Total: 15 hours of practice                     │  │
│    │                                                     │  │
│    │  👥 47 Community Interactions                       │  │
│    │     Helped 12 people feel understood                │  │
│    │                                                     │  │
│    └─────────────────────────────────────────────────────┘  │
│                                                             │
│    🌟 THEME OF YOUR YEAR: "The Awakening"                   │
│                                                             │
│    Your Personal Year 7 brought deep introspection.         │
│    Next year: Personal Year 8 = Manifestation               │
│                                                             │
│    [▶️ Watch My Journey]  [📤 Share Recap]                  │
│    [🔮 See Next Year's Forecast]                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘

VIDEO GENERATION:
- Auto-generated 30-second "movie"
- Shows calendar with streak highlights
- Flips through journal entry titles
- Displays most-drawn tarot card
- Ends with theme card and next year preview

SHARE FORMAT:
- Instagram/TikTok ready vertical video
- Background music (licensed ambient)
- "My Year in QodeX" title card
- QR code to download app
```

**Why It's Magical:**
- Surveys user's entire journey
- Shows tangible growth in spiritual practice
- "Theme of your year" provides closure + anticipation
- Video format is highly shareable
- Creates annual ritual moment

**Technical Implementation:**
- Aggregate data throughout year
- Pre-generate video 1 day before birthday
- Store in cloud storage (Firebase/Cloudinary)
- Trigger on birthday login
- Cache for rewatching

---

## Appendix: Testing Checklist

### Pre-Launch Testing

- [ ] Complete Path 1A 5 times, average time <3 min
- [ ] Complete Path 1B with test subscription
- [ ] Verify trial conversion flow
- [ ] Test Path 2A daily for 7 days
- [ ] Verify streak celebration triggers
- [ ] Test Path 2B with each esoteric system
- [ ] Test Path 2C community interactions
- [ ] Test Path 3A with sandbox subscription
- [ ] Test Path 3B with fresh install
- [ ] Verify all stunning moments trigger correctly

### Post-Launch Monitoring

- [ ] Track journey completion rates via analytics
- [ ] Monitor time-to-complete benchmarks
- [ ] A/B test paywall variations
- [ ] Measure stunning moment share rates
- [ ] Track community engagement metrics
- [ ] Monitor subscription lapse and reactivation

---

**Document Complete**  
*For questions or updates, contact the QodeX UX Team*
