#!/bin/bash

# VitalSense Permission Setup Script
# Sets correct permissions for all scripts

echo "🔧 VitalSense Permission Setup"
echo "=============================="

# Find all .sh files and make them executable
echo "📋 Setting up script permissions..."

SCRIPT_COUNT=0

# List of all shell scripts in the project
SCRIPTS=(
    "launch-vitalsense.sh"
    "setup-project.sh"
    "setup-xcode-cloud.sh"
    "validate-xcode-cloud.sh"
    "cleanup-project.sh"
    "validate-app-store.sh"
    "setup-xcode-project.sh"
    "preflight-xcode-finalization.sh"
)

# Also check for ci_scripts
CI_SCRIPTS=(
    "ci_scripts/ci_post_clone.sh"
    "ci_scripts/ci_pre_xcodebuild.sh"
    "ci_scripts/ci_post_xcodebuild.sh"
)

echo "🔨 Making shell scripts executable..."

# Set permissions for main scripts
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        echo "✅ $script - executable"
        ((SCRIPT_COUNT++))
    else
        echo "⚠️  $script - not found (will be created when needed)"
    fi
done

# Set permissions for ci_scripts if they exist
for script in "${CI_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        echo "✅ $script - executable"
        ((SCRIPT_COUNT++))
    else
        echo "⚠️  $script - not found (run setup-xcode-cloud.sh to create)"
    fi
done

# Make this setup script executable too
chmod +x "setup-permissions.sh"
echo "✅ setup-permissions.sh - executable"
((SCRIPT_COUNT++))

echo ""
echo "🎉 Permission setup complete!"
echo "📊 Total scripts configured: $SCRIPT_COUNT"
echo ""

echo "🚀 Ready to run VitalSense scripts:"
echo "================================="
echo "• ./launch-vitalsense.sh         - Main launch script"
echo "• ./setup-project.sh             - Generate core files"
echo "• ./setup-xcode-cloud.sh         - Configure CI/CD"
echo "• ./validate-xcode-cloud.sh      - Validate cloud setup"
echo "• ./cleanup-project.sh           - Remove duplicates"
echo ""

# Test that the main launch script can run
if [ -x "launch-vitalsense.sh" ]; then
    echo "✅ Launch script is ready to run: ./launch-vitalsense.sh"
else
    echo "❌ Launch script permission issue - trying to fix..."
    chmod +x "launch-vitalsense.sh"
    if [ -x "launch-vitalsense.sh" ]; then
        echo "✅ Fixed: launch-vitalsense.sh is now executable"
    else
        echo "❌ Could not fix launch script permissions"
        echo "   Try running: chmod +x launch-vitalsense.sh"
    fi
fi

echo ""
echo "🔧 To run any script, use: ./script-name.sh"
echo "   Example: ./launch-vitalsense.sh"
echo ""
echo "✨ All VitalSense scripts are now ready to run!"