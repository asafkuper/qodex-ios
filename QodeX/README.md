# QodeX iOS App

## Build Instructions

### Requirements
- Xcode 15.0+
- iOS 17.0+ SDK
- macOS 14.0+

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/qodex-ios.git
cd qodex-ios
```

2. Open in Xcode:
```bash
open QodeX.xcodeproj
```

3. Configure signing:
   - Select QodeX target
   - Go to Signing & Capabilities
   - Set your Team
   - Update Bundle Identifier

4. Build and run:
   - Select target device/simulator
   - Press Cmd+R

### Project Structure
```
QodeX/
├── App/                    # App entry point
├── Core/                   # Networking, Auth, Persistence
├── Features/               # UI Screens
│   ├── Auth/
│   ├── Dashboard/
│   ├── Calculator/
│   ├── Library/
│   ├── Community/
│   └── Profile/
├── DesignSystem/           # UI Components, Colors, Typography
└── Resources/              # Assets, Localizations
```

### Dependencies
This project uses minimal external dependencies:
- SwiftUI (native)
- Combine (native)
- Foundation (native)

Future additions:
- Firebase (Auth, Firestore, Analytics)
- RevenueCat (In-App Purchases)

### Configuration

Create `Config.xcconfig`:
```
API_BASE_URL = https://api.qodex.academy
FIREBASE_API_KEY = your_key_here
REVENUECAT_API_KEY = your_key_here
```

### Testing
```bash
cmd+U in Xcode
# or
xcodebuild test -project QodeX.xcodeproj -scheme QodeX -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Deployment
See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## License
Proprietary - QodeX Academy
