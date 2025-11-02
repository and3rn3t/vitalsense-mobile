#!/bin/sh

# Pre-build script for Xcode Cloud
# This script runs before the build starts

set -e

echo "🚀 Starting VitalSense pre-build setup..."

# Install dependencies if needed
if [ -f "Package.swift" ]; then
    echo "📦 Resolving Swift Package Manager dependencies..."
    # SPM dependencies are automatically resolved by Xcode Cloud
fi

# Install Ruby gems for Fastlane if Gemfile exists
if [ -f "Gemfile" ]; then
    echo "💎 Installing Ruby gems..."
    bundle install --path vendor/bundle
fi

# Set up environment variables
echo "🔧 Setting up environment..."
export CI=true
export XCODE_CLOUD=true

# Verify Xcode version
echo "📱 Xcode version:"
xcodebuild -version

# Check available simulators
echo "📲 Available simulators:"
xcrun simctl list devices available

# Verify project structure
echo "🏗️ Project structure verification:"
if [ -f "VitalSense.xcodeproj/project.pbxproj" ]; then
    echo "✅ Xcode project found"
else
    echo "❌ Xcode project not found"
    exit 1
fi

if [ -f "VitalSense.xcworkspace/contents.xcworkspacedata" ]; then
    echo "✅ Xcode workspace found"
else
    echo "❌ Xcode workspace not found"
    exit 1
fi

# Create build directories
mkdir -p build
mkdir -p fastlane/build_logs
mkdir -p fastlane/test_output

echo "✅ Pre-build setup completed successfully!"
