#!/bin/bash

# VitalSense Bootstrap Script
# This script can be run with 'bash bootstrap.sh' without needing execute permissions

echo "🚀 VitalSense Bootstrap - Fixing Permissions"
echo "============================================"

# Fix all script permissions
echo "🔧 Setting execute permissions on all scripts..."

# Make shell scripts executable
find . -name "*.sh" -exec chmod +x {} \; 2>/dev/null
chmod +x *.sh 2>/dev/null || true

# Handle ci_scripts directory if it exists
if [ -d "ci_scripts" ]; then
    chmod +x ci_scripts/*.sh 2>/dev/null || true
    echo "✅ CI scripts permissions set"
fi

echo "✅ All script permissions fixed!"
echo ""

# Test that the main script can now run
if [ -x "launch-vitalsense.sh" ]; then
    echo "🎉 SUCCESS! You can now run:"
    echo "   ./launch-vitalsense.sh"
    echo ""
    echo "🏥 VitalSense Health App Setup Ready!"
    echo ""
    echo "Would you like to start the setup now? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo "🚀 Starting VitalSense setup..."
        ./launch-vitalsense.sh
    else
        echo ""
        echo "✅ Ready when you are! Run './launch-vitalsense.sh' to start."
    fi
else
    echo "❌ Still having permission issues. Try running:"
    echo "   sudo chmod +x *.sh"
    echo "   Then: ./launch-vitalsense.sh"
fi

echo ""
echo "📋 Available scripts after permission fix:"
echo "• ./launch-vitalsense.sh      - Main setup guide"
echo "• ./setup-project.sh          - Generate core files"  
echo "• ./setup-xcode-cloud.sh      - Configure CI/CD"
echo "• ./validate-xcode-cloud.sh   - Validate setup"
echo "• ./cleanup-project.sh        - Remove duplicates"
echo ""
echo "🏥 Your VitalSense health monitoring app is ready to build!"