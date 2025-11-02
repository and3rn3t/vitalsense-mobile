# Xcode Cloud Configuration for VitalSense

## Overview

This document provides comprehensive information about the Xcode Cloud configuration for the VitalSense mobile application project.

## 🏗️ Workflow Configuration

### Build and Test Workflow (`ci_build_and_test.xcodebuild`)

- **Triggers**: Pull requests and pushes to `main` and `develop` branches
- **Actions**: Build and test iOS app with iPhone 15 simulator
- **Platform**: iOS 17.0+
- **Configuration**: Debug

### Release Workflow (`ci_release.xcodebuild`)

- **Triggers**: Git tags matching `v*` pattern and pushes to `release/*` branches
- **Actions**: Archive and export IPA for App Store distribution
- **Configuration**: Release
- **Export Method**: App Store Connect

### Watch App Workflow (`ci_watch_build.xcodebuild`)

- **Triggers**: Pull requests and path-filtered pushes for Watch app changes
- **Actions**: Build and test watchOS companion app
- **Platform**: watchOS 10.0+ with Apple Watch Series 9 simulator
- **Path Filters**: Watch app, Core, and Sources directories

## 📋 CI Scripts

### `ci_post_clone.sh`

Runs after repository clone:

- Sets up Ruby/Fastlane environment
- Configures Swift Package Manager
- Verifies HealthKit and WatchKit entitlements
- Creates necessary build directories

### `ci_pre_xcodebuild.sh`

Runs before build starts:

- Installs dependencies (Ruby gems, SPM packages)
- Verifies Xcode and simulator availability
- Sets environment variables
- Creates build artifact directories

### `ci_post_xcodebuild.sh`

Runs after build completion:

- Archives test results and coverage data
- Generates build artifacts summary
- Performs release build validations
- Cleanup temporary files

## 🔧 Environment Variables

The following environment variables are automatically set:

- `CI=true` - Indicates CI environment
- `XCODE_CLOUD=true` - Specific to Xcode Cloud
- `CONFIGURATION` - Build configuration (Debug/Release)

## 📱 Platform Requirements

### iOS App

- **Minimum**: iOS 17.0
- **Target Device**: iPhone 15 (simulator)
- **Frameworks**: SwiftUI, HealthKit, Core Motion

### watchOS App

- **Minimum**: watchOS 10.0  
- **Target Device**: Apple Watch Series 9 (simulator)
- **Frameworks**: WatchKit, HealthKit

## 🏥 HealthKit Integration

The VitalSense app requires specific HealthKit capabilities:

- **Entitlements**: `com.apple.developer.healthkit`
- **Privacy**: Health data access permissions
- **Compliance**: App Store health app guidelines

Required Info.plist entries:

```xml
<key>NSHealthShareUsageDescription</key>
<string>VitalSense reads your health data to provide personalized gait analysis and health insights.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>VitalSense writes workout and health data to your Health app for comprehensive tracking.</string>
```

## 🔐 Code Signing & Provisioning

### Development

- **Team ID**: Set via Apple Developer account
- **Bundle ID**: `com.vitalsense.mobile` (or configured identifier)
- **Capabilities**: HealthKit, App Groups, Background Processing

### Distribution

- **Method**: App Store Connect
- **Bitcode**: Disabled (as per iOS 14+ requirements)
- **Symbols**: Upload enabled for crash analytics

## 📊 Test Plans

### Unit Tests (`VitalSenseTests.xctestplan`)

- Core business logic testing
- HealthKit integration tests
- Data model validation
- Performance benchmarks

### UI Tests (`VitalSenseUITests`)

- End-to-end user workflows
- Accessibility validation
- Widget functionality
- Watch app connectivity

## 🚀 Deployment Strategy

### Automated Triggers

1. **Feature Development**: Push to `develop` → Build and test
2. **Pull Requests**: Any target branch → Full validation
3. **Release Preparation**: Push to `release/*` → Release build
4. **Production Release**: Tag with `v*` → App Store archive

### Manual Triggers

- Ad-hoc builds via Xcode Cloud console
- TestFlight distributions
- App Store submissions

## 📈 Monitoring & Analytics

### Build Analytics

- Build duration tracking
- Test success rates
- Archive size monitoring
- Deployment frequency metrics

### Quality Gates

- Unit test coverage minimum: 80%
- UI test pass rate: 100%
- Static analysis warnings: Zero tolerance
- Performance regression detection

## 🔍 Troubleshooting

### Common Issues

1. **HealthKit Entitlement Errors**
   - Verify App ID has HealthKit capability enabled
   - Check provisioning profile includes HealthKit
   - Ensure Info.plist has required usage descriptions

2. **Watch App Build Failures**
   - Confirm watchOS deployment target compatibility
   - Verify shared code compatibility with watchOS
   - Check Watch extension bundle identifier

3. **Code Signing Issues**
   - Validate Apple Developer account team membership
   - Ensure certificates are current and not expired
   - Check provisioning profile device registrations

### Debug Information

- Build logs available in Xcode Cloud console
- Test results exported as xcresult bundles
- Crash reports integrated with Xcode Organizer

## 📞 Support

For Xcode Cloud configuration issues:

1. Check Apple Developer documentation
2. Verify project settings in Xcode
3. Review build logs in App Store Connect
4. Contact Apple Developer Support if needed

---

*Last Updated: November 2, 2025*
*Version: 1.0.0*
