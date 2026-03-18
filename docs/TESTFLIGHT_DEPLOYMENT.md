# QodeX iOS App — TestFlight Deployment Checklist

## 🎯 OBJECTIVE
Deploy QodeX to TestFlight for 100 beta users.

---

## ✅ PRE-DEPLOYMENT CHECKLIST

### 1. Code Verification
- [ ] Build succeeds in Xcode (Cmd+B)
- [ ] No compiler warnings
- [ ] All unit tests pass
- [ ] UI tests pass
- [ ] Memory leaks checked (Instruments)
- [ ] No hardcoded API keys in repo

### 2. Configuration
- [ ] Bundle ID: `academy.qodex.app`
- [ ] Version: `1.0.0 (1)`
- [ ] Build number incremented
- [ ] App Icon (all sizes)
- [ ] Launch screen
- [ ] Info.plist complete
- [ ] Privacy manifest (PrivacyInfo.xcprivacy)

### 3. App Store Connect Setup
- [ ] App record created
- [ ] TestFlight enabled
- [ ] Internal testers added (you + Shani)
- [ ] External testing group created
- [ ] Beta app description written
- [ ] Feedback email set
- [ ] App Store screenshot placeholders

### 4. Firebase Configuration
- [ ] Production Firebase project
- [ ] GoogleService-Info.plist added
- [ ] Analytics enabled
- [ ] Crashlytics enabled
- [ ] Push notifications configured
- [ ] Firestore rules set for production

### 5. RevenueCat Configuration
- [ ] Products created in App Store Connect
- [ ] Products synced to RevenueCat
- [ ] Offerings configured
- [ ] Test mode OFF for production

---

## 📱 BUILD PROCESS

### Step 1: Archive
```bash
# In Xcode
1. Select: Any iOS Device (arm64)
2. Product → Archive
3. Wait for build (5-10 minutes)
4. Organizer window opens automatically
```

### Step 2: Validate
```bash
# In Organizer
1. Click "Validate App"
2. Select destination: App Store Connect
3. Click "Validate"
4. Fix any errors
```

### Step 3: Upload
```bash
# In Organizer
1. Click "Distribute App"
2. Select: App Store Connect
3. Select: Upload
4. Click "Upload"
5. Wait (10-30 minutes)
```

---

## 🧪 TESTFLIGHT SETUP

### Internal Testing (You + Shani)
1. App Store Connect → My Apps → QodeX
2. TestFlight → Internal Testing
3. Add testers (Apple IDs)
4. Builds appear automatically

### External Testing (100 Beta Users)
1. TestFlight → External Testing
2. Create group: "Founding Members"
3. Add beta description:
```
QodeX Inner Circle — Beta Program

Decode your energetic matrix.

This beta includes:
• Full numerology chart
• Daily Qodes
• Community features
• Weekly live sessions with Shani

We'd love your feedback!

Requirements:
• iPhone running iOS 17+
• TestFlight app installed
```

4. Submit for beta review (1-24 hours)
5. Once approved: Add testers via email or public link

---

## 📧 BETA TESTER INVITATION

### Email Template
```
Subject: You're in! QodeX Beta Access 🎉

Hi [Name],

You're approved for the QodeX Inner Circle beta!

GET STARTED:

1. Install TestFlight (if not done)
   https://apps.apple.com/app/testflight/id899247664

2. Accept invitation
   https://testflight.apple.com/join/[CODE]

3. Download QodeX

4. Join our community
   Discord: [LINK]

FIRST LIVE SESSION:
Wednesday, March 19 at 8PM EST

Questions? Reply to this email.

Welcome aboard!
Shani
```

---

## 🔍 POST-DEPLOYMENT CHECKS

### Immediate (First Hour)
- [ ] App downloads successfully
- [ ] Launch screen displays
- [ ] Onboarding flow works
- [ ] Birth date input works
- [ ] Chart calculates
- [ ] No crashes on first use

### Day 1
- [ ] Push notifications received
- [ ] Daily Qode updates
- [ ] Subscription paywall works
- [ ] Community loads
- [ ] Analytics events firing

### Week 1
- [ ] 10+ active users
- [ ] Crash-free sessions > 99%
- [ ] Average rating collected
- [ ] Feedback received
- [ ] First bug reports

---

## 🐛 COMMON ISSUES

### Issue: Build fails with "Signing error"
**Fix**: 
- Xcode → Preferences → Accounts → Refresh
- Check provisioning profiles
- Ensure "Automatically manage signing" is checked

### Issue: "Invalid binary" on upload
**Fix**:
- Check GoogleService-Info.plist is included
- Verify bundle ID matches App Store Connect
- Check for missing icons

### Issue: TestFlight invitation not received
**Fix**:
- Check spam folder
- Verify email address
- Try public link instead

### Issue: App crashes on launch
**Fix**:
- Check Firebase configuration
- Verify API keys are valid
- Review Crashlytics logs

---

## 📊 SUCCESS METRICS

| Metric | Target | Check |
|--------|--------|-------|
| Build upload | Success | Day 1 |
| Beta approval | < 24 hours | Day 1-2 |
| First 10 downloads | 100% success | Day 2 |
| Active users (Day 7) | 50+ | Week 1 |
| Crash rate | < 1% | Week 1 |
| Feedback received | 20+ responses | Week 1 |

---

## 🚀 FASTLANE AUTOMATION (Optional)

### Setup
```bash
# Install Fastlane
sudo gem install fastlane -NV

# Initialize
cd QodeX
fastlane init
```

### Beta Deploy Script
```ruby
# fastlane/Fastfile
lane :beta do
  increment_build_number(xcodeproj: "QodeX.xcodeproj")
  build_app(scheme: "QodeX")
  upload_to_testflight(
    skip_waiting_for_build_processing: true,
    notify_external_testers: true
  )
end
```

### Usage
```bash
fastlane beta
```

---

## 📋 FINAL CHECKLIST

Before hitting "Upload":

- [ ] Code committed to git
- [ ] Version number updated
- [ ] CHANGELOG.md updated
- [ ] Release notes written
- [ ] Beta testers list ready
- [ ] Shani tested internal build
- [ ] Backup of current build
- [ ] Rollback plan ready

---

## 🎯 NEXT AFTER TESTFLIGHT

1. **Week 1**: Monitor crashes, collect feedback
2. **Week 2**: Iterate based on feedback
3. **Week 3**: Add features, fix bugs
4. **Week 4**: Prepare for App Store submission

---

*TestFlight Deployment Checklist v1.0*
