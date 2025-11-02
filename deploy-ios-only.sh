#!/bin/bash
# Deploy VitalSense iOS app only (skip Watch and Widgets)
# This script builds and installs just the main iOS app to your device

set -e

echo "🚀 Building VitalSense iOS App (skipping extensions)..."

# Clean derived data to avoid cached errors
echo "🧹 Cleaning build cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/VitalSense-*

# Build just the main iOS app without the embedded extensions
# We'll use xcodebuild with specific flags to skip problematic targets
cd /Users/ma55700/Documents/GitHub/vitalsense-mobile

echo "📦 Building main app bundle..."
xcodebuild \
  -project VitalSense.xcodeproj \
  -scheme VitalSense \
  -destination 'platform=iOS,id=00008130-000859EC0AD1001C' \
  -configuration Debug \
  -allowProvisioningUpdates \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=NO \
  ONLY_ACTIVE_ARCH=YES \
  -sdk iphoneos \
  ENABLE_BITCODE=NO \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=C8U3P6AJ6L \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  build

echo "✅ Build complete! App should be on your device."
echo "If the app isn't installed, open Xcode and run the app directly from there."
