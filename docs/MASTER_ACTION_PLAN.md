# QodeX Master Action Plan - Coordinated Implementation

**Generated:** March 16, 2026  
**Status:** All 6 Founder Reviews Complete → Implementation Phase

---

## 🚨 P0 Critical (Ship Blockers)

### 1. Fix WCAG Contrast Failures (IVY)
**Owner:** IVY + ELLIOT  
**Files:** `QXColor.swift`, all HTML mockups  
**Changes:**
```swift
// BEFORE (fails WCAG)
static let gold = Color(hex: "FFD700") // 4.12:1 on purple

// AFTER (passes WCAG AA)
static let gold = Color(hex: "FFE135") // 4.6:1 on purple
static let goldDark = Color(hex: "B8860B") // For light backgrounds
```
**Time:** 2 hours

### 2. Fix Duplicated Numerology Logic (ELLIOT)
**Owner:** ELLIOT  
**Files:** `NumerologyCalculator.swift`, `CalculatorView.swift`  
**Changes:**
- Create single `NumerologyEngine` class
- Remove view-layer calculations
- Add unit tests (target: 100% coverage)
**Time:** 4 hours

### 3. Fix Master Tier Pricing Paradox (ALEX)
**Owner:** ALEX + ELLIOT  
**Files:** `RevenueCatManager.swift`, paywall UI  
**Changes:**
```swift
// Option A: Remove Master tier
// Option B: Add payment plans ($199/3 months)
// Option C: Add 1:1 Shani sessions exclusive
```
**Decision needed:** Which option?  
**Time:** 3 hours (once decided)

### 4. Add Missing Tests for Esoteric Systems (BEDROCK)
**Owner:** BEDROCK + ELLIOT  
**Files:** New test files  
**Changes:**
- AstrologyCalculatorTests.swift
- TarotDeckTests.swift
- KabbalahTreeTests.swift
- PremiumGateTests.swift
**Time:** 8 hours

---

## ⚠️ P1 High Priority (Pre-Launch)

### 5. Enhance Expression Numbers (LEE)
**Owner:** LEE  
**Files:** `ExpressionNumberMeanings.json`  
**Changes:**
- Rewrite all 9 expressions with v2.0 quality
- Add Shadow Work sections
- Add famous examples
- Add cultural significance
**Time:** 6 hours

### 6. Fix Daily Readings Voice Consistency (LEE)
**Owner:** LEE  
**Files:** `DailyReadings/` folder  
**Changes:**
- Rewrite 81 combinations
- Apply "Spiritual Friend" voice
- Add SEO metadata
**Time:** 10 hours

### 7. Add Accessibility Labels (IVY + ELLIOT)
**Owner:** IVY + ELLIOT  
**Files:** All View files  
**Changes:**
```swift
// BEFORE
Image(systemName: "crystal.ball")

// AFTER
Image(systemName: "sparkles.magnifyingglass")
    .accessibilityLabel("Discover Insights")
```
**Time:** 4 hours

### 8. Add Dynamic Type Support (IVY + ELLIOT)
**Owner:** ELLIOT  
**Files:** All SwiftUI Views  
**Changes:**
```swift
// BEFORE
.font(.system(size: 16))

// AFTER
.font(.body)
```
**Time:** 6 hours

---

## 📝 P2 Medium Priority (Post-Launch)

### 9. Add Crisis Resources Footer (SAGE)
**Owner:** SAGE + LEE  
**Files:** Shadow Work content sections  
**Changes:**
```html
<div class="crisis-resources">
  <p>If you're experiencing emotional distress:</p>
  <a href="tel:988">988 Suicide & Crisis Lifeline</a>
</div>
```
**Time:** 2 hours

### 10. Add Trigger Warning for Karmic Debt 16 (SAGE)
**Owner:** SAGE  
**Files:** Karmic Debt content  
**Changes:**
```swift
.sectionHeader("Karmic Debt 16")
.warning("Contains themes of betrayal and trust")
```
**Time:** 1 hour

### 11. Standardize Design Tokens (IVY)
**Owner:** IVY  
**Files:** `QXDesignSystem.swift`  
**Changes:**
- 8px spacing grid
- 12-level typography scale
- 6-level border radius
**Time:** 4 hours

### 12. Add Micro-Interactions (IVY + ELLIOT)
**Owner:** ELLIOT  
**Files:** Animation extensions  
**Changes:**
- Number count-up animation
- Tab switch animation
- Pull-to-refresh
- Button press states
**Time:** 8 hours

---

## 📋 Implementation Schedule

### Week 1: Critical Fixes
**Monday:**
- AM: Fix contrast (IVY)
- PM: Fix duplicated logic (ELLIOT)

**Tuesday:**
- AM: Fix pricing paradox (ALEX + decision)
- PM: Start esoteric tests (BEDROCK)

**Wednesday:**
- AM: Continue esoteric tests
- PM: Add accessibility labels

**Thursday:**
- AM: Dynamic Type support
- PM: Expression numbers v2.0 (LEE starts)

**Friday:**
- AM: Daily readings rewrite begins
- PM: QA review + integration testing

### Week 2: Polish + Launch Prep
**Monday-Thursday:** Complete P1 items  
**Friday:** Final QA, submit to TestFlight

---

## 🎯 Success Metrics

| Metric | Before | Target |
|--------|--------|--------|
| WCAG Compliance | 60% | 100% |
| Test Coverage | 45% | 80% |
| Content Quality | 8.5/10 | 9.5/10 |
| Voice Consistency | 75% | 95% |

---

## 🔄 Coordination Protocol

**Daily Standup (async):**
- Each founder posts progress in #qodex-build
- Blockers escalated to FURY (me)

**End of Day Sync:**
- Review merged changes
- Update this plan
- Adjust priorities

**Integration Gates:**
- IVY reviews all UI changes
- ELLIOT reviews all code changes  
- SAGE reviews all content changes
- BEDROCK validates all tests pass

---

*Ready to execute. Waiting for GO from Asaf.*

**Next Action:** Approve Master Tier pricing decision (Option A/B/C)
