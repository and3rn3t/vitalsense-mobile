#!/bin/bash

# VitalSense Complete Integration Script
# Sets up the full project with all components

set -euo pipefail

echo "🏥 VitalSense Complete Integration Setup"
echo "========================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Make all scripts executable
echo -e "${BLUE}📋 Making all scripts executable...${NC}"
chmod +x *.sh

# Run the complete setup
echo -e "${BLUE}🔧 Running project setup...${NC}"
./setup-xcode-project.sh

# Generate screenshot templates  
echo -e "${BLUE}📸 Creating screenshot templates...${NC}"
./create-screenshots.sh

echo -e "${GREEN}✅ Integration setup complete!${NC}"

# Display next steps
echo ""
echo -e "${BLUE}📱 Your VitalSense App Components:${NC}"
echo "=================================="
echo ""
echo -e "${GREEN}✅ iOS App:${NC} VitalSenseApp.swift"
echo "   • SwiftUI interface with health dashboard"
echo "   • Gait analysis workflow"
echo "   • HealthKit integration"
echo "   • Settings and privacy screens"
echo ""
echo -e "${GREEN}✅ Apple Watch App:${NC} VitalSenseWatchApp.swift"  
echo "   • Independent watch interface"
echo "   • Workout session management"
echo "   • Heart rate monitoring"
echo "   • Health data synchronization"
echo ""
echo -e "${GREEN}✅ HealthKit Manager:${NC} HealthKitManager.swift"
echo "   • Health data permissions"
echo "   • Data reading/writing"
echo "   • Privacy compliance"
echo ""
echo -e "${GREEN}✅ Gait Analyzer:${NC} GaitAnalyzer.swift"
echo "   • Core Motion integration"
echo "   • Real-time gait analysis"
echo "   • Fall risk assessment"
echo "   • Machine learning algorithms"
echo ""

echo -e "${BLUE}⚙️  Configuration Files Ready:${NC}"
echo "• Info.plist files for all targets"
echo "• VitalSense.entitlements with HealthKit permissions"
echo "• Build configuration (.xcconfig) files"
echo "• Config.plist with health data settings"
echo ""

echo -e "${BLUE}🎨 Marketing Materials Ready:${NC}"
echo "• Complete App Store description"
echo "• Screenshot templates and guide"
echo "• Privacy policy template"
echo "• App Store Connect setup guide"
echo ""

echo -e "${YELLOW}🚀 Next Steps to Launch:${NC}"
echo "=========================="
echo ""
echo "1. 📱 Create Xcode Project:"
echo "   • Open Xcode → Create new project → iOS App"
echo "   • Name: VitalSense"
echo "   • Bundle ID: dev.andernet.VitalSense"
echo "   • Add VitalSenseApp.swift as your main App file"
echo ""

echo "2. ⚙️  Configure Project:"
echo "   • Link .xcconfig files to targets in Build Settings"
echo "   • Set Info.plist paths for each target"
echo "   • Add VitalSense.entitlements to main app target"
echo "   • Update DEVELOPMENT_TEAM in Base.xcconfig"
echo ""

echo "3. ⌚ Add Apple Watch Target:"
echo "   • File → New → Target → watchOS → Watch App"
echo "   • Add VitalSenseWatchApp.swift to watch target"
echo "   • Configure watch Info.plist path"
echo ""

echo "4. 📚 Add Health Managers:"
echo "   • Add HealthKitManager.swift to main app target"
echo "   • Add GaitAnalyzer.swift to main app target"
echo "   • Import HealthKit and CoreMotion frameworks"
echo ""

echo "5. 🎨 Create App Icon:"
echo "   • Design 1024x1024 PNG health-themed icon"
echo "   • Run: ./generate-app-icons.sh your-icon.png"
echo "   • Import generated icons into Assets.xcassets"
echo ""

echo "6. ✅ Validate Setup:"
echo "   • Run: ./validate-app-store.sh"
echo "   • Fix any reported issues"
echo "   • Test on physical device (HealthKit requires real hardware)"
echo ""

echo "7. 📤 Deploy to TestFlight:"
echo "   • Run: ./deploy-testflight.sh"
echo "   • Or build manually in Xcode"
echo "   • Upload to App Store Connect"
echo ""

echo ""
echo -e "${GREEN}🎉 Your VitalSense health app is ready for development!${NC}"
echo ""
echo -e "${BLUE}💡 Pro Tips:${NC}"
echo "• Test thoroughly on physical iPhone and Apple Watch"
echo "• HealthKit requires real device - simulator won't work"
echo "• Review Apple's HealthKit guidelines before submission"
echo "• Include appropriate medical disclaimers"
echo "• Expect 7-14 days for App Store health app review"
echo ""

echo -e "${BLUE}📖 Documentation Available:${NC}"
echo "• README.md - Complete overview"
echo "• FINAL_DEPLOYMENT_CHECKLIST.md - 4-day launch plan"
echo "• APP_STORE_CONNECT_GUIDE.md - Step-by-step submission"
echo "• APP_STORE_MARKETING.md - All marketing materials"
echo ""

echo -e "${GREEN}✨ Start building your health app now!${NC}"