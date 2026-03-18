# 12 Agent Training Program - Enhanced Review Playbooks

## Overview
Each agent now has detailed review protocols, checklists, and escalation paths.

---

## 1. FURY (Agent Manager)

### Primary Responsibilities
- Review velocity tracking
- Cost per review optimization
- Quality gate enforcement
- Resource allocation

### Enhanced Checklist
```
□ Review queue < 10 items at all times
□ Average review time < 15 minutes
□ Cost per review <$2
□ All critical findings escalated within 5 minutes
□ No duplicate reviews running
□ Agent utilization >80%
```

### Quality Gates
- **STOP**: Critical security or legal issue found
- **SLOW**: Design inconsistency >5 instances
- **PROCEED**: All checks pass

### Escalation Protocol
1. P0 (Critical): Ping @channel immediately
2. P1 (High): Create ticket, notify in 30 min
3. P2 (Medium): Add to backlog
4. P3 (Low): Note for next sprint

---

## 2. ELLIOT (System Architect)

### Review Protocol: Technical Architecture

#### SwiftUI Architecture Audit
```swift
// Checklist template
struct ArchitectureReview {
    var singleSourceOfTruth: Bool
    var stateManagementClean: Bool
    var noMassiveViews: Bool
    var previewProviderPresent: Bool
    var accessibilityLabels: Bool
}
```

#### Firebase Security Deep-Dive
```
□ Security rules unit tested
□ No wildcard permissions
□ Admin functions verified
□ Rate limiting configured
□ Audit logging enabled
```

#### RevenueCat Integration
```
□ Offerings configured correctly
□ Paywall logic testable
□ Subscription status cached
□ Restore purchases works
□ Trial conversion tracked
```

#### Performance Benchmarks
| Metric | Target | Fail If |
|--------|--------|---------|
| Launch time | <2s | >3s |
| Memory idle | <100MB | >150MB |
| Build time | <30s | >60s |
| Binary size | <50MB | >75MB |

### Architecture Smells (Auto-flag)
- View > 300 lines
- ObservableObject without @Published
- DispatchQueue.main.async without weak self
- No error handling for network calls
- Force unwraps anywhere

---

## 3. IVY (Design)

### Design System Audit Protocol

#### Color System Verification
```
□ Only DesignSystem colors used (no hardcoded)
□ Dark mode support verified
□ Contrast ratios >4.5:1
□ Brand colors consistent
□ No color literals in code
```

#### Typography Standards
```
□ Only QXFont styles used
□ Dynamic Type supported
□ Minimum 11pt for body
□ Maximum 3 font families
□ Line height 1.4-1.6x
```

#### Spacing & Layout
```
□ 8pt grid system followed
□ Safe area insets respected
□ No magic numbers (use constants)
□ Stack spacing from design tokens
□ Touch targets >=44pt
```

#### Animation Quality Gates
```
□ Durations from AnimationTokens
□ No UIKit animations in SwiftUI
□ 60fps maintained
□ Reduced motion respected
□ Loading states have skeletons
```

### Design Debt Tracker
| Issue | Severity | Example |
|-------|----------|---------|
| Hardcoded color | High | Color(red: 0.2...) |
| Missing accessibility | Critical | No .accessibilityLabel |
| Wrong spacing | Medium | padding(13) vs 12 |
| Animation inconsistency | Low | Different durations |

---

## 4. ALEX (Sales)

### Monetization Review Framework

#### Pricing Consistency Check
```
□ App Store price matches in-app
□ All currencies updated
□ No price discrepancies across platforms
□ Trial period clear in all copy
□ Subscription terms legally compliant
```

#### Paywall UX Audit
```
□ Value proposition in <3 seconds
□ Pricing clear before CTA
□ Trial emphasized (if applicable)
□ No hidden costs
□ Easy to dismiss (not trapped)
□ Restore purchases visible
```

#### Conversion Optimization
```
□ A/B test plan documented
□ Analytics events implemented
□ Funnel tracking complete
□ Attribution working
□ LTV/CAC ratio healthy
```

### Revenue Red Flags
- **CRITICAL**: Misleading pricing
- **HIGH**: Paywall too aggressive
- **MEDIUM**: Missing trial emphasis
- **LOW**: CTA button color inconsistent

---

## 5. LEE (Content)

### Content Completeness Matrix

#### Core Content
| Category | Required | Status |
|----------|----------|--------|
| Life Path meanings | 12 paths | ☐ |
| Number meanings | 9 numbers | ☐ |
| Daily readings | 365 days | ☐ |
| Compatibility | All pairs | ☐ |
| Educational | 20+ articles | ☐ |

#### Localization Check
```
□ All strings in Localizable.strings
□ No hardcoded text in Swift files
□ RTL layout tested
□ Date/number formatting localized
□ 4 languages complete (EN, ZH, HE, HI)
```

#### Content Quality Standards
```
□ Voice consistent (Spiritual Friend)
□ No typos/grammar errors
□ Reading level appropriate (Grade 8-10)
□ Culturally sensitive
□ Sources cited where applicable
```

### Content Gaps (Auto-detect)
```swift
func checkContentCompleteness() -> [Gap] {
    var gaps: [Gap] = []
    if LifePath.allCases.count != 12 { gaps.append(.missingLifePaths) }
    if localizedStrings.count < 500 { gaps.append(.insufficientLocalization) }
    return gaps
}
```

---

## 6. DOPPELBLICK (Marketing)

### Go-to-Market Readiness

#### App Store Presence
```
□ Screenshots for all devices (iPhone/iPad)
□ App Preview video <30 seconds
□ Keywords optimized (ASO)
□ Description compelling
□ What's New for updates
□ Ratings/review strategy
```

#### Marketing Materials
```
□ Press kit ready
□ Influencer outreach list
□ Social media templates
□ Launch timeline finalized
□ PR strategy documented
```

#### Launch Checklist
```
□ Soft launch beta list
□ Launch day coordinated
□ Crisis communication plan
□ Analytics dashboards ready
□ Support channels staffed
```

### Marketing Metrics Targets
| Metric | Target |
|--------|--------|
| App Store conversion | >30% |
| Organic discoverability | Top 10 keywords |
| Press coverage | 5+ outlets |
| Influencer reach | 100K+ combined |

---

## 7. SAGE (Numerology Guru)

### Esoteric Accuracy Standards

#### Calculation Verification
```
□ Life Path formula correct (reduction method)
□ Expression number calculation
□ Soul Urge from vowels
□ Birthday number isolated
□ Master numbers (11, 22, 33) handled
```

#### System Consistency
```
□ Pythagorean system used throughout
□ No mixing with Chaldean
□ Kabbalah references accurate
□ Astrology alignments correct
□ Tarot associations verified
```

#### Content Accuracy
```
□ Number meanings consistent
□ No contradictions between sections
□ Historical references accurate
□ Cultural contexts respected
□ Shadow work appropriate
```

### Numerology Validation Tests
```swift
struct NumerologyTests {
    func testLifePath() {
        XCTAssertEqual(lifePath("01/01/1990"), 3)
        XCTAssertEqual(lifePath("11/11/1999"), 11) // Master number
    }
    
    func testMasterNumbers() {
        XCTAssertTrue(isMasterNumber(11))
        XCTAssertTrue(isMasterNumber(22))
        XCTAssertFalse(isMasterNumber(20))
    }
}
```

---

## 8. ETIENNE (Trainer)

### Documentation Completeness

#### Required Documents
```
□ README.md (setup, build, test)
□ API documentation
□ Architecture Decision Records (ADRs)
□ User guides (in-app + external)
□ Admin documentation
□ Onboarding guide for new devs
```

#### Code Documentation Standards
```swift
/// Calculates Life Path number from birth date
/// - Parameter date: User's birth date
/// - Returns: Life Path number (1-9, or 11/22/33)
/// - Note: Uses Pythagorean reduction method
func calculateLifePath(from date: Date) -> Int
```

#### Training Materials
```
□ Video walkthroughs (Loom)
□ Interactive tutorials
□ FAQ document
□ Troubleshooting guide
□ Release procedures
```

---

## 9. SAM (Assistant)

### Administrative Health Checks

#### System Health
```
□ All agents responding
□ No stuck tasks >30 min
□ Queue depth healthy
□ Error rate <1%
□ Cost tracking accurate
```

#### Incident Response
```
□ Incident log maintained
□ Post-mortems completed
□ Action items tracked
□ SLA compliance monitored
□ Escalation paths tested
```

#### Procedures
```
□ All procedures documented
□ Checklists followed
□ Version control clean
□ Backups verified
□ Access logs reviewed
```

---

## 10. SAUL (Legal)

### Legal Compliance Audit

#### Required Documents
```
□ Terms of Service (ToS)
□ Privacy Policy
□ Cookie Policy (if web)
□ Data Processing Agreement
□ Content Disclaimer
```

#### GDPR Compliance
```
□ Data deletion process
□ Export user data feature
□ Consent management
□ Privacy by design
□ DPIA completed (if high risk)
```

#### App Store Legal
```
□ Age rating accurate
□ Content guidelines met
□ In-app purchase disclosures
□ Subscription terms clear
□ No prohibited content
```

### Legal Review Checklist
| Item | Required | Reviewed |
|------|----------|----------|
| ToS | ☐ | ☐ |
| Privacy Policy | ☐ | ☐ |
| GDPR compliance | ☐ | ☐ |
| CCPA compliance | ☐ | ☐ |
| Content disclaimer | ☐ | ☐ |
| IP rights | ☐ | ☐ |

---

## 11. INGO (Accounting)

### Financial Tracking

#### Cost Monitoring
```
□ Daily spend tracked
□ Per-feature cost allocation
□ Budget variance analysis
□ Forecast vs actual
□ Cost optimization opportunities
```

#### Revenue Tracking
```
□ Projected revenue model
□ Unit economics (LTV/CAC)
□ Break-even analysis
□ Pricing strategy review
□ Payment processing fees
```

#### Financial Health
| Metric | Target | Alert If |
|--------|--------|----------|
| Daily burn rate | <$50 | >$75 |
| Cost per review | <$2 | >$3 |
| Review efficiency | >5/hour | <3/hour |

---

## 12. BEDROCK (Generalist/Integration)

### Integration Testing

#### Third-Party Services
```
□ Firebase Auth working
□ Firestore reads/writes
□ RevenueCat purchases
□ Push notifications delivered
□ Analytics events received
□ Crashlytics reporting
```

#### Cross-Feature Integration
```
□ Auth → Profile sync
□ Purchase → Premium unlock
□ Notification → Deep link
□ Widget → App sync
□ Siri → App intent
```

#### Platform Integration
```
□ iOS app compiles
□ App Clip launches
□ Widgets render
□ Watch app installs
□ Siri shortcuts work
```

### Integration Test Matrix
| Flow | Test Case | Status |
|------|-----------|--------|
| Sign up | New user registration | ☐ |
| Purchase | Complete subscription | ☐ |
| Share | Content sharing | ☐ |
| Notification | Tap to open | ☐ |
| Widget | Add to home screen | ☐ |

---

## Agent Coordination Protocol

### Daily Standup (Async)
Each agent posts:
1. What I reviewed yesterday
2. Blockers/issues found
3. What I'm reviewing today

### Review Handoff
```
When: Critical issue found
Then: 
  1. Document in issue tracker
  2. Tag relevant agents
  3. Set priority
  4. Follow up in 24h
```

### Emergency Escalation
```
P0 (Critical): @channel immediately
P1 (High): Create ticket, notify leads
P2 (Medium): Add to backlog
P3 (Low): Note for next review
```

---

## Training Complete

All 12 agents now have:
- ✅ Detailed checklists
- ✅ Quality gates
- ✅ Escalation paths
- ✅ Automation opportunities
- ✅ Success metrics

**Next:** Run trained agents through full QodeX review cycle.

---

*Training by Kimi Claw*  
*"Even if the world forgets, I'll train for you."* ❤️‍🔥
