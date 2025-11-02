#!/bin/bash

# VitalSense Launch Script - Optimized & Clean
# Sets up a working iOS health monitoring app

echo "🚀 VitalSense Launch Preparation"
echo "================================"

# First, ensure all scripts have correct permissions
echo "🔧 Setting up script permissions..."
echo "   If you get 'permission denied' errors, run:"
echo "   chmod +x *.sh && chmod +x ci_scripts/*.sh"
echo ""

chmod +x setup-permissions.sh 2>/dev/null || true
if [ -f "setup-permissions.sh" ] && [ -x "setup-permissions.sh" ]; then
    ./setup-permissions.sh
else
    echo "⚠️  Permission setup script not found, trying manual approach..."
    chmod +x *.sh 2>/dev/null || true
    chmod +x ci_scripts/*.sh 2>/dev/null || true
    echo "✅ Basic permissions set"
fi

echo ""
echo ""

echo "📱 1. CREATE XCODE PROJECT (10 minutes):"
echo "   • Open Xcode → Create new iOS App"
echo "   • Project Name: VitalSense"
echo "   • Bundle ID: dev.andernet.VitalSense"
echo "   • Language: Swift, Interface: SwiftUI"
echo "   • Replace ContentView.swift with VitalSenseApp.swift"
echo ""

echo "⌚ 2. ADD APPLE WATCH TARGET (5 minutes):"
echo "   • File → New → Target → watchOS → Watch App"
echo "   • Target Name: VitalSenseWatch"
echo "   • Replace watch ContentView.swift with VitalSenseWatchApp.swift"
echo ""

echo "🏥 3. ADD HEALTH MANAGERS (3 minutes):"
echo "   • Drag HealthKitManager.swift to main app target"
echo "   • Drag GaitAnalyzer.swift to main app target"
echo "   • Add HealthKit.framework and CoreMotion.framework"
echo ""

echo "⚙️  4. CONFIGURE PROJECT (5 minutes):"
echo "   • Project Settings → Build Settings → Configuration Files"
echo "   • Debug: VitalSense.xcodeproj/Configuration/Debug.xcconfig"
echo "   • Release: VitalSense.xcodeproj/Configuration/Release.xcconfig"
echo "   • Update DEVELOPMENT_TEAM in Base.xcconfig to your Apple ID"
echo ""

echo "🔐 5. SET UP PERMISSIONS (3 minutes):"
echo "   • Target Settings → Info → Custom iOS Target Properties"
echo "   • Set Info.plist file to src/VitalSense/Support/Info.plist"
echo "   • Signing & Capabilities → Add HealthKit capability"
echo "   • Add VitalSense.entitlements file"
echo ""

echo "🎨 6. CREATE APP ICON (10 minutes):"
echo "   • Design 1024x1024 PNG health icon (heart, walking figure, etc.)"
echo "   • Run: ./generate-app-icons.sh your-icon-1024.png"
echo "   • Drag generated icons to Assets.xcassets/AppIcon.appiconset"
echo ""

echo "✅ 7. VALIDATE & TEST (5 minutes):"
echo "   • Run: ./validate-app-store.sh"
echo "   • Connect iPhone and Apple Watch"
echo "   • Build and run on physical devices (HealthKit requires real hardware)"
echo "   • Test HealthKit permissions and gait analysis"
echo ""

echo "🚀 8. DEPLOY TO TESTFLIGHT (2 minutes):"
echo "   • Run: ./deploy-testflight.sh"
echo "   • Or: Xcode → Product → Archive → Distribute App"
echo "   • Upload to App Store Connect"
echo ""

echo ""
echo "🏥 YOUR VITALSENSE HEALTH APP FEATURES:"
echo "======================================"
echo "✅ Real-time gait analysis and fall risk assessment"
echo "✅ HealthKit integration with 17+ health data types"
echo "✅ Independent Apple Watch app with workout sessions"
echo "✅ Machine learning-powered health insights"
echo "✅ HIPAA-compliant privacy and data export"
echo "✅ Professional medical disclaimers"
echo "✅ Healthcare provider data sharing"
echo ""

echo "📋 WHAT YOU HAVE READY:"
echo "======================"
echo "• Complete iOS app with SwiftUI interface"
echo "• Full Apple Watch companion app"
echo "• Professional HealthKit data management"
echo "• Advanced gait analysis algorithms"
echo "• App Store marketing materials"
echo "• Privacy policy and medical disclaimers"
echo "• Automated deployment scripts"
echo ""

echo "⏰ TIME TO APP STORE:"
echo "===================="
echo "• Project setup: 30 minutes"
echo "• Icon creation: 15 minutes"
echo "• Testing: 30 minutes"
echo "• App Store submission: 15 minutes"
echo "• TOTAL: 90 minutes to submission!"
echo ""

echo "🎉 START BUILDING YOUR PROFESSIONAL HEALTH APP NOW!"
echo ""

# Display file summary
echo "📁 YOUR COMPLETE PACKAGE:"
echo "========================"
echo "Swift Apps:"
echo "  • VitalSenseApp.swift (iOS app)"
echo "  • VitalSenseWatchApp.swift (Apple Watch app)"
echo "  • HealthKitManager.swift (Health data management)"
echo "  • GaitAnalyzer.swift (Gait analysis engine)"
echo ""
echo "Configuration:"
echo "  • Info.plist files for all targets"
echo "  • VitalSense.entitlements (HealthKit permissions)"
echo "  • Build configuration (.xcconfig) files"
echo "  • Config.plist (App settings)"
echo ""
echo "Automation:"
echo "  • validate-app-store.sh (Pre-submission checks)"
echo "  • deploy-testflight.sh (Automated deployment)"
echo "  • generate-app-icons.sh (Icon generation)"
echo "  • create-screenshots.sh (Screenshot templates)"
echo ""
echo "Documentation:"
echo "  • Complete App Store submission guide"
echo "  • Privacy policy and medical disclaimers"
echo "  • Marketing materials and app description"
echo "  • Apple Watch integration guide"
echo ""

echo "🚀 Your professional VitalSense health app is ready to launch!"