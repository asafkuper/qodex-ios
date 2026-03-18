# QodeX App Store Deployment Guide
## Complete Step-by-Step Instructions

---

## PHASE 1: PREPARATION (Day 1)

### 1.1 Apple Developer Account Setup

**If you don't have an account:**
1. Go to https://developer.apple.com/programs/
2. Click "Enroll" → Individual ($99/year) or Organization ($299/year)
3. Complete enrollment (1-2 business days for approval)

**If you have an account:**
1. Log in to https://developer.apple.com/account/
2. Verify membership is active
3. Check that you can access Certificates, Identifiers & Profiles

---

### 1.2 App Store Connect Setup

1. Go to https://appstoreconnect.apple.com/
2. Click "My Apps"
3. Click "+" → "New App"
4. Fill in:
   - **Platform**: iOS
   - **App Name**: QodeX Inner Circle
   - **Primary Language**: English
   - **Bundle ID**: academy.qodex.app (must match Xcode)
   - **SKU**: QODEX-001
   - **User Access**: Full Access

---

## PHASE 2: CERTIFICATES & PROFILES (Day 1-2)

### 2.1 Using Fastlane Match (Recommended)

```bash
# Install Fastlane
brew install fastlane

# Navigate to project
cd /path/to/qodex-ios

# Initialize match
fastlane match init

# Create certificates
fastlane match development
fastlane match appstore
```

### 2.2 Manual Setup (Alternative)

**Step 1: Create Certificate Signing Request (CSR)**
```bash
# On your Mac
openssl genrsa -out mykey.key 2048
openssl req -new -key mykey.key -out CertificateSigningRequest.certSigningRequest \
  -subj "/emailAddress=you@example.com, CN=Your Name, C=US"
```

**Step 2: Create Certificates in Developer Portal**
1. Go to https://developer.apple.com/account/resources/certificates/list
2. Click "+" → "iOS App Development" → Continue
3. Upload CSR → Download certificate
4. Repeat for "Apple Distribution"

**Step 3: Install Certificates**
```bash
double-click ios_development.cer
double-click ios_distribution.cer
```

**Step 4: Create App ID**
1. Go to https://developer.apple.com/account/resources/identifiers/list/bundleId
2. Click "+" → "App IDs"
3. Description: QodeX Inner Circle
4. Bundle ID: Explicit → academy.qodex.app
5. Enable capabilities:
   - ☑️ Push Notifications
   - ☑️ In-App Purchase
   - ☑️ Sign In with Apple

**Step 5: Create Provisioning Profiles**
1. Go to https://developer.apple.com/account/resources/profiles/list
2. Click "+" → "iOS App Development" → Select App ID → Download
3. Click "+" → "App Store" → Select App ID → Download

---

## PHASE 3: XCODE CONFIGURATION (Day 2)

### 3.1 Project Settings

**Open QodeX.xcodeproj and verify:**

```
TARGETS → QodeX → General → Identity
├── Display Name: QodeX
├── Bundle Identifier: academy.qodex.app
├── Version: 1.0.0
├── Build: 1
└── Team: [Your Apple ID]
```

### 3.2 Signing & Capabilities

```
TARGETS → QodeX → Signing & Capabilities
├── Automatically manage signing: ☑️ (or manual with profiles)
├── Team: [Your Team]
├── Bundle Identifier: academy.qodex.app
└── Capabilities:
    ├── Push Notifications
    ├── In-App Purchase
    └── Sign In with Apple
```

### 3.3 Info.plist Updates

Add to `QodeX/Info.plist`:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>

<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads and analytics.</string>

<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## PHASE 4: BUILD CONFIGURATION (Day 2-3)

### 4.1 Create Archive

```bash
# Using Xcode
# 1. Select "Any iOS Device (arm64)" as target
# 2. Product → Archive
# 3. Wait for build to complete

# Using Fastlane
fastlane gym \
  --scheme "QodeX" \
  --export_method app-store \
  --output_directory "./build"
```

### 4.2 Validate Archive

1. Window → Organizer → Select your archive
2. Click "Validate App"
3. Choose "App Store Connect"
4. Review validation results
5. Fix any errors

### 4.3 Upload to App Store Connect

**Option A: Xcode (Easiest)**
1. Organizer → Select archive
2. Click "Distribute App"
3. Select "App Store Connect"
4. Select "Upload"
5. Follow prompts

**Option B: Fastlane (Automated)**
```bash
fastlane deliver \
  --ipa "build/QodeX.ipa" \
  --skip_screenshots \
  --skip_metadata
```

**Option C: Transporter App**
1. Download Transporter from Mac App Store
2. Drag .ipa file to Transporter
3. Click "Deliver"

---

## PHASE 5: APP STORE CONNECT (Day 3-4)

### 5.1 App Information

```
App Store → QodeX → App Information
├── Name: QodeX Inner Circle
├── Subtitle: Decode Your Life Path
├── Category: Lifestyle (Primary), Education (Secondary)
└── Content Rights: ☑️ No third-party content
```

### 5.2 Pricing and Availability

```
Pricing and Availability
├── Price: Free (with In-App Purchases)
├── Availability: All countries
└── Pre-orders: No
```

### 5.3 In-App Purchases (Critical)

Create 6 subscriptions:

| Reference Name | Product ID | Type | Price |
|----------------|-----------|------|-------|
| Seeker Monthly | com.qodex.seeker.monthly | Auto-Renewable | $19.99 |
| Seeker Annual | com.qodex.seeker.annual | Auto-Renewable | $179.99 |
| Initiate Monthly | com.qodex.initiate.monthly | Auto-Renewable | $49.99 |
| Initiate Annual | com.qodex.initiate.annual | Auto-Renewable | $449.99 |
| Master Monthly | com.qodex.master.monthly | Auto-Renewable | $199.99 |
| Master Annual | com.qodex.master.annual | Auto-Renewable | $1799.99 |

**For each subscription:**
1. Reference Name: [As above]
2. Product ID: [As above]
3. Subscription Group: Create "QodeX Membership"
4. Subscription Duration: [Monthly/Annual]
5. Review Screenshot: Upload paywall screenshot
6. Description: "Full access to QodeX Inner Circle"

### 5.4 App Privacy

```
App Privacy → Get Started
├── Data Collection: ☑️ Yes
├── Data Types:
│   ├── Contact Info (Email, Name)
│   ├── User Content (Journal entries)
│   ├── Identifiers (User ID)
│   └── Usage Data (Analytics)
├── Data Usage:
│   ├── App Functionality
│   ├── Analytics
│   └── Product Personalization
└── Data Linked to User: ☑️ Yes
```

---

## PHASE 6: ASSETS (Day 4)

### 6.1 App Icon

Create icons for all sizes:
```
AppIcon.appiconset/
├── 20x20@2x (iPad Notification)
├── 20x20@3x (iPhone Notification)
├── 29x29@2x (iPad Settings)
├── 29x29@3x (iPhone Settings)
├── 40x40@2x (iPad Spotlight)
├── 40x40@3x (iPhone Spotlight)
├── 60x60@2x (iPhone App)
├── 60x60@3x (iPhone App)
├── 76x76@2x (iPad App)
├── 83.5x83.5@2x (iPad Pro)
└── 1024x1024 (App Store)
```

**Design Guidelines:**
- 1024x1024 master icon
- No transparency
- No rounded corners (iOS adds them)
- Simple, recognizable design

### 6.2 Screenshots (Required)

**Required Sizes:**
- iPhone 6.7" (1290x2796) - iPhone 15 Pro Max
- iPhone 6.5" (1284x2778) - iPhone 14 Plus
- iPhone 5.5" (1242x2208) - iPhone 8 Plus

**Screenshot Content (5 per device):**
1. **Daily Qode** - Show today's number
2. **Calculator** - Full chart results
3. **Community** - Discussion feed
4. **Teachings** - Video library
5. **Profile** - Membership status

**Tips:**
- Remove status bar (Simulator → Device → Bezels → Hidden)
- Use clean, real data
- Add text overlays if needed
- Maintain consistent style

### 6.3 App Preview Video (Optional)

- 15-30 seconds
- Show core features
- No audio required
- 886x1920 (iPhone)

---

## PHASE 7: SUBMISSION (Day 5)

### 7.1 Prepare for Review

**App Review Information:**
```
Sign-in Information:
├── User: demo@qodex.academy
└── Password: Demo123!

Contact Information:
├── First Name: Shani
├── Last Name: [Your Last Name]
├── Email: shani@qodex.academy
└── Phone: [Your Phone]

Notes:
"QodeX is a numerology app with subscription tiers.
Test account provided for review.
All content is original or properly licensed."
```

### 7.2 App Review Details

```
What's New in This Version:
"Initial release of QodeX Inner Circle.
Features:
- Life Path calculator
- Daily Qode insights
- Community discussions
- Live sessions with Shani
- Subscription tiers"

Keywords:
numerology, astrology, life path, spiritual, wellness, meditation, community

Support URL: https://qodex.academy/support
Marketing URL: https://qodex.academy
```

### 7.3 Submit for Review

1. App Store Connect → QodeX → App Store
2. Select build from "Build" dropdown
3. Click "Add for Review"
4. Review all information
5. Click "Submit for Review"

---

## PHASE 8: POST-SUBMISSION

### 8.1 Typical Timeline

| Stage | Duration |
|-------|----------|
| Waiting for Review | 1-7 days |
| In Review | 1-2 days |
| Ready for Sale | Immediate |

### 8.2 Common Rejection Reasons & Fixes

| Reason | Fix |
|--------|-----|
| Missing privacy policy | Add to website and App Store |
| Sign in with Apple required | Implement if using other social logins |
| In-app purchase not working | Test with sandbox account |
| Crashes on launch | Test on physical device |
| Metadata rejected | Update screenshots/description |

### 8.3 After Approval

1. **Release Options:**
   - Manual: You control release timing
   - Automatic: Releases immediately after approval

2. **Promote Your App:**
   - Social media announcement
   - Email existing users
   - Product Hunt launch
   - Press outreach

---

## FASTLANE AUTOMATION (Recommended)

### Setup Fastfile

```ruby
# fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    increment_build_number
    build_app(scheme: "QodeX")
    upload_to_testflight
  end

  desc "Build and upload to App Store"
  lane :release do
    increment_version_number
    increment_build_number
    build_app(scheme: "QodeX")
    upload_to_app_store(
      force: true,
      skip_metadata: false,
      skip_screenshots: false,
      submit_for_review: true,
      automatic_release: false
    )
  end

  desc "Generate screenshots"
  lane :screenshots do
    capture_screenshots
    frame_screenshots(white: true)
  end
end
```

### Run Deployment

```bash
# TestFlight (Beta)
fastlane beta

# App Store (Production)
fastlane release
```

---

## CHECKLIST

### Before Submission:
- [ ] Apple Developer Account active
- [ ] App Store Connect app created
- [ ] Certificates and profiles installed
- [ ] Bundle ID matches (academy.qodex.app)
- [ ] Version and build numbers set
- [ ] App icon all sizes
- [ ] Screenshots for all devices
- [ ] Privacy policy URL live
- [ ] Support URL live
- [ ] In-app purchases configured
- [ ] Tested on physical device
- [ ] No crashes or bugs
- [ ] App runs on iOS 17+

### At Submission:
- [ ] Archive created successfully
- [ ] Validation passed
- [ ] Build uploaded to App Store Connect
- [ ] Build selected in App Store tab
- [ ] All metadata complete
- [ ] Demo account provided
- [ ] Review notes added
- [ ] Submit for Review clicked

---

## TIMELINE SUMMARY

| Day | Task | Duration |
|-----|------|----------|
| 1 | Developer account, App Store Connect setup | 2-4 hours |
| 2 | Certificates, Xcode configuration | 3-4 hours |
| 3 | Build, test, upload | 2-3 hours |
| 4 | Assets, screenshots, metadata | 4-6 hours |
| 5 | Final review, submission | 1-2 hours |
| 6-12 | Wait for review | 1-7 days |
| 13 | Release! | Immediate |

**Total Active Time: ~15-20 hours**
**Total Calendar Time: 1-2 weeks**

---

## EMERGENCY CONTACTS

- Apple Developer Support: https://developer.apple.com/contact/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Fastlane Issues: https://github.com/fastlane/fastlane/issues

---

Good luck with your launch! 🚀
