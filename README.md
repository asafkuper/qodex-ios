# QodeX Inner Circle iOS App

[![Swift Version](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

> A premium numerology and energetic decoding experience for QodeX Academy members.

## ✨ Features

- **Secure Member Access** — JWT-based authentication for Inner Circle members
- **Personal Qode Calculator** — Birth date/name decoding with real-time calculations
- **Teachings Library** — Curated content from Shani's numerology courses
- **Live Sessions** — Access to exclusive member calls and replays
- **Community Hub** — Inner circle discussions and connections
- **Offline Access** — Download teachings for offline study
- **Progress Tracking** — Personal journey visualization

## 🎨 Design Philosophy

**Reference:** *Monument Valley* geometry + *Headspace* calm + *Apple Design Awards* polish

- Deep cosmic blacks (`#0A0A0F`)
- Sacred geometry accents
- Subtle gold highlights (`#D4AF37`)
- Fluid micro-interactions
- Precision typography (SF Pro Display + Custom Serif for mystical elements)

## 🏗 Architecture

```
QodeX/
├── App/
│   ├── QodeXApp.swift
│   └── AppDelegate.swift
├── Core/
│   ├── Networking/
│   ├── Authentication/
│   └── Persistence/
├── Features/
│   ├── Auth/
│   ├── Dashboard/
│   ├── Calculator/
│   ├── Library/
│   ├── Community/
│   └── Profile/
├── DesignSystem/
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Components/
│   └── Animations/
└── Resources/
    ├── Assets.xcassets
    └── Localizations/
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ target
- Apple Developer Account (for App Store)

### Installation

```bash
git clone https://github.com/yourusername/qodex-ios.git
cd qodex-ios
open QodeX.xcodeproj
```

### Configuration

1. Copy `Config.template.xcconfig` to `Config.xcconfig`
2. Add your API endpoints and keys
3. Configure Firebase (Auth + Firestore)
4. Set up RevenueCat for subscriptions

## 📱 App Store Deployment

### Fastlane Setup
```bash
bundle install
bundle exec fastlane init
```

### Build & Upload
```bash
# TestFlight
bundle exec fastlane beta

# App Store
bundle exec fastlane release
```

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed instructions.

## 🔐 Security

- Keychain for sensitive data
- Certificate pinning for API calls
- Biometric authentication option
- No PII in logs

## 📄 License

Proprietary — QodeX Academy. All rights reserved.

---

Built with intention by the QodeX team.
