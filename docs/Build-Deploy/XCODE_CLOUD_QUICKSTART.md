# Xcode Cloud Quick Setup Guide

## 🚀 Getting Started

This guide will help you set up Xcode Cloud for the VitalSense mobile application.

## Prerequisites

- [ ] Apple Developer Program membership
- [ ] Admin access to App Store Connect
- [ ] Xcode 14.0+ installed
- [ ] Repository hosted on GitHub, GitLab, or Bitbucket

## Step-by-Step Setup

### 1. Repository Configuration

The repository already includes:

- ✅ `.xcode-cloud/` directory with workflow definitions
- ✅ `ci_scripts/` directory with build scripts
- ✅ Xcode project and workspace files

### 2. Apple Developer Console Setup

1. **Sign in to App Store Connect**
   - Navigate to [App Store Connect](https://appstoreconnect.apple.com)
   - Go to "Xcode Cloud" section

2. **Connect Repository**
   - Click "Get Started" in Xcode Cloud
   - Choose your Git provider (GitHub recommended)
   - Authorize access to the `vitalsense-mobile` repository

3. **Configure Team Settings**
   - Verify your Apple Developer Team ID
   - Ensure you have the required roles:
     - App Manager or Admin role
     - Access to certificates and provisioning profiles

### 3. Xcode Project Configuration

1. **Open Project**

   ```bash
   open VitalSense.xcworkspace
   ```

2. **Navigate to Xcode Cloud Settings**
   - Product → Xcode Cloud → Manage Workflows
   - Or use the Report Navigator → Cloud tab

3. **Import Workflows**
   - Xcode should automatically detect the `.xcode-cloud` configurations
   - Review and approve the workflow settings:
     - Build and Test (main workflow)
     - Release Build (for App Store)
     - Watch App Build (watchOS testing)

### 4. Code Signing Setup

1. **Automatic Signing (Recommended)**
   - Select project → VitalSense target
   - Enable "Automatically manage signing"
   - Select your development team

2. **Manual Signing (Advanced)**
   - Create App ID with HealthKit capability
   - Generate development/distribution certificates
   - Create provisioning profiles for:
     - iOS app
     - Watch app
     - App extensions (widgets)

### 5. Environment Configuration

Required environment variables (auto-configured):

- `CI=true`
- `XCODE_CLOUD=true`
- `CONFIGURATION` (Debug/Release)

Optional variables you may want to add:

- `APP_IDENTIFIER` - Your bundle identifier
- `TEAM_ID` - Apple Developer Team ID

### 6. Test Your Setup

1. **Trigger a Build**
   - Push a commit to the `main` branch
   - Or create a pull request
   - Monitor the build in Xcode Cloud console

2. **Check Build Status**
   - View progress in Xcode → Report Navigator → Cloud
   - Or visit App Store Connect → Xcode Cloud

## 🔍 Verification Checklist

- [ ] Repository connected to Xcode Cloud
- [ ] Workflows imported and active
- [ ] Code signing configured correctly
- [ ] HealthKit entitlements enabled
- [ ] Test build completes successfully
- [ ] CI scripts execute without errors

## 📊 Monitoring Your Builds

### Build Triggers

- **Automatic**: Pushes to `main`, `develop`, and pull requests
- **Release**: Tags matching `v*.*.*` pattern
- **Manual**: Via Xcode Cloud console

### Build Artifacts

- Test results and coverage reports
- Archive files for distribution
- Build logs and diagnostics

## 🚨 Common Issues & Solutions

### HealthKit Entitlement Errors

```
Error: HealthKit entitlement not found
```

**Solution**: Enable HealthKit capability in App ID and regenerate provisioning profiles

### Watch App Build Failures

```
Error: watchOS deployment target not supported
```

**Solution**: Update Watch app deployment target to watchOS 10.0+

### Code Signing Issues

```
Error: No matching provisioning profiles found
```

**Solution**: Use automatic signing or create manual profiles with correct bundle IDs

## 📞 Getting Help

1. **Apple Documentation**: [Xcode Cloud User Guide](https://developer.apple.com/documentation/xcode/xcode-cloud)
2. **Build Logs**: Check detailed logs in App Store Connect
3. **Developer Forums**: [Apple Developer Forums](https://developer.apple.com/forums/)
4. **Support**: Contact Apple Developer Support

## 🎯 Next Steps

Once Xcode Cloud is working:

1. Set up TestFlight integration
2. Configure App Store Connect API keys
3. Enable notifications for build status
4. Add additional team members with appropriate roles

---

✅ **Setup Complete!** Your VitalSense app is now configured for continuous integration with Xcode Cloud.
