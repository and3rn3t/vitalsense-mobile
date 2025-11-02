# VitalSense - Health Monitoring iOS App

A comprehensive health monitoring app for iOS and Apple Watch that provides real-time gait analysis, fall risk assessment, and HealthKit integration.

## 🚀 Quick Start

1. **Run the setup script:**
   ```bash
   ./setup-project.sh
   ```

2. **Create Xcode project:**
   - Open Xcode → Create new iOS App
   - Project Name: `VitalSense`
   - Bundle ID: `dev.andernet.VitalSense`
   - Language: Swift, Interface: SwiftUI

3. **Add the generated files to your project:**
   - `VitalSenseApp.swift` (replace ContentView.swift)
   - `HealthKitManager.swift`
   - `GaitAnalyzer.swift`
   - `Info.plist`
   - `VitalSense.entitlements`

4. **Add Apple Watch target:**
   - File → New → Target → watchOS → Watch App
   - Add `VitalSenseWatchApp.swift` to watch target

5. **Configure permissions:**
   - Add HealthKit capability in Signing & Capabilities
   - Add Core Motion framework

6. **Test on device:**
   - Build and run on iPhone/Apple Watch (HealthKit requires physical devices)

## 📱 Features

- **Real-time Gait Analysis** - Advanced walking pattern analysis using Core Motion
- **Fall Risk Assessment** - AI-powered fall risk scoring based on gait stability  
- **HealthKit Integration** - Seamless health data reading and writing
- **Apple Watch Companion** - Independent watch app with workout sessions
- **Privacy-First Design** - All data processing happens on-device

## 🏗️ Architecture

- **iOS App**: SwiftUI-based main application
- **Watch App**: Independent watchOS companion app
- **HealthKitManager**: Centralized health data management
- **GaitAnalyzer**: Core Motion-based gait analysis engine

## 🧪 Testing

1. Run on physical iPhone and Apple Watch (HealthKit requires real hardware)
2. Grant health permissions when prompted
3. Start gait analysis and walk around
4. Verify health data synchronization between devices

## 🚀 Deployment

1. Archive for release: `Product → Archive`
2. Upload to App Store Connect
3. Submit for review

## 📄 Requirements

- iOS 17.0+
- watchOS 10.0+
- Xcode 15.0+
- Physical iPhone and Apple Watch for testing

---

*Built with Swift, SwiftUI, HealthKit, and Core Motion*