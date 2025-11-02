# Xcode Cloud Setup - Step by Step Guide

## 🚨 **Important**: Setup Process Order

**You must set up Xcode Cloud through Xcode first, NOT App Store Connect directly.**

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Apple Developer Program membership** (paid account required)
- [ ] **Admin or App Manager role** in your Apple Developer team
- [ ] **Xcode 14.0+** installed on macOS
- [ ] **Repository hosted** on GitHub, GitLab, or Bitbucket
- [ ] **Valid Apple ID** signed into Xcode

## Step 1: Create App Record in App Store Connect

**⚠️ Do this BEFORE setting up Xcode Cloud**

1. **Sign in to App Store Connect**
   - Go to [https://appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Sign in with your Apple ID

2. **Create New App**
   - Click "My Apps" → "+" button → "New App"
   - Fill in the details:
     - **Platform**: iOS
     - **Name**: "VitalSense" (or your preferred name)
     - **Primary Language**: English (U.S.)
     - **Bundle ID**: Select `dev.andernet.VitalSense` from dropdown
     - **SKU**: Something unique like "vitalsense-ios-2025"

3. **Enable HealthKit**
   - Go to App Information → App Store Connect
   - Under "App Information" → "Category"
   - Select **"Health & Fitness"** as Primary Category
   - Under "App Review Information" add HealthKit usage description

## Step 2: Configure Bundle ID & Capabilities

1. **Go to Apple Developer Portal**
   - Visit [https://developer.apple.com/account](https://developer.apple.com/account)
   - Navigate to "Certificates, Identifiers & Profiles"

2. **Configure App ID**
   - Click "Identifiers" → Find `dev.andernet.VitalSense`
   - If it doesn't exist, create it:
     - Click "+" → "App IDs" → "App"
     - Description: "VitalSense Health Monitor"
     - Bundle ID: `dev.andernet.VitalSense`

3. **Enable Required Capabilities**
   - Check these capabilities:
     - ✅ **HealthKit**
     - ✅ **App Groups** (for Watch connectivity)
     - ✅ **Background Modes** (for health monitoring)
     - ✅ **Push Notifications** (optional, for reminders)

4. **Save and Continue**

## Step 3: Set Up Xcode Cloud from Xcode

**⚠️ This is the correct way to initialize Xcode Cloud**

### 3a. Open Your Project

```bash
# Navigate to your project
cd C:\git\vitalsense-mobile

# Open the workspace (important!)
open VitalSense.xcworkspace
```

### 3b. Configure Xcode Cloud in Xcode

1. **In Xcode Menu**:
   - Go to **Product** → **Xcode Cloud** → **Create Workflow**
   - OR use the **Report Navigator** → **Cloud** tab → **Create Workflow**

2. **Repository Connection**:
   - Xcode will prompt to connect your Git repository
   - Choose your Git provider (GitHub, GitLab, etc.)
   - **Authorize Xcode** to access your repository
   - Select the `vitalsense-mobile` repository

3. **Initial Workflow Setup**:
   - Xcode will detect your existing `.xcode-cloud` configuration
   - It should find the workflows we created:
     - `ci_build_and_test.xcodebuild`
     - `ci_release.xcodebuild`
     - `ci_watch_build.xcodebuild`

### 3c. Verify Project Settings

1. **Select VitalSense target**
2. **Signing & Capabilities tab**:
   - Enable **"Automatically manage signing"**
   - Select your **Team** (Apple Developer account)
   - Verify **Bundle Identifier**: `dev.andernet.VitalSense`
   - Confirm **HealthKit** capability is present

3. **Repeat for Watch target**:
   - Select **VitalSenseWatch Watch App** target
   - Enable automatic signing
   - Verify bundle ID: `dev.andernet.VitalSense.watchkitapp`

## Step 4: Verify Xcode Cloud Setup

### 4a. Check Xcode Cloud Console

1. **In Xcode**:
   - Go to **Report Navigator** (📊 icon)
   - Click **Cloud** tab
   - You should see your workflows listed

2. **Test Connection**:
   - Click **"Start Build"** on one of your workflows
   - OR push a commit to trigger automatic builds

### 4b. Monitor First Build

- Watch the build progress in Xcode
- Check for any code signing or capability errors
- Review build logs for issues

## Step 5: Now Check App Store Connect

**Only AFTER completing Steps 1-4**, you'll find Xcode Cloud in App Store Connect:

1. **Go to App Store Connect**
2. **Navigate to**: My Apps → VitalSense → Xcode Cloud
3. **You should now see**:
   - Connected repository
   - Active workflows
   - Build history
   - Settings and configuration options

## 🚨 Troubleshooting Common Issues

### "Can't find Xcode Cloud in App Store Connect"

- **Cause**: Repository not connected through Xcode yet
- **Solution**: Complete Steps 2-3 first

### "No matching bundle identifier"

- **Cause**: App ID not created in Developer Portal
- **Solution**: Create App ID with exact bundle identifier `dev.andernet.VitalSense`

### "HealthKit capability missing"

- **Cause**: Capability not enabled in App ID
- **Solution**: Enable HealthKit in Apple Developer Portal → Identifiers

### "Code signing errors in build"

- **Cause**: Automatic signing not configured
- **Solution**: Enable automatic signing and select correct team

## 📋 Verification Checklist

Before first build:

- [ ] App record created in App Store Connect  
- [ ] Bundle ID `dev.andernet.VitalSense` exists with HealthKit enabled
- [ ] Repository connected through Xcode (not App Store Connect)
- [ ] Automatic signing enabled with correct team
- [ ] Workflows visible in Xcode → Report Navigator → Cloud
- [ ] Test build initiated successfully

## 🎯 Success Indicators

You'll know it's working when:

- ✅ Workflows appear in Xcode Cloud tab
- ✅ Builds can be triggered from Xcode
- ✅ App Store Connect shows Xcode Cloud section
- ✅ Build logs appear in both Xcode and App Store Connect

---

**Key Point**: Always start from Xcode, not App Store Connect! The repository connection must be established through Xcode first.
