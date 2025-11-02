<<<<<<< HEAD
#!/bin/sh

# Post-clone script for Xcode Cloud
# This script runs after the repository is cloned but before build starts

set -e

echo "📥 Starting VitalSense post-clone setup..."

# Set executable permissions for scripts
chmod +x ci_scripts/*.sh
chmod +x scripts/*.sh

# Install system dependencies if needed
echo "🔧 Setting up system dependencies..."

# Ruby setup for Fastlane
if [ -f "Gemfile" ]; then
    echo "💎 Setting up Ruby environment..."

    # Install bundler if not present
    if ! command -v bundle >/dev/null 2>&1; then
        gem install bundler
    fi

    # Install gems
    bundle install --path vendor/bundle
fi

# Swift Package Manager setup
if [ -f "Package.swift" ]; then
    echo "📦 Swift Package Manager detected"
    # Dependencies will be resolved automatically by Xcode Cloud
fi

# Set up environment for HealthKit development
echo "🏥 Setting up HealthKit development environment..."

# Verify required capabilities
if grep -q "com.apple.developer.healthkit" VitalSense/VitalSense.entitlements 2>/dev/null; then
    echo "✅ HealthKit entitlements found"
else
    echo "⚠️ HealthKit entitlements not found - may need manual configuration"
fi

# Verify Watch connectivity entitlements
if grep -q "com.apple.developer.watchkit" VitalSense/VitalSense.entitlements 2>/dev/null; then
    echo "✅ WatchKit entitlements found"
else
    echo "⚠️ WatchKit entitlements not found - may need manual configuration"
fi

# Create necessary directories
mkdir -p build/
mkdir -p fastlane/build_logs/
mkdir -p fastlane/test_output/

# Set up git configuration for any git operations
git config --global user.name "Xcode Cloud"
git config --global user.email "xcode-cloud@vitalsense.app"

echo "✅ Post-clone setup completed successfully!"
=======
#!/bin/bash

# ci_post_clone.sh - VitalSense Xcode Cloud Post-Clone Script
# Runs after the repository is cloned but before the build starts

set -euo pipefail

echo "🔧 VitalSense Post-Clone Setup"
echo "=============================="

# Set up environment variables
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

# Log environment info
echo "📱 Xcode version: $(xcodebuild -version)"
echo "🍎 macOS version: $(sw_vers -productVersion)"
echo "📦 Available simulators:"
xcrun simctl list devices available

# Install any required tools or dependencies
echo "📦 Installing dependencies..."

# For VitalSense health app, we might need specific simulator configurations
echo "🏥 Setting up HealthKit testing environment..."

# Create HealthKit test data directory if needed
mkdir -p TestData
echo "✅ HealthKit test environment ready"

# Validate that required frameworks are available
echo "🔍 Validating frameworks..."
if xcodebuild -showsdks | grep -q "iphoneos"; then
    echo "✅ iOS SDK available"
else
    echo "❌ iOS SDK not found"
    exit 1
fi

if xcodebuild -showsdks | grep -q "watchos"; then
    echo "✅ watchOS SDK available"
else
    echo "⚠️  watchOS SDK not found - Watch app builds may fail"
fi

echo "✅ Post-clone setup complete"
>>>>>>> 1333e3b58e4bbff2154060f9dba49b07c9dcb40e
