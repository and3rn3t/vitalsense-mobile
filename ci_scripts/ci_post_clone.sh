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
