#!/bin/bash

# VitalSense Xcode Cloud Validation Script
# Validates that the project is properly configured for Xcode Cloud

echo "🔍 VitalSense Xcode Cloud Validation"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
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

echo ""
echo "📋 Phase 1: Xcode Cloud Script Validation"
echo "========================================="

# Check ci_scripts directory exists
if [ -d "ci_scripts" ]; then
    pass "ci_scripts directory exists"
else
    fail "ci_scripts directory missing - run ./setup-xcode-cloud.sh"
fi

# Check required scripts exist and are executable
for script in "ci_post_clone.sh" "ci_pre_xcodebuild.sh" "ci_post_xcodebuild.sh"; do
    if [ -x "ci_scripts/$script" ]; then
        pass "ci_scripts/$script is executable"
    elif [ -f "ci_scripts/$script" ]; then
        warn "ci_scripts/$script exists but not executable"
        chmod +x "ci_scripts/$script"
        pass "Made ci_scripts/$script executable"
    else
        fail "ci_scripts/$script missing"
    fi
done

# Check .xcodecloudignore exists
if [ -f ".xcodecloudignore" ]; then
    pass ".xcodecloudignore file exists"
else
    fail ".xcodecloudignore missing"
fi

echo ""
echo "📋 Phase 2: VitalSense Health App Configuration"
echo "=============================================="

# Check for VitalSense app files
if [ -f "VitalSenseApp.swift" ]; then
    pass "VitalSenseApp.swift found"
else
    fail "VitalSenseApp.swift missing - core app file required"
fi

# Check for HealthKit manager
if [ -f "HealthKitManager.swift" ]; then
    pass "HealthKitManager.swift found"
    # Check if it contains HealthKit imports
    if grep -q "import HealthKit" "HealthKitManager.swift"; then
        pass "HealthKit import found in HealthKitManager"
    else
        warn "HealthKit import missing in HealthKitManager"
    fi
else
    fail "HealthKitManager.swift missing - required for health functionality"
fi

# Check for GaitAnalyzer
if [ -f "GaitAnalyzer.swift" ]; then
    pass "GaitAnalyzer.swift found"
    if grep -q "import CoreMotion" "GaitAnalyzer.swift"; then
        pass "CoreMotion import found in GaitAnalyzer"
    else
        warn "CoreMotion import missing in GaitAnalyzer"
    fi
else
    fail "GaitAnalyzer.swift missing - required for gait analysis"
fi

# Check for Apple Watch app
if [ -f "VitalSenseWatchApp.swift" ]; then
    pass "VitalSenseWatchApp.swift found"
else
    warn "VitalSenseWatchApp.swift missing - Apple Watch functionality unavailable"
fi

echo ""
echo "📋 Phase 3: Health App Permissions & Configuration"
echo "================================================="

# Check Info.plist
if [ -f "Info.plist" ]; then
    pass "Info.plist found"
    
    # Check for health usage descriptions
    if grep -q "NSHealthShareUsageDescription" "Info.plist"; then
        pass "Health share usage description found"
    else
        fail "NSHealthShareUsageDescription missing - required for HealthKit"
    fi
    
    if grep -q "NSHealthUpdateUsageDescription" "Info.plist"; then
        pass "Health update usage description found"
    else
        warn "NSHealthUpdateUsageDescription missing - may be required"
    fi
    
    if grep -q "NSMotionUsageDescription" "Info.plist"; then
        pass "Motion usage description found"
    else
        fail "NSMotionUsageDescription missing - required for gait analysis"
    fi
else
    fail "Info.plist missing - required for app configuration"
fi

# Check entitlements file
if [ -f "VitalSense.entitlements" ]; then
    pass "VitalSense.entitlements found"
    
    if grep -q "com.apple.developer.healthkit" "VitalSense.entitlements"; then
        pass "HealthKit entitlement found"
    else
        fail "HealthKit entitlement missing in entitlements file"
    fi
else
    fail "VitalSense.entitlements missing - required for HealthKit"
fi

echo ""
echo "📋 Phase 4: Test Configuration"
echo "============================="

# Check for test directory
if [ -d "VitalSenseTests" ]; then
    pass "VitalSenseTests directory exists"
    
    # Check for health-specific tests
    if [ -f "VitalSenseTests/HealthKitManagerTests.swift" ]; then
        pass "HealthKitManagerTests.swift found"
    else
        warn "HealthKitManagerTests.swift missing - health testing recommended"
    fi
    
    if [ -f "VitalSenseTests/GaitAnalyzerTests.swift" ]; then
        pass "GaitAnalyzerTests.swift found"
    else
        warn "GaitAnalyzerTests.swift missing - gait analysis testing recommended"
    fi
else
    warn "VitalSenseTests directory missing - unit testing recommended for Xcode Cloud"
fi

echo ""
echo "📋 Phase 5: Repository Configuration"
echo "==================================="

# Check if we're in a git repository
if [ -d ".git" ]; then
    pass "Git repository detected"
    
    # Check for common branches
    if git branch -r | grep -q "origin/main\|origin/master"; then
        pass "Main branch exists for Xcode Cloud workflows"
    else
        warn "Main/master branch not found - required for Xcode Cloud"
    fi
    
    # Check if there are any commits
    if git log --oneline -1 >/dev/null 2>&1; then
        pass "Repository has commits"
    else
        warn "No commits found - add and commit files before Xcode Cloud setup"
    fi
else
    fail "Not a git repository - git is required for Xcode Cloud"
fi

# Check for large files that should be ignored
if [ -f ".xcodecloudignore" ]; then
    if grep -q "*.md" ".xcodecloudignore"; then
        pass "Documentation files excluded from builds"
    else
        warn "Consider excluding documentation files from builds"
    fi
fi

echo ""
echo "📋 Phase 6: Health App Specific Validation"
echo "=========================================="

# Validate health app requirements
echo "🏥 Health App Requirements Check:"

# Check for medical disclaimers
if find . -name "*.swift" -exec grep -l "medical\|health.*disclaimer\|FDA" {} \; | head -1 >/dev/null; then
    pass "Medical disclaimers found in code"
else
    warn "Medical disclaimers should be included for health apps"
fi

# Check for privacy considerations
if find . -name "*.swift" -exec grep -l "privacy\|HIPAA\|health.*data" {} \; | head -1 >/dev/null; then
    pass "Privacy considerations found in code"
else
    warn "Privacy handling should be documented for health apps"
fi

# Check for error handling in health managers
if [ -f "HealthKitManager.swift" ] && grep -q "error\|Error\|throw" "HealthKitManager.swift"; then
    pass "Error handling found in HealthKitManager"
else
    warn "Robust error handling recommended for health data"
fi

echo ""
echo "🎯 VALIDATION SUMMARY"
echo "===================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo "🎉 VitalSense is fully optimized for Xcode Cloud!"
        echo ""
        echo "🚀 Next Steps:"
        echo "1. Commit all changes to your repository"
        echo "2. Push to GitHub/GitLab/Bitbucket"
        echo "3. Configure workflows in App Store Connect"
        echo "4. Enable Xcode Cloud for automatic builds"
    else
        echo "✅ VitalSense is ready for Xcode Cloud with some warnings"
        echo "Consider addressing the warnings above for optimal performance"
    fi
else
    echo "❌ VitalSense requires fixes before Xcode Cloud deployment"
    echo "Please address the failed items above"
    exit 1
fi

echo ""
echo "🏥 Health App Specific Recommendations:"
echo "• Test on physical devices for HealthKit validation"
echo "• Include medical disclaimers and privacy policies"
echo "• Configure TestFlight for beta health data testing"  
echo "• Consider FDA regulations if making medical claims"
echo "• Implement robust error handling for health data"
echo ""
echo "☁️ Your VitalSense health monitoring app is ready for Xcode Cloud!"