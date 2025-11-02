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
