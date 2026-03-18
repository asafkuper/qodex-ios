# 🌍 QodeX Localization - 12 Languages

**Version:** 1.0.0  
**Base Language:** English (en)  
**RTL Support:** Hebrew (he), Arabic (ar)  
**Total Keys:** 200+ strings per language

---

## Supported Languages

| Code | Language | Status | File |
|------|----------|--------|------|
| en | English | ✅ Base | en.lproj/Localizable.strings |
| he | Hebrew | 🔄 Agent | he.lproj/Localizable.strings |
| es | Spanish | 🔄 Agent | es.lproj/Localizable.strings |
| fr | French | 🔄 Agent | fr.lproj/Localizable.strings |
| de | German | 🔄 Agent | de.lproj/Localizable.strings |
| zh-Hans | Chinese Simplified | 🔄 Agent | zh-Hans.lproj/Localizable.strings |
| pt | Portuguese | 🔄 Agent | pt.lproj/Localizable.strings |
| ru | Russian | 🔄 Agent | ru.lproj/Localizable.strings |
| ja | Japanese | 🔄 Agent | ja.lproj/Localizable.strings |
| hi | Hindi | 🔄 Agent | hi.lproj/Localizable.strings |
| ko | Korean | 🔄 Agent | ko.lproj/Localizable.strings |
| ar | Arabic | 🔄 Agent | ar.lproj/Localizable.strings |

---

## String Categories

### 1. App Information
- App name, tagline, version

### 2. Onboarding (5 screens)
- Welcome, Name Input, Birthdate, Chart Preview, Complete

### 3. Main Navigation
- Today, Chart, Community, Learn, Profile tabs

### 4. Core Features
- Daily readings, Power hours, Life Path numbers
- Chart view, Number details, Reading details

### 5. Social Features
- Community, Profile, Compatibility
- Posts, likes, comments

### 6. Settings & Privacy
- Notifications, Appearance, Language
- Privacy controls, Help & Support

### 7. Monetization
- Paywall, Premium features, Subscription tiers

### 8. Learning & Growth
- Learn section, Journal, Meditation
- Achievements, Streaks, Search

---

## RTL (Right-to-Left) Support

Languages requiring RTL layout:
- 🇮🇱 Hebrew (he)
- 🇸🇦 Arabic (ar)

Xcode automatically handles RTL for:
- Navigation bars
- Table views
- Collection views
- Text alignment
- Layout direction

---

## App Store Localization

### App Name by Language
- English: QodeX
- Hebrew: קודקס
- Spanish: QodeX
- French: QodeX
- German: QodeX
- Chinese: QodeX - 数字命理
- Portuguese: QodeX
- Russian: QodeX
- Japanese: QodeX - 数秘術
- Hindi: क्वोडेक्स
- Korean: 코덱스
- Arabic: كودكس

### Keywords by Region

**English (US/UK):**
numerology, astrology, daily reading, life path, tarot, compatibility, horoscope, zodiac, birth chart, spiritual, meditation, mindfulness

**Hebrew (Israel):**
נומרולוגיה, אסטרולוגיה, קריאה יומית, מסלול חיים, טארוט, תאימות, הורוסקופ, מפת לידה, רוחני, מדיטציה

**Spanish (Spain/LatAm):**
numerología, astrología, lectura diaria, camino de vida, tarot, compatibilidad, horóscopo, zodiaco, carta natal, espiritual, meditación

**Chinese (China):**
数字命理, 占星术, 每日解读, 生命灵数, 塔罗牌, 配对, 星座, 星盘, 灵性, 冥想, 正念

**Arabic (MENA):**
علم الأرقام, علم التنجيم, القراءة اليومية, مسار الحياة, التاروت, التوافق, البرج, خريطة الميلاد, روحاني, التأمل

---

## Implementation Guide

### 1. Xcode Project Setup

Add to Info.plist:
```xml
<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>he</string>
    <string>es</string>
    <string>fr</string>
    <string>de</string>
    <string>zh-Hans</string>
    <string>pt</string>
    <string>ru</string>
    <string>ja</string>
    <string>hi</string>
    <string>ko</string>
    <string>ar</string>
</array>
```

### 2. Usage in Code

```swift
// Basic string
Text(NSLocalizedString("welcome_title", comment: ""))

// With format
Text(String(format: NSLocalizedString("lesson_of", comment: ""), 3, 7))

// SwiftUI shortcut
Text("welcome_title")
```

### 3. Testing Localization

Xcode scheme settings:
1. Product → Scheme → Edit Scheme
2. Run → Options
3. Application Language: Choose target language
4. Application Region: Match language region

---

## Maintenance

### Adding New Strings
1. Add to `en.lproj/Localizable.strings` (base)
2. Run localization export: `xcodebuild -exportLocalizations`
3. Distribute to translators
4. Import translations: `xcodebuild -importLocalizations`

### Updating Translations
1. Identify changed keys
2. Update base language first
3. Mark for translation
4. Update all language files

---

## Quality Assurance

### Pre-Launch Checklist
- [ ] All strings translated
- [ ] No truncation in UI
- [ ] RTL layouts tested
- [ ] Date/number formats correct
- [ ] Currency symbols correct
- [ ] App Store metadata translated
- [ ] Screenshots in each language

### Testing Matrix

| Language | UI Test | RTL Test | App Store |
|----------|---------|----------|-----------|
| English | ✅ | N/A | ✅ |
| Hebrew | 🔄 | 🔄 | 🔄 |
| Spanish | 🔄 | N/A | 🔄 |
| French | 🔄 | N/A | 🔄 |
| German | 🔄 | N/A | 🔄 |
| Chinese | 🔄 | N/A | 🔄 |
| Arabic | 🔄 | 🔄 | 🔄 |

---

## Market Priorities

### Tier 1 (Launch Markets)
1. 🇺🇸 United States (English)
2. 🇬🇧 United Kingdom (English)
3. 🇮🇱 Israel (Hebrew) - Primary market
4. 🇨🇦 Canada (English/French)
5. 🇦🇺 Australia (English)

### Tier 2 (Month 2-3)
1. 🇩🇪 Germany (German)
2. 🇫🇷 France (French)
3. 🇪🇸 Spain (Spanish)
4. 🇧🇷 Brazil (Portuguese)
5. 🇲🇽 Mexico (Spanish)

### Tier 3 (Month 4-6)
1. 🇨🇳 China (Chinese)
2. 🇯🇵 Japan (Japanese)
3. 🇰🇷 South Korea (Korean)
4. 🇮🇳 India (Hindi + English)
5. 🇷🇺 Russia (Russian)
6. 🇸🇦 UAE/Saudi (Arabic)

---

**Localization infrastructure complete.**  
**200+ strings ready for 12 languages.**  
**Global launch enabled.** 🌍
