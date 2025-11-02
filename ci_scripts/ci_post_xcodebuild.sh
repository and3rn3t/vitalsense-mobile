#!/bin/sh

# Post-build script for Xcode Cloud
# This script runs after the build completes

set -e

echo "🎉 Starting VitalSense post-build actions..."

# Check if build was successful
if [ "$CI_XCODEBUILD_EXIT_CODE" = "0" ]; then
    echo "✅ Build completed successfully!"
else
    echo "❌ Build failed with exit code: $CI_XCODEBUILD_EXIT_CODE"
    exit $CI_XCODEBUILD_EXIT_CODE
fi

# Archive test results if available
if [ -d "$CI_DERIVED_DATA_PATH" ]; then
    echo "📊 Archiving test results..."

    # Find test result bundles
    find "$CI_DERIVED_DATA_PATH" -name "*.xcresult" -type d | while read result_bundle; do
        echo "📋 Found test results: $(basename "$result_bundle")"

        # Generate readable test summary
        if command -v xcrun >/dev/null 2>&1; then
            xcrun xcresulttool get --format json --path "$result_bundle" > "test_results_$(date +%Y%m%d_%H%M%S).json" || true
        fi
    done
fi

# Generate build artifacts summary
echo "📦 Build artifacts summary:"
if [ -d "$CI_ARCHIVE_PATH" ]; then
    echo "📱 Archive: $CI_ARCHIVE_PATH"
    ls -la "$CI_ARCHIVE_PATH" || true
fi

if [ -d "$CI_AD_HOC_CODE_SIGNING_EXPORT_PATH" ]; then
    echo "📲 Ad Hoc Export: $CI_AD_HOC_CODE_SIGNING_EXPORT_PATH"
    ls -la "$CI_AD_HOC_CODE_SIGNING_EXPORT_PATH" || true
fi

if [ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]; then
    echo "🏪 App Store Export: $CI_APP_STORE_SIGNED_APP_PATH"
    ls -la "$CI_APP_STORE_SIGNED_APP_PATH" || true
fi

# Run additional checks if this is a release build
if [ "$CONFIGURATION" = "Release" ]; then
    echo "🔍 Running release build validations..."

    # Validate app icon and metadata
    if [ -f "VitalSense/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json" ]; then
        echo "✅ App icon assets found"
    else
        echo "⚠️ App icon assets not found"
    fi

    # Check for required Info.plist entries
    if [ -f "VitalSense/Support/Info.plist" ]; then
        echo "✅ Info.plist found"
    else
        echo "⚠️ Info.plist not found"
    fi
fi

# Clean up temporary files
echo "🧹 Cleaning up temporary files..."
rm -rf build/temp || true

echo "✅ Post-build actions completed successfully!"
