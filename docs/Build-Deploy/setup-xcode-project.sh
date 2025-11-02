#!/bin/bash

# VitalSense Xcode Project Configuration Script
# Automates linking of configuration files and project setup

set -euo pipefail

echo "🔧 VitalSense Xcode Project Setup"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="VitalSense"
WORKSPACE_NAME="VitalSense.xcworkspace"
PROJECT_FILE="VitalSense.xcodeproj"

echo -e "${BLUE}📋 Checking project structure...${NC}"

# Check if we're in the right directory
if [ ! -f "Base.xcconfig" ] || [ ! -f "Info.plist" ]; then
    echo -e "${RED}❌ Please run this script from the directory containing the configuration files${NC}"
    exit 1
fi

# Prompt for Apple Developer Team ID
echo -e "${YELLOW}🔐 Apple Developer Team Setup${NC}"
echo "Current Team ID in configuration: C8U3P6AJ6L"
read -p "Enter your Apple Developer Team ID (or press Enter to keep current): " TEAM_ID

if [ ! -z "$TEAM_ID" ]; then
    echo -e "${BLUE}📝 Updating Team ID in configuration files...${NC}"
    
    # Update Base.xcconfig
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/DEVELOPMENT_TEAM = C8U3P6AJ6L/DEVELOPMENT_TEAM = $TEAM_ID/g" Base.xcconfig
    else
        sed -i "s/DEVELOPMENT_TEAM = C8U3P6AJ6L/DEVELOPMENT_TEAM = $TEAM_ID/g" Base.xcconfig
    fi
    
    echo -e "${GREEN}✅ Team ID updated to: $TEAM_ID${NC}"
fi

# Create directories if they don't exist
echo -e "${BLUE}📁 Creating project directory structure...${NC}"

mkdir -p "VitalSense.xcodeproj/Configuration"
mkdir -p "src/VitalSense/Support"
mkdir -p "src/VitalSenseWatch"
mkdir -p "src/VitalSenseWidgets"
mkdir -p "src/VitalSense/Resources/Assets.xcassets/AppIcon.appiconset"
mkdir -p "src/VitalSense/Resources/Assets.xcassets/AppIcon-Watch.appiconset"
mkdir -p "src/VitalSense/Resources/Assets.xcassets/AccentColor.colorset"

# Move configuration files to proper locations
echo -e "${BLUE}📦 Moving configuration files...${NC}"

mv Base.xcconfig "VitalSense.xcodeproj/Configuration/" 2>/dev/null || cp Base.xcconfig "VitalSense.xcodeproj/Configuration/"
mv Debug.xcconfig "VitalSense.xcodeproj/Configuration/" 2>/dev/null || cp Debug.xcconfig "VitalSense.xcodeproj/Configuration/"
mv Release.xcconfig "VitalSense.xcodeproj/Configuration/" 2>/dev/null || cp Release.xcconfig "VitalSense.xcodeproj/Configuration/"
mv Shared.xcconfig "VitalSense.xcodeproj/Configuration/" 2>/dev/null || cp Shared.xcconfig "VitalSense.xcodeproj/Configuration/"

mv Info.plist "src/VitalSense/Support/" 2>/dev/null || cp Info.plist "src/VitalSense/Support/"
mv InfoWatch.plist "src/VitalSenseWatch/Info.plist" 2>/dev/null || cp InfoWatch.plist "src/VitalSenseWatch/Info.plist"
mv InfoWidgets.plist "src/VitalSenseWidgets/Info.plist" 2>/dev/null || cp InfoWidgets.plist "src/VitalSenseWidgets/Info.plist"
mv VitalSense.entitlements "src/VitalSense/Support/" 2>/dev/null || cp VitalSense.entitlements "src/VitalSense/Support/"
mv Config.plist "src/VitalSense/Support/" 2>/dev/null || cp Config.plist "src/VitalSense/Support/"

echo -e "${GREEN}✅ Configuration files organized${NC}"

# Create basic Contents.json files for asset catalogs
echo -e "${BLUE}🎨 Setting up asset catalogs...${NC}"

# AppIcon Contents.json
cat > "src/VitalSense/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Watch AppIcon Contents.json
cat > "src/VitalSense/Resources/Assets.xcassets/AppIcon-Watch.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "watch",
      "role" : "notificationCenter",
      "scale" : "2x",
      "size" : "24x24",
      "subtype" : "38mm"
    },
    {
      "idiom" : "watch",
      "role" : "notificationCenter",
      "scale" : "2x",
      "size" : "27.5x27.5",
      "subtype" : "42mm"
    },
    {
      "idiom" : "watch",
      "role" : "companionSettings",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "watch",
      "role" : "companionSettings",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "idiom" : "watch",
      "role" : "notificationCenter",
      "scale" : "2x",
      "size" : "33x33",
      "subtype" : "45mm"
    },
    {
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "40x40",
      "subtype" : "38mm"
    },
    {
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "44x44",
      "subtype" : "40mm"
    },
    {
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "46x46",
      "subtype" : "41mm"
    },
    {
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "50x50",
      "subtype" : "44mm"
    },
    {
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "51x51",
      "subtype" : "45mm"
    },
    {
      "idiom" : "watch",
      "role" : "quickLook",
      "scale" : "2x",
      "size" : "86x86",
      "subtype" : "38mm"
    },
    {
      "idiom" : "watch",
      "role" : "quickLook",
      "scale" : "2x",
      "size" : "98x98",
      "subtype" : "42mm"
    },
    {
      "idiom" : "watch",
      "role" : "quickLook",
      "scale" : "2x",
      "size" : "108x108",
      "subtype" : "44mm"
    },
    {
      "idiom" : "watch-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# AccentColor Contents.json
cat > "src/VitalSense/Resources/Assets.xcassets/AccentColor.colorset/Contents.json" << 'EOF'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "1.000",
          "green" : "0.400",
          "red" : "0.200"
        }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "1.000",
          "green" : "0.500",
          "red" : "0.300"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Assets.xcassets Contents.json
cat > "src/VitalSense/Resources/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo -e "${GREEN}✅ Asset catalog structure created${NC}"

echo -e "${BLUE}📋 Setup Summary:${NC}"
echo "================================="
echo -e "${GREEN}✅ Configuration files organized${NC}"
echo -e "${GREEN}✅ Project directory structure created${NC}"
echo -e "${GREEN}✅ Asset catalog templates ready${NC}"
echo -e "${GREEN}✅ Info.plist files in correct locations${NC}"
echo -e "${GREEN}✅ Entitlements file ready${NC}"

echo ""
echo -e "${YELLOW}🚀 Next Steps in Xcode:${NC}"
echo "1. Open VitalSense.xcworkspace (or create new project)"
echo "2. Link xcconfig files in Build Settings for each target"
echo "3. Set Info.plist paths for each target"
echo "4. Add VitalSense.entitlements to main app target"
echo "5. Add 1024x1024 app icon images to asset catalogs"

echo ""
echo -e "${BLUE}📱 For App Store submission, you'll also need:${NC}"
echo "• 1024x1024 PNG app icons (no transparency)"
echo "• iPhone screenshots (6.7\", 6.5\", 5.5\" sizes)"
echo "• Apple Watch screenshots"
echo "• Privacy policy URL"
echo "• App Store Connect app record"

echo ""
echo -e "${GREEN}🎉 Project setup complete!${NC}"