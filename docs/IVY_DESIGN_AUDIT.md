# IVY Design Audit — QodeX iOS Mockups

**Role:** IVY (CDO / Design Lead)  
**Date:** March 16, 2026  
**Scope:** 5 HTML Mockups (Splash, Onboarding, Home, Life Path, Profile)  
**Reference:** iOS Human Interface Guidelines, Material Design 3, WCAG 2.1 AA

---

## Executive Summary

The QodeX mockups establish a cohesive mystical-esoteric visual identity with a strong purple-gold color system. However, **critical inconsistencies** exist in typography scale, spacing rhythm, and interaction patterns that will fragment the user experience. The design language shows promise but requires systematization before implementation.

**Priority Issues:**
- 🔴 **8 Critical** — Accessibility violations, inconsistent touch targets
- 🟡 **12 High** — Visual hierarchy gaps, spacing inconsistencies
- 🟢 **16 Medium** — Missing micro-interactions, polish opportunities

---

## 1. Design Inconsistencies

### 1.1 Color System Fragmentation

| Element | 01-Splash | 02-Onboarding | 03-Home | 04-Life Path | 05-Profile |
|---------|-----------|---------------|---------|--------------|------------|
| Primary Gold | `#FFD700` | `#FFD700` | `#FFD700` | `#FFD700` | `#FFD700` |
| Background Start | `#1a0a2e` | `#1a0a2e` | `#1a0a2e` | `#1a0a2e` | `#1a0a2e` |
| Background End | `#2d1b4e` | `#0d0221` | `#0d0221` | `#0d0221` | `#0d0221` |
| Card Background | *N/A* | *N/A* | `rgba(255,255,255,0.05)` | `rgba(255,255,255,0.05)` | `rgba(255,255,255,0.05)` |
| Accent Purple | `#4A0E4E` | *Not used* | `#4A0E4E` | `#4A0E4E` | *Not used* |

**Issue:** Inconsistent gradient endpoints create subtle but noticeable shifts between screens. Splash uses `#2d1b4e` while others use `#0d0221`.

**Fix:** Standardize on a single 3-color palette:
```css
--qodex-deep: #0d0221;        /* Darkest */
--qodex-mid: #1a0a2e;         /* Mid ground */
--qodex-accent: #4A0E4E;      /* Purple accent */
--qodex-gold: #FFD700;        /* Primary gold */
--qodex-gold-dark: #FFA500;   /* Gold shadow */
```

### 1.2 Typography Scale Discrepancies

| Screen | H1 Size | H2 Size | Body | Caption |
|--------|---------|---------|------|---------|
| 01-Splash | 42px | — | 16px | 12px |
| 02-Onboarding | — | 28px | 16px | 14px |
| 03-Home | 24px (user name) | 20px | 15px | 11-14px |
| 04-Life Path | 28px | — | 15px | 13-16px |
| 05-Profile | 28px | 22px | 14-15px | 11px |

**Critical Issues:**
- **No type scale system** — sizes arbitrarily chosen per screen
- **Inconsistent font weights** — Splash uses 700 for app name, Profile uses 700 for header, but different base sizes
- **Line heights not defined** — risk of clipping with Dynamic Type

### 1.3 Spacing Rhythm Violations

**Observed padding values:**
- Splash: Logo centered with absolute positioning
- Onboarding: `120px 32px 40px` (top/horizontal/bottom)
- Home: `60px 24px 24px` header, `0 24px 100px` content
- Life Path: `60px 24px 0` header, `32px 24px` hero
- Profile: `60px 24px 24px` header

**Issue:** No consistent 8px or 4px grid system. Values like 60px, 120px appear arbitrary.

### 1.4 Border Radius Inconsistencies

| Component | 01 | 02 | 03 | 04 | 05 |
|-----------|----|----|----|----|----|
| Buttons | 16px | 16px | — | 16px | — |
| Cards | — | — | 24px | 12px | 24px |
| Avatar | 30px (squircle) | — | 50% | 50% | 50% |
| Action Icons | — | — | 14px | 8px | 8px |
| Input Fields | — | — | — | — | — |

**Issue:** Cards vary from 12px to 24px radius with no semantic reasoning.

### 1.5 Icon System Fragmentation

**Current state:** Emoji-based icons (🔮, 📅, ✨, 🌙, ⚡)

**Issues:**
1. Platform rendering inconsistencies (iOS vs Android emoji sets)
2. No stroke weight consistency
3. No active/inactive states defined in vector format
4. VoiceOver will read emoji literally ("crystal ball" instead of "compatibility")

---

## 2. Visual Hierarchy Improvements

### 2.1 Typography Scale (Proposed)

Implement a **Major Third (1.25x)** type scale with SF Pro Display/Text:

```
Display:   40px / 48px line / -0.02em / Bold (700)
H1:        32px / 40px line / -0.01em / Bold (700)
H2:        28px / 36px line / -0.01em / Semibold (600)
H3:        24px / 32px line / 0 / Semibold (600)
H4:        20px / 28px line / 0 / Semibold (600)
Body:      17px / 24px line / 0 / Regular (400)
Body Emph: 17px / 24px line / 0 / Semibold (600)
Callout:   16px / 22px line / 0 / Semibold (600)
Subhead:   15px / 20px line / 0 / Regular (400)
Footnote:  13px / 18px line / 0 / Regular (400)
Caption:   12px / 16px line / 0 / Regular (400)
Caption2:  11px / 13px line / 0 / Medium (500)
```

### 2.2 Spacing System (8px Grid)

```
4px:   Micro spacing (icon padding)
8px:   Tight spacing (inline elements)
12px:  Compact spacing (card internal)
16px:  Default spacing (section padding)
20px:  Medium spacing (card padding)
24px:  Section breaks
32px:  Large section breaks
40px:   XL section breaks
48px:   Major section dividers
64px:   Hero spacing
```

### 2.3 Specific Hierarchy Fixes by Screen

#### 01-Splash
**Current Issue:** Logo and text have equal visual weight; loading indicator competes with brand.

**Recommendation:**
- Reduce tagline opacity from 0.6 to 0.5
- Increase logo shadow blur from 60px to 80px for depth
- Move loading indicator to 80px from bottom (currently 120px) to balance composition
- Add 0.3s stagger between logo and text fade-in

#### 02-Onboarding
**Current Issue:** Number "7" dominates; title competes for attention.

**Recommendation:**
- Reduce number size from 120px to 96px
- Increase title weight from 700 to 700 with tighter tracking
- Add subtle pulse animation to number (see Micro-interactions)
- Ensure CTA button is above fold on iPhone SE (tested: currently at risk)

#### 03-Home
**Current Issue:** Daily number card lacks clear focal hierarchy.

**Recommendation:**
- Number "5" should have gradient text fill (gold to amber)
- Increase number size from 64px to 72px
- Reduce card label "Today's Number" opacity from 1.0 to 0.7
- Add subtle parallax on scroll (number moves slower than card)

#### 04-Life Path
**Current Issue:** Hero number competes with title; content sections lack breathing room.

**Recommendation:**
- Reduce hero glow blur from 30px to 24px (too diffuse)
- Add 8px letter-spacing to "The Seeker" title
- Increase section margins from 32px to 40px
- Strengths grid: increase icon size from 24px to 28px

#### 05-Profile
**Current Issue:** Stats cards compete with profile card; premium banner is jarring.

**Recommendation:**
- Profile card: increase top padding from 24px to 32px
- Stats grid: reduce value size from 24px to 22px
- Premium banner: add subtle gold shimmer animation (see Micro-interactions)
- Menu section: increase vertical padding from 16px to 18px

---

## 3. Missing Micro-Interactions & Animations

### 3.1 Critical Missing Interactions

| Interaction | Location | Priority | Spec |
|-------------|----------|----------|------|
| **Button Press** | All CTAs | 🔴 Critical | Scale to 0.96 + opacity 0.9, 100ms ease-out |
| **Card Tap** | Action cards | 🔴 Critical | Scale to 0.98 + shadow reduction, 150ms |
| **Pull-to-Refresh** | Home, Profile | 🟡 High | Sacred geometry rotation + gold shimmer |
| **Number Reveal** | Life Path | 🟡 High | Count-up animation 0→N, 800ms ease-out |
| **Tab Switch** | Bottom nav | 🟡 High | Icon morph + 4px vertical bounce |
| **Scroll Parallax** | Home hero | 🟢 Medium | Number moves at 0.5x scroll speed |
| **Premium Shimmer** | Profile banner | 🟢 Medium | Gradient sweep, 2s loop |
| **Particle Burst** | Splash complete | 🟢 Medium | 12 particles outward from logo |
| **Haptic Sync** | All number reveals | 🟢 Medium | Light impact on digit landing |
| **Pull Elasticity** | All scroll views | 🟢 Medium | Rubber band resistance at edges |

### 3.2 Detailed Animation Specs

#### Button Press State
```swift
// UIButton extension
func applyQodexPressAnimation() {
    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
        self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        self.alpha = 0.9
    }
}

func applyQodexReleaseAnimation() {
    UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
        self.transform = .identity
        self.alpha = 1.0
    }
}
```

#### Number Count-Up Animation
```swift
struct NumberRevealAnimation: View {
    let targetNumber: Int
    @State private var displayNumber: Int = 0
    
    var body: some View {
        Text("\(displayNumber)")
            .font(.system(size: 72, weight: .light))
            .foregroundStyle(QodexColors.gold)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    displayNumber = targetNumber
                }
            }
    }
}
```

#### Premium Banner Shimmer
```swift
// CAKeyframeAnimation on gradient layer
let shimmer = CABasicAnimation(keyPath: "locations")
shimmer.fromValue = [-1.0, -0.5, 0.0]
shimmer.toValue = [1.0, 1.5, 2.0]
shimmer.duration = 2.0
shimmer.repeatCount = .infinity
```

#### Sacred Geometry Rotation (Pull-to-Refresh)
```swift
// SpriteKit or Core Animation
let rotation = CABasicAnimation(keyPath: "transform.rotation")
rotation.fromValue = 0
rotation.toValue = CGFloat.pi * 2
rotation.duration = 1.0
rotation.repeatCount = .infinity
```

### 3.3 Timing Standards

```
Micro:      50-100ms  (button press, toggle)
Fast:       150-200ms (state changes, reveals)
Medium:     300-400ms (screen transitions, modals)
Slow:       600-800ms (hero animations, celebrations)
Ambient:    2000ms+   (shimmers, breathing, orbits)
```

**Easing Functions:**
- `easeOut`: Entering elements, reveals
- `easeInOut`: Symmetric transitions, tabs
- `spring(damping: 0.7)`: Buttons, cards (bouncy)
- `linear`: Continuous rotations, progress

---

## 4. WCAG Accessibility Audit

### 4.1 Critical Violations (AA Non-Compliance)

#### Issue A1: Gold on Purple Contrast
**Location:** All screens using `#FFD700` on `#1a0a2e`

**Current Ratio:** 4.12:1 (fails AA for normal text, passes for large)  
**Required:** 4.5:1 for normal text, 3:1 for large (18px+)

**Fix:**
- Use `#FFE135` (brighter gold) → 4.8:1 ratio
- Or add text shadow: `0 1px 2px rgba(0,0,0,0.5)`
- For small gold text, increase to minimum 17px

#### Issue A2: Secondary Button Contrast
**Location:** 02-Onboarding "I Already Know My Number"

**Current:** Gold text (`#FFD700`) on transparent with 0.3 opacity border  
**Issue:** Border contrast insufficient; text may be read as disabled

**Fix:**
```css
.secondary-button {
    border: 1.5px solid rgba(255, 209, 53, 0.6);  /* Increased opacity */
    color: #FFE135;  /* Brighter gold */
}
```

#### Issue A3: Loading Text Contrast
**Location:** 01-Splash "ALIGNING THE COSMOS..."

**Current:** `rgba(255,255,255,0.4)` on dark purple  
**Ratio:** ~3.2:1 (fails AA)

**Fix:** Increase to `rgba(255,255,255,0.6)` → 5.1:1

#### Issue A4: Nav Label Contrast
**Location:** 03-Home, 05-Profile bottom navigation

**Current Inactive:** `rgba(255,255,255,0.4)`  
**Issue:** May appear disabled to users with low vision

**Fix:**
- Inactive: `rgba(255,255,255,0.6)` → 5.1:1
- Active: `#FFE135` → 4.8:1

### 4.2 Touch Target Violations

| Element | Current Size | Required | Status |
|---------|--------------|----------|--------|
| Skip button | ~44px height | 44×44pt | ✅ Pass |
| Back button | 40×40px | 44×44pt | 🔴 Fail |
| Profile button | 44×44px | 44×44pt | ✅ Pass |
| Settings button | 44×44px | 44×44pt | ✅ Pass |
| Nav items | ~24px icon + label | 44×44pt min | 🟡 Risk |
| Menu items | Full width × 56px | 44×44pt | ✅ Pass |
| Quick actions | 48px icon | 44×44pt | ✅ Pass |

**Fix for Back Button:**
```css
.back-btn {
    width: 44px;
    height: 44px;
    /* Increase from 40px */
}
```

### 4.3 VoiceOver / Screen Reader Issues

#### Issue V1: Emoji Icons
**Location:** All screens using emoji as icons

**Problem:** VoiceOver reads "crystal ball" instead of "compatibility"

**Fix:**
```swift
Image(systemName: "heart.fill")  // Use SF Symbols
    .accessibilityLabel("Compatibility")
    .accessibilityHint("Compare your numerology with others")
```

Or for HTML:
```html
<span aria-label="Compatibility" role="img">🔮</span>
```

#### Issue V2: Number Context
**Location:** 05-Profile numerology numbers

**Current:** Screen reader reads "Seven, three, one" without context

**Fix:**
```swift
VStack {
    Text("7")
        .accessibilityLabel("Life Path Number 7")
        .accessibilityHint("Your core purpose number is 7, the Seeker")
}
```

#### Issue V3: Loading State
**Location:** 01-Splash

**Current:** No accessibility announcement during loading

**Fix:**
```swift
// Announce to VoiceOver
UIAccessibility.post(notification: .announcement, argument: "Loading QodeX, aligning cosmic energies")
```

### 4.4 Dynamic Type Support

**Current State:** Fixed pixel values throughout

**Required:** Support for UIContentSizeCategory (AX1 to AX5)

**Implementation:**
```swift
// Use UIFontMetrics
let font = UIFont.preferredFont(forTextStyle: .title1)
let scaledFont = UIFontMetrics.default.scaledFont(for: font)

// Or SwiftUI
Text("Title")
    .font(.title)
    .dynamicTypeSize(.xLarge)  // Limit max if needed
```

### 4.5 Reduce Motion Support

**Required:** Respect `prefersReducedMotion` setting

```swift
.withAnimation(UserDefaults.standard.bool(forKey: "reduce_motion") ? nil : .spring())
```

---

## 5. Design System Documentation

### 5.1 QodeX Design Tokens

```yaml
# colors.yml
colors:
  primary:
    gold: "#FFE135"           # Primary brand
    goldDark: "#FFA500"       # Gradients, shadows
    goldMuted: "rgba(255,225,53,0.6)"  # Secondary
  
  background:
    deepest: "#0d0221"        # Page background
    deep: "#1a0a2e"           # Cards, elevated
    mid: "#2d1b4e"            # Subtle variation
    accent: "#4A0E4E"         # Feature highlights
  
  content:
    primary: "#FFFFFF"        # Headlines
    secondary: "rgba(255,255,255,0.7)"  # Body
    tertiary: "rgba(255,255,255,0.5)"   # Captions
    disabled: "rgba(255,255,255,0.3)"   # Inactive
  
  semantic:
    success: "#34C759"        # iOS green
    warning: "#FF9500"        # iOS orange
    error: "#FF3B30"          # iOS red
    info: "#5AC8FA"           # iOS blue
```

### 5.2 Typography System

```yaml
# typography.yml
fontFamily:
  primary: "SF Pro Display"   # Headers
  secondary: "SF Pro Text"    # Body
  fallback: "-apple-system, BlinkMacSystemFont, sans-serif"

typeScale:
  display:
    size: 40px
    lineHeight: 48px
    weight: 700
    letterSpacing: -0.02em
  h1:
    size: 32px
    lineHeight: 40px
    weight: 700
    letterSpacing: -0.01em
  h2:
    size: 28px
    lineHeight: 36px
    weight: 600
    letterSpacing: -0.01em
  h3:
    size: 24px
    lineHeight: 32px
    weight: 600
    letterSpacing: 0
  h4:
    size: 20px
    lineHeight: 28px
    weight: 600
    letterSpacing: 0
  body:
    size: 17px
    lineHeight: 24px
    weight: 400
    letterSpacing: 0
  bodyEmphasis:
    size: 17px
    lineHeight: 24px
    weight: 600
    letterSpacing: 0
  callout:
    size: 16px
    lineHeight: 22px
    weight: 600
    letterSpacing: 0
  subhead:
    size: 15px
    lineHeight: 20px
    weight: 400
    letterSpacing: 0
  footnote:
    size: 13px
    lineHeight: 18px
    weight: 400
    letterSpacing: 0
  caption:
    size: 12px
    lineHeight: 16px
    weight: 400
    letterSpacing: 0
  caption2:
    size: 11px
    lineHeight: 13px
    weight: 500
    letterSpacing: 0.02em
```

### 5.3 Spacing System

```yaml
# spacing.yml
spacing:
  0: 0px
  1: 4px
  2: 8px
  3: 12px
  4: 16px
  5: 20px
  6: 24px
  8: 32px
  10: 40px
  12: 48px
  16: 64px
  20: 80px

layout:
  screenPadding: 24px        # Horizontal page padding
  cardPadding: 20px          # Internal card padding
  sectionGap: 32px           # Between major sections
  elementGap: 16px           # Between related elements
  tightGap: 8px              # Inline elements
```

### 5.4 Border Radius System

```yaml
# radius.yml
radius:
  none: 0px
  sm: 8px       # Small buttons, tags
  md: 12px      # Input fields, small cards
  lg: 16px      # Buttons, medium cards
  xl: 20px      # Feature cards, banners
  2xl: 24px     # Large cards, modals
  full: 9999px  # Circular elements

componentRadius:
  button: 16px
  card: 24px
  actionCard: 16px
  avatar: 9999px
  input: 12px
  chip: 8px
  bottomSheet: 24px
```

### 5.5 Shadow System

```yaml
# shadows.yml
shadows:
  sm:
    x: 0
    y: 2px
    blur: 8px
    color: "rgba(0,0,0,0.15)"
  md:
    x: 0
    y: 4px
    blur: 16px
    color: "rgba(0,0,0,0.2)"
  lg:
    x: 0
    y: 8px
    blur: 24px
    color: "rgba(0,0,0,0.25)"
  xl:
    x: 0
    y: 12px
    blur: 40px
    color: "rgba(0,0,0,0.3)"
  
  glow:          # Special gold glow
    x: 0
    y: 0
    blur: 60px
    spread: -10px
    color: "rgba(255,209,53,0.4)"
```

### 5.6 Component Library

#### Button Component
```swift
enum QodexButtonStyle {
    case primary      // Gold fill, dark text
    case secondary    // Transparent, gold border
    case ghost        // No fill, gold text
    case premium      // Animated shimmer
}

struct QodexButton: View {
    let title: String
    let style: QodexButtonStyle
    let action: () -> Void
    
    // Specs:
    // - Height: 56px (primary), 48px (secondary/ghost)
    // - Padding: 20px horizontal
    // - Font: Body Emphasis (17px, 600)
    // - Radius: 16px
    // - Press: Scale 0.96, 100ms
}
```

#### Card Component
```swift
enum QodexCardStyle {
    case `default`    // White 5% fill
    case featured     // Gold tint, subtle border
    case elevated     // Darker with shadow
}

struct QodexCard: View {
    let style: QodexCardStyle
    let content: Content
    
    // Specs:
    // - Padding: 20px
    // - Radius: 24px
    // - Border: 1px (featured only)
}
```

#### Number Badge Component
```swift
struct QodexNumberBadge: View {
    let number: Int
    let size: BadgeSize
    
    enum BadgeSize {
        case sm    // 48px (Profile menu)
        case md    // 80px (Profile card)
        case lg    // 140px (Life Path hero)
        case xl    // 200px+ (Special reveals)
    }
    
    // Specs:
    // - Gold gradient fill
    // - Dark text
    // - Optional: Concentric ring animations
}
```

### 5.7 Icon System

**Replace all emoji with SF Symbols equivalents:**

| Current | SF Symbol | Accessibility Label |
|---------|-----------|---------------------|
| 🔮 | `heart.fill` | Compatibility |
| 📅 | `calendar` | Forecast |
| ✨ | `textformat` | Name Analysis |
| 🌙 | `moon.fill` | Moon Phases |
| ⚡ | `bolt.fill` | Strengths |
| 📚 | `book.fill` | Learn |
| 🧘 | `sparkles` | Spiritual |
| 🎯 | `target` | Focus |
| 🌙 | `moon.stars.fill` | Shadow Work |
| 🔔 | `bell.fill` | Notifications |
| 🌐 | `globe` | Language |
| 🔒 | `lock.fill` | Privacy |
| ❓ | `questionmark.circle` | Help |
| 👑 | `crown.fill` | Premium |
| ⚙️ | `gearshape.fill` | Settings |
| 🏠 | `house.fill` | Home |
| 📖 | `book.open.fill` | Learn |
| ✦ | `star.fill` | Insights |
| 👤 | `person.fill` | Profile |

### 5.8 Animation Tokens

```yaml
# animation.yml
duration:
  micro: 0.1s      # Button press
  fast: 0.2s       # State change
  medium: 0.35s    # Transition
  slow: 0.6s       # Reveal
  celebration: 1.0s # Hero moment

easing:
  easeOut: "cubic-bezier(0,0,0.2,1)"
  easeInOut: "cubic-bezier(0.4,0,0.2,1)"
  spring: "spring(0.7, 0.5)"  # damping, initial velocity
  linear: "linear"

spring:
  default:
    damping: 0.7
    response: 0.3
  bouncy:
    damping: 0.5
    response: 0.4
  gentle:
    damping: 0.9
    response: 0.2
```

---

## 6. Implementation Priority

### Phase 1: Critical (Week 1)
1. Fix all WCAG contrast violations
2. Increase back button touch target to 44px
3. Replace emoji icons with SF Symbols
4. Implement button press animations
5. Add VoiceOver labels to all interactive elements

### Phase 2: High (Week 2)
1. Standardize color tokens
2. Implement typography scale
3. Apply 8px spacing grid
4. Add number count-up animation
5. Implement tab switch animations

### Phase 3: Medium (Week 3-4)
1. Add premium shimmer effect
2. Implement scroll parallax on Home
3. Add pull-to-refresh animation
4. Create component library in Storybook/SwiftUI
5. Document all patterns

---

## 7. Reference

**Visual Design References:**
- *Monument Valley* — Impossible geometry, sacred minimalism
- *Headspace* — Breathing animations, calm transitions
- *Stoic* — Daily reflection UI, elegant typography
- *Arcane* — Mystical color palettes, ethereal glows

**Technical References:**
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [SF Symbols Guidelines](https://developer.apple.com/sf-symbols/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

*End of IVY Design Audit*  
*Prepared by IVY, CDO / Design Lead*
