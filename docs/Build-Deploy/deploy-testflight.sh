#!/bin/bash

# VitalSense TestFlight Deployment Script
# Automates build, archive, and upload process

set -euo pipefail

echo "🚀 VitalSense TestFlight Deployment"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_NAME="VitalSense"
WORKSPACE_NAME="VitalSense.xcworkspace"
SCHEME_NAME="VitalSense"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/VitalSense.xcarchive"
EXPORT_PATH="./build/export"

# Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

if [ ! -f "$WORKSPACE_NAME" ] && [ ! -f "VitalSense.xcodeproj" ]; then
    echo -e "${RED}❌ No Xcode workspace or project found${NC}"
    echo "Please run this script from your project root directory"
    exit 1
fi

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ xcodebuild not found${NC}"
    echo "Please install Xcode and Xcode Command Line Tools"
    exit 1
fi

# Determine build target
BUILD_TARGET=""
if [ -f "$WORKSPACE_NAME" ]; then
    BUILD_TARGET="-workspace $WORKSPACE_NAME"
else
    BUILD_TARGET="-project VitalSense.xcodeproj"
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Clean build folder
echo -e "${BLUE}🧹 Cleaning build folder...${NC}"
rm -rf build/
mkdir -p build/

# Increment build number
echo -e "${BLUE}📈 Incrementing build number...${NC}"
CURRENT_BUILD=$(xcodebuild $BUILD_TARGET -scheme $SCHEME_NAME -showBuildSettings | grep "CURRENT_PROJECT_VERSION" | head -1 | sed 's/.*= //')
NEW_BUILD=$((CURRENT_BUILD + 1))

echo "Current build: $CURRENT_BUILD"
echo "New build: $NEW_BUILD"

# Update build number in project
agvtool new-version -all $NEW_BUILD 2>/dev/null || echo -e "${YELLOW}⚠️  Could not auto-increment build number${NC}"

# Pre-flight checks
echo -e "${BLUE}✈️  Running pre-flight checks...${NC}"

# Check for required files
MISSING_FILES=0

check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}❌ Missing: $1${NC}"
        ((MISSING_FILES++))
    else
        echo -e "${GREEN}✅ Found: $1${NC}"
    fi
}

echo "Checking configuration files:"
check_file "VitalSense.xcodeproj/Configuration/Base.xcconfig"
check_file "VitalSense.xcodeproj/Configuration/Release.xcconfig"

echo "Checking app files:"
check_file "src/VitalSense/Support/Info.plist"
check_file "src/VitalSense/Support/VitalSense.entitlements"

if [ $MISSING_FILES -gt 0 ]; then
    echo -e "${RED}❌ $MISSING_FILES required files missing${NC}"
    echo "Please run setup-xcode-project.sh first"
    exit 1
fi

# Build and analyze
echo -e "${BLUE}🔨 Building and analyzing project...${NC}"
xcodebuild $BUILD_TARGET \
    -scheme $SCHEME_NAME \
    -configuration $CONFIGURATION \
    clean analyze | xcpretty || {
    echo -e "${RED}❌ Build analysis failed${NC}"
    exit 1
}

echo -e "${GREEN}✅ Analysis passed${NC}"

# Archive
echo -e "${BLUE}📦 Creating archive...${NC}"
xcodebuild $BUILD_TARGET \
    -scheme $SCHEME_NAME \
    -configuration $CONFIGURATION \
    -archivePath "$ARCHIVE_PATH" \
    archive | xcpretty || {
    echo -e "${RED}❌ Archive failed${NC}"
    exit 1
}

echo -e "${GREEN}✅ Archive created: $ARCHIVE_PATH${NC}"

# Create export options plist
echo -e "${BLUE}📝 Creating export options...${NC}"

cat > build/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>destination</key>
    <string>upload</string>
    <key>manageAppVersionAndBuildNumber</key>
    <true/>
    <key>teamID</key>
    <string>$(xcodebuild $BUILD_TARGET -scheme $SCHEME_NAME -showBuildSettings | grep "DEVELOPMENT_TEAM" | head -1 | sed 's/.*= //')</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF

# Export archive
echo -e "${BLUE}📤 Exporting archive for App Store...${NC}"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist build/ExportOptions.plist | xcpretty || {
    echo -e "${RED}❌ Export failed${NC}"
    exit 1
}

echo -e "${GREEN}✅ Export completed: $EXPORT_PATH${NC}"

# Find the .ipa file
IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -1)
if [ -z "$IPA_FILE" ]; then
    echo -e "${RED}❌ No .ipa file found in export${NC}"
    exit 1
fi

echo -e "${GREEN}📱 IPA file: $IPA_FILE${NC}"

# Get file size
FILE_SIZE=$(ls -lh "$IPA_FILE" | awk '{print $5}')
echo -e "${BLUE}📊 IPA size: $FILE_SIZE${NC}"

# Check if we should upload to TestFlight
echo ""
echo -e "${YELLOW}🚀 Ready to upload to TestFlight!${NC}"
echo ""
read -p "Upload to TestFlight now? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}📤 Uploading to TestFlight...${NC}"
    
    # Upload using xcrun altool
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_FILE" \
        --username "${APPLE_ID_EMAIL:-$(whoami)@example.com}" \
        --password "@keychain:Application Loader: ${APPLE_ID_EMAIL:-$(whoami)@example.com}" || {
        
        echo -e "${YELLOW}⚠️  Upload with altool failed, trying Transporter...${NC}"
        
        # Try with Transporter app
        if command -v xcrun &> /dev/null; then
            echo "Please use Xcode Organizer or Transporter app to upload manually:"
            echo "File: $IPA_FILE"
            open "$EXPORT_PATH"
        fi
    }
else
    echo -e "${BLUE}📋 Manual upload instructions:${NC}"
    echo "1. Open Xcode → Window → Organizer"
    echo "2. Select Archives tab"
    echo "3. Select your VitalSense archive"
    echo "4. Click 'Distribute App'"
    echo "5. Choose 'App Store Connect'"
    echo "6. Follow the upload wizard"
    echo ""
    echo "Or use Transporter app:"
    echo "File location: $IPA_FILE"
    open "$EXPORT_PATH"
fi

echo ""
echo -e "${GREEN}🎉 Build process completed!${NC}"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo "• Build number: $NEW_BUILD"
echo "• Archive: $ARCHIVE_PATH"
echo "• IPA: $IPA_FILE"
echo "• Size: $FILE_SIZE"
echo ""
echo -e "${BLUE}📱 Next steps for TestFlight:${NC}"
echo "1. Wait for processing in App Store Connect (30-90 minutes)"
echo "2. Add test information and release notes"
echo "3. Submit for Beta App Review (if external testing)"
echo "4. Invite testers once approved"
echo ""
echo -e "${YELLOW}⚠️  Health app testing notes:${NC}"
echo "• HealthKit requires physical device testing"
echo "• Test all permission flows thoroughly"
echo "• Verify Apple Watch companion functionality"
echo "• Test background health data collection"
echo ""
echo -e "${GREEN}✨ Your VitalSense app is ready for TestFlight!${NC}"