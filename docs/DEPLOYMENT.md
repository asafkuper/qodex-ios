# App Store Deployment Guide

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Enroll at: https://developer.apple.com/programs/
   - Complete identity verification

2. **App Store Connect**
   - Access: https://appstoreconnect.apple.com
   - Create new app record

3. **Certificates & Provisioning**
   - Development certificate
   - Distribution certificate
   - App Store provisioning profile

## Fastlane Setup

```bash
# Install Fastlane
brew install fastlane

# Initialize in project
cd QodeX
fastlane init

# Create Appfile
cat > fastlane/Appfile << EOF
app_identifier("academy.qodex.app")
apple_id("your-apple-id@email.com")
itc_team_id("YOUR_TEAM_ID")
team_id("YOUR_TEAM_ID")
EOF

# Create Fastfile
cat > fastlane/Fastfile << EOF
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    scan
  end

  desc "Build beta for TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "QodeX.xcodeproj")
    build_app(scheme: "QodeX")
    upload_to_testflight
  end

  desc "Deploy to App Store"
  lane :release do
    increment_build_number(xcodeproj: "QodeX.xcodeproj")
    build_app(scheme: "QodeX")
    upload_to_app_store(
      force: true,
      skip_metadata: false,
      skip_screenshots: false,
      submit_for_review: true
    )
  end
end
EOF
```

## Manual Deployment Steps

### 1. Archive Build
```bash
xcodebuild -project QodeX.xcodeproj -scheme QodeX -configuration Release archive -archivePath QodeX.xcarchive
```

### 2. Export IPA
```bash
xcodebuild -exportArchive -archivePath QodeX.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
```

### 3. Upload to App Store Connect
```bash
xcrun altool --upload-app --type ios --file "build/QodeX.ipa" --apiKey "YOUR_API_KEY" --apiIssuer "YOUR_ISSUER_ID"
```

## App Store Information

### App Details
- **Name:** QodeX Inner Circle
- **Subtitle:** Numerology & Energy Decoding
- **Category:** Lifestyle / Education
- **Price:** Free with In-App Purchases

### Screenshots Required
- iPhone 6.7" (1290 x 2796)
- iPhone 6.5" (1284 x 2778)
- iPhone 5.5" (1242 x 2208)
- iPad Pro 12.9" (2048 x 2732)

### App Review Information
- **Demo Account:** Required (provide test Inner Circle credentials)
- **Notes:** Explain the numerology calculator functionality

## In-App Purchases Setup

1. Go to App Store Connect → Your App → Features → In-App Purchases
2. Create subscriptions:
   - Inner Circle Monthly: $19.99/month
   - Inner Circle Annual: $199.99/year (2 months free)
   - Master Tier: $499/year

3. Configure RevenueCat:
   - Sign up: https://www.revenuecat.com
   - Add API key to `Config.xcconfig`
   - Set up entitlements for each tier

## Checklist Before Submission

- [ ] App icon (1024x1024)
- [ ] Launch screen
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] Marketing URL (optional)
- [ ] App Preview video (optional)
- [ ] 3-5 screenshots per device
- [ ] Keywords optimized
- [ ] Description written
- [ ] What's New text (for updates)

## Post-Launch

### Analytics Setup
- Firebase Analytics
- Mixpanel or Amplitude
- RevenueCat metrics

### Crash Reporting
- Firebase Crashlytics
- Sentry (optional)

### Push Notifications
- OneSignal or Firebase Cloud Messaging

## Marketing Assets

### App Icon
- Simple, recognizable
- Works at small sizes
- No transparency

### Screenshots
- Show real app content
- Add text overlays explaining features
- Use device frames

### App Preview
- 15-30 seconds
- Show core functionality
- No hands in frame (optional)

---

Need help? Contact: support@qodex.academy
