#!/bin/bash

# VitalSense App Store Validation Script
# Comprehensive pre-submission checks for health apps

set -euo pipefail

echo "✅ VitalSense App Store Validation"
echo "=================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Validation counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED++))
}

fail() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

check_file() {
    if [ -f "$1" ]; then
        pass "Found: $1"
        return 0
    else
        fail "Missing: $1"
        return 1
    fi
}

check_file_content() {
    if [ -f "$1" ] && [ -s "$1" ]; then
        pass "$1 exists and has content"
        return 0
    else
        fail "$1 missing or empty"
        return 1
    fi
}

echo -e "${BLUE}🏥 Health App Specific Validation${NC}"
echo "================================="

# 1. HealthKit Configuration
echo -e "\n${BLUE}🔒 HealthKit & Permissions${NC}"

if check_file "src/VitalSense/Support/VitalSense.entitlements"; then
    if grep -q "com.apple.developer.healthkit" "src/VitalSense/Support/VitalSense.entitlements"; then
        pass "HealthKit entitlement found"
    else
        fail "HealthKit entitlement missing from VitalSense.entitlements"
    fi
fi

if check_file "src/VitalSense/Support/Info.plist"; then
    if grep -q "NSHealthShareUsageDescription" "src/VitalSense/Support/Info.plist"; then
        pass "NSHealthShareUsageDescription found"
    else
        fail "NSHealthShareUsageDescription missing from Info.plist"
    fi
    
    if grep -q "NSHealthUpdateUsageDescription" "src/VitalSense/Support/Info.plist"; then
        pass "NSHealthUpdateUsageDescription found"
    else
        fail "NSHealthUpdateUsageDescription missing from Info.plist"
    fi
    
    if grep -q "NSMotionUsageDescription" "src/VitalSense/Support/Info.plist"; then
        pass "NSMotionUsageDescription found"
    else
        fail "NSMotionUsageDescription missing from Info.plist"
    fi
fi

# 2. Build Configuration
echo -e "\n${BLUE}⚙️  Build Configuration${NC}"

check_file_content "VitalSense.xcodeproj/Configuration/Base.xcconfig"
check_file_content "VitalSense.xcodeproj/Configuration/Debug.xcconfig" 
check_file_content "VitalSense.xcodeproj/Configuration/Release.xcconfig"

if [ -f "VitalSense.xcodeproj/Configuration/Base.xcconfig" ]; then
    TEAM_ID=$(grep "DEVELOPMENT_TEAM" "VitalSense.xcodeproj/Configuration/Base.xcconfig" | cut -d'=' -f2 | xargs)
    if [ "$TEAM_ID" == "C8U3P6AJ6L" ]; then
        warn "Development Team ID is still placeholder - update to your actual Apple Developer Team ID"
    else
        pass "Development Team ID configured: $TEAM_ID"
    fi
    
    if grep -q "SWIFT_VERSION = 5.9" "VitalSense.xcodeproj/Configuration/Base.xcconfig"; then
        pass "Swift 5.9 configured"
    else
        warn "Swift version may not be optimal"
    fi
    
    if grep -q "IPHONEOS_DEPLOYMENT_TARGET = 16.0" "VitalSense.xcodeproj/Configuration/Base.xcconfig"; then
        pass "iOS 16.0 deployment target set"
    else
        warn "iOS deployment target may be suboptimal"
    fi
fi

# 3. App Icons & Assets
echo -e "\n${BLUE}🎨 App Icons & Assets${NC}"

check_file "src/VitalSense/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json"
check_file "src/VitalSense/Resources/Assets.xcassets/AccentColor.colorset/Contents.json"

# Check for actual icon files
ICON_COUNT=$(find src/VitalSense/Resources/Assets.xcassets/AppIcon.appiconset/ -name "*.png" 2>/dev/null | wc -l)
if [ $ICON_COUNT -gt 0 ]; then
    pass "$ICON_COUNT app icon files found"
else
    fail "No app icon PNG files found - add 1024x1024 and other required sizes"
fi

# 4. Multi-target Configuration
echo -e "\n${BLUE}📱 Multi-target Setup${NC}"

check_file "src/VitalSenseWatch/Info.plist"
check_file "src/VitalSenseWidgets/Info.plist"

# 5. Bundle Identifiers
echo -e "\n${BLUE}📦 Bundle Identifier Validation${NC}"

if [ -f "VitalSense.xcodeproj/Configuration/Base.xcconfig" ]; then
    BUNDLE_ID=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "VitalSense.xcodeproj/Configuration/Base.xcconfig" | cut -d'=' -f2 | xargs)
    if [[ $BUNDLE_ID == dev.andernet.VitalSense* ]]; then
        pass "Bundle identifier configured: $BUNDLE_ID"
    else
        warn "Bundle identifier should follow dev.andernet.VitalSense pattern"
    fi
fi

# 6. Privacy & Security
echo -e "\n${BLUE}🔐 Privacy & Security${NC}"

# Check for privacy policy placeholder
if check_file "src/VitalSense/Support/Info.plist"; then
    if grep -q "privacy-policy" "src/VitalSense/Support/Info.plist" 2>/dev/null; then
        warn "Privacy policy URL placeholder found - update with actual URL"
    else
        warn "Consider adding privacy policy URL for health app compliance"
    fi
fi

# Check for hardened runtime
if [ -f "VitalSense.xcodeproj/Configuration/Base.xcconfig" ]; then
    if grep -q "ENABLE_HARDENED_RUNTIME = YES" "VitalSense.xcodeproj/Configuration/Base.xcconfig"; then
        pass "Hardened runtime enabled"
    else
        warn "Consider enabling hardened runtime for security"
    fi
fi

# 7. Health Data Categories
echo -e "\n${BLUE}🏥 Health Data Configuration${NC}"

if check_file "src/VitalSense/Support/Config.plist"; then
    if grep -q "healthKitDataTypes" "src/VitalSense/Support/Config.plist"; then
        pass "Health data types configured in Config.plist"
    else
        warn "Health data types not configured in Config.plist"
    fi
    
    if grep -q "gaitAnalysisSettings" "src/VitalSense/Support/Config.plist"; then
        pass "Gait analysis settings configured"
    else
        warn "Gait analysis settings not found in Config.plist"
    fi
fi

# 8. Background Modes
echo -e "\n${BLUE}🔄 Background Processing${NC}"

if [ -f "src/VitalSense/Support/Info.plist" ]; then
    if grep -q "workout-processing" "src/VitalSense/Support/Info.plist"; then
        pass "Workout processing background mode configured"
    else
        warn "Workout processing background mode not found"
    fi
    
    if grep -q "health-research" "src/VitalSense/Support/Info.plist"; then
        pass "Health research background mode configured"
    else
        warn "Health research background mode not found"
    fi
fi

# 9. Version Information
echo -e "\n${BLUE}📊 Version Information${NC}"

if [ -f "VitalSense.xcodeproj/Configuration/Shared.xcconfig" ]; then
    if grep -q "MARKETING_VERSION = 1.0" "VitalSense.xcodeproj/Configuration/Shared.xcconfig"; then
        pass "Marketing version set to 1.0"
    else
        warn "Marketing version not set to 1.0"
    fi
    
    if grep -q "CURRENT_PROJECT_VERSION = 1" "VitalSense.xcodeproj/Configuration/Shared.xcconfig"; then
        pass "Build version set to 1"
    else
        warn "Build version not set to 1"
    fi
fi

# 10. Apple Watch Configuration
echo -e "\n${BLUE}⌚ Apple Watch Setup${NC}"

if check_file "src/VitalSenseWatch/Info.plist"; then
    if grep -q "WKApplication" "src/VitalSenseWatch/Info.plist"; then
        pass "WatchKit application configured"
    else
        fail "WatchKit application not properly configured"
    fi
    
    if grep -q "dev.andernet.VitalSense" "src/VitalSenseWatch/Info.plist"; then
        pass "Watch companion app bundle identifier linked"
    else
        warn "Watch companion app bundle identifier not properly linked"
    fi
fi

# 11. Potential Issues Check
echo -e "\n${BLUE}⚠️  Common Issues Check${NC}"

# Check for placeholder content
if grep -r "TODO\|FIXME\|placeholder" src/ 2>/dev/null | head -5; then
    warn "Found TODO/FIXME/placeholder comments - review before submission"
else
    pass "No obvious placeholder content found"
fi

# Check for debug code
if grep -r "print(\|NSLog\|debugPrint" src/ 2>/dev/null | grep -v "// DEBUG" | head -3; then
    warn "Found debug print statements - consider removing for production"
else
    pass "No obvious debug print statements found"
fi

# Summary
echo ""
echo -e "${BLUE}📋 Validation Summary${NC}"
echo "====================="
echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 Validation Complete - Ready for App Store submission!${NC}"
    
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}📝 Address warnings above for optimal submission${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo "1. Run './deploy-testflight.sh' to build and upload"
    echo "2. Create App Store Connect app record"  
    echo "3. Add app icons (1024x1024 PNG)"
    echo "4. Take screenshots for App Store"
    echo "5. Write app description and privacy policy"
    echo "6. Submit for App Review"
    
else
    echo -e "${RED}🚨 Fix failed items before submitting to App Store${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}💡 Health App Submission Tips:${NC}"
echo "• Expect 7-14 day review time for health apps"
echo "• Provide clear demo instructions for reviewers"
echo "• Include medical disclaimers (not for diagnosis/treatment)"
echo "• Justify all HealthKit data usage clearly"
echo "• Test thoroughly on physical devices"
echo "• Ensure Apple Watch functionality works independently"

exit 0