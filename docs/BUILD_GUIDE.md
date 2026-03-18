# QodeX iOS App - Complete Build Guide

## 🚀 Quick Start

### Prerequisites
- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ deployment target
- Apple Developer Account ($99/year)
- Firebase account (free)
- RevenueCat account (free tier available)

### 1. Clone & Setup

```bash
git clone https://github.com/yourusername/qodex-ios.git
cd qodex-ios
```

### 2. Install Dependencies

**Option A: Swift Package Manager (Recommended)**
- Open `QodeX.xcodeproj` in Xcode
- Xcode will automatically resolve SPM dependencies

**Option B: CocoaPods**
```bash
pod install
open QodeX.xcworkspace
```

### 3. Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "QodeX Academy"
3. Add iOS app with bundle ID: `academy.qodex.app`
4. Download `GoogleService-Info.plist`
5. Add to `QodeX/Resources/`

**Enable Firebase Services:**
- Authentication (Email, Google, Apple)
- Firestore Database
- Cloud Storage
- Cloud Messaging (Push Notifications)
- Analytics
- Crashlytics

### 4. RevenueCat Configuration

1. Sign up at [RevenueCat](https://www.revenuecat.com/)
2. Create app with bundle ID: `academy.qodex.app`
3. Configure products:
   - `com.qodex.seeker.monthly` - $19.99
   - `com.qodex.seeker.annual` - $179.99
   - `com.qodex.initiate.monthly` - $49.99
   - `com.qodex.initiate.annual` - $449.99
   - `com.qodex.master.monthly` - $199.99
   - `com.qodex.master.annual` - $1,799.99

4. Copy API key to `SubscriptionManager.swift`

### 5. Google Sign-In Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 credentials
3. Add `REVERSED_CLIENT_ID` to URL schemes in Info.plist

### 6. Configure App

Edit `Config.xcconfig`:
```
FIREBASE_API_KEY = your_key
REVENUECAT_API_KEY = your_key
GOOGLE_CLIENT_ID = your_client_id
```

## 📱 App Store Deployment

### Fastlane Setup

```bash
# Install Fastlane
brew install fastlane

# Initialize
cd qodex-ios
fastlane init

# Configure Match for code signing
fastlane match init
```

### Deploy Commands

```bash
# Run tests
fastlane test

# Upload to TestFlight (Beta)
fastlane beta

# Deploy to App Store
fastlane release
```

### App Store Connect Setup

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Create new app:
   - Name: QodeX Inner Circle
   - Bundle ID: academy.qodex.app
   - SKU: QODEX-001

3. Required assets:
   - App Icon (1024x1024)
   - Screenshots (iPhone 6.7", 6.5", 5.5")
   - App Preview video (optional)

4. App Information:
   - Category: Lifestyle / Education
   - Age Rating: 4+
   - Price: Free (with subscriptions)

## 🏗 Architecture

```
QodeX/
├── App/
│   ├── QodeXApp.swift          # App entry point
│   └── AppDelegate.swift       # Firebase/RC setup
├── Core/
│   ├── Authentication/         # AuthManager
│   ├── Subscription/           # RevenueCat integration
│   ├── Networking/             # API clients
│   ├── Persistence/            # CoreData/UserDefaults
│   └── Models/                 # Data models
├── Features/
│   ├── Auth/                   # Login/Signup flows
│   ├── Dashboard/              # Home screen
│   ├── Calculator/             # Qode calculator
│   ├── Library/                # Teachings
│   ├── Community/              # Inner Circle
│   ├── Subscription/           # Paywall
│   └── Profile/                # User profile
├── DesignSystem/
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Components/
│   └── Animations/
└── Resources/
    ├── Assets.xcassets
    ├── GoogleService-Info.plist
    └── Localizations/
```

## 🎨 Design System

### Colors
- Cosmic Black: `#0A0A0F`
- Deep Void: `#12121A`
- Gold: `#D4AF37`
- Mystic Purple: `#6B4EE6`
- Cosmic Teal: `#00D4AA`

### Typography
- Display: SF Pro Display Bold 32pt
- Headline: SF Pro Display Semibold 24pt
- Body: SF Pro Text Regular 16pt
- Caption: SF Pro Text Medium 12pt

## 🔐 Security Checklist

- [ ] Enable App Transport Security (ATS)
- [ ] Configure Keychain for sensitive data
- [ ] Implement certificate pinning
- [ ] Add biometric authentication option
- [ ] Enable Firebase App Check
- [ ] Configure RevenueCat webhook verification
- [ ] Set up Cloud Firestore security rules

## 📊 Analytics Events

Track these key events:
- `signup_complete` - User registration
- `subscription_started` - Purchase initiated
- `subscription_completed` - Purchase successful
- `content_started` - Video/lesson started
- `qode_calculated` - Calculator used
- `community_posted` - User posted in community

## 🚀 Post-Launch

### Week 1
- Monitor Crashlytics for crashes
- Check RevenueCat for purchase issues
- Respond to App Store reviews
- Track daily active users

### Month 1
- Analyze subscription conversion
- A/B test paywall designs
- Add requested features
- Plan content updates

## 📞 Support

For technical issues:
- Firebase: support@firebase.google.com
- RevenueCat: support@revenuecat.com
- Apple Developer: developer.apple.com/contact

---

Built with intention for the QodeX community.
