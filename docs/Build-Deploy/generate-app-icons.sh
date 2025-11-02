#!/bin/bash

# VitalSense App Icon Generator
# Creates all required app icon sizes from a 1024x1024 source image

set -euo pipefail

echo "🎨 VitalSense App Icon Generator"
echo "==============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick not found${NC}"
    echo "Please install ImageMagick:"
    echo "  macOS: brew install imagemagick"
    echo "  Ubuntu: sudo apt-get install imagemagick"
    echo "  Or use online icon generators instead"
    exit 1
fi

# Check for source image
SOURCE_IMAGE=""
if [ $# -eq 1 ]; then
    SOURCE_IMAGE="$1"
elif [ -f "app-icon-1024.png" ]; then
    SOURCE_IMAGE="app-icon-1024.png"
else
    echo -e "${YELLOW}📷 Please provide a 1024x1024 PNG source image${NC}"
    echo "Usage: $0 [source-image.png]"
    echo ""
    echo "Or place your 1024x1024 icon as 'app-icon-1024.png' in this directory"
    echo ""
    echo "🎨 Icon Design Guidelines:"
    echo "• 1024x1024 pixels"
    echo "• PNG format"
    echo "• No transparency"
    echo "• No rounded corners (iOS adds them automatically)"
    echo "• Health/medical theme with clear, simple design"
    echo "• Consider how it looks at small sizes"
    echo ""
    echo "💡 You can also use online tools like:"
    echo "• https://appicon.co"
    echo "• https://www.canva.com/create/app-icons/"
    echo "• https://www.figma.com (design your own)"
    
    # Create a sample icon template
    echo ""
    echo -e "${BLUE}🖼️  Creating a sample icon template...${NC}"
    
    # Create a simple health-themed icon using ImageMagick
    convert -size 1024x1024 xc:white \
        -fill "#007AFF" \
        -draw "circle 512,512 512,200" \
        -fill "white" \
        -pointsize 400 \
        -gravity center \
        -annotate +0-50 "❤" \
        -fill "#007AFF" \
        -pointsize 120 \
        -gravity center \
        -annotate +0+200 "VitalSense" \
        sample-app-icon-1024.png 2>/dev/null || echo -e "${YELLOW}⚠️  Could not create sample icon${NC}"
    
    if [ -f "sample-app-icon-1024.png" ]; then
        echo -e "${GREEN}✅ Created sample-app-icon-1024.png${NC}"
        echo "You can use this as a starting point or replace with your own design"
        SOURCE_IMAGE="sample-app-icon-1024.png"
    else
        exit 1
    fi
fi

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo -e "${RED}❌ Source image not found: $SOURCE_IMAGE${NC}"
    exit 1
fi

echo -e "${BLUE}📱 Generating iOS app icons from: $SOURCE_IMAGE${NC}"

# Create output directories
mkdir -p "AppIcon-iOS"
mkdir -p "AppIcon-Watch"

# iOS App Icon Sizes (in pixels)
declare -A ios_sizes=(
    ["20"]="20x20"
    ["20@2x"]="40x40"
    ["20@3x"]="60x60"
    ["29"]="29x29"
    ["29@2x"]="58x58"
    ["29@3x"]="87x87"
    ["40"]="40x40"
    ["40@2x"]="80x80"
    ["40@3x"]="120x120"
    ["60@2x"]="120x120"
    ["60@3x"]="180x180"
    ["76"]="76x76"
    ["76@2x"]="152x152"
    ["83.5@2x"]="167x167"
    ["1024"]="1024x1024"
)

# Apple Watch Icon Sizes
declare -A watch_sizes=(
    ["24@2x"]="48x48"
    ["27.5@2x"]="55x55"
    ["29@2x"]="58x58"
    ["29@3x"]="87x87"
    ["33@2x"]="66x66"
    ["40@2x"]="80x80"
    ["44@2x"]="88x88"
    ["46@2x"]="92x92"
    ["50@2x"]="100x100"
    ["51@2x"]="102x102"
    ["86@2x"]="172x172"
    ["98@2x"]="196x196"
    ["108@2x"]="216x216"
    ["1024"]="1024x1024"
)

# Generate iOS icons
echo -e "${BLUE}📱 Generating iOS icons...${NC}"
for name in "${!ios_sizes[@]}"; do
    size="${ios_sizes[$name]}"
    width=$(echo $size | cut -d'x' -f1)
    
    output_file="AppIcon-iOS/icon-${name}.png"
    convert "$SOURCE_IMAGE" -resize ${width}x${width} "$output_file"
    echo "  ✅ $output_file ($size)"
done

# Generate Apple Watch icons (circular)
echo -e "${BLUE}⌚ Generating Apple Watch icons...${NC}"
for name in "${!watch_sizes[@]}"; do
    size="${watch_sizes[$name]}"
    width=$(echo $size | cut -d'x' -f1)
    
    output_file="AppIcon-Watch/icon-${name}.png"
    
    # Create circular mask for watch icons
    convert "$SOURCE_IMAGE" -resize ${width}x${width} \
        \( +clone -threshold -1 -negate -fill white -draw "circle $((width/2)),$((width/2)) $((width/2)),0" \) \
        -alpha off -compose copy_opacity -composite \
        "$output_file" 2>/dev/null || convert "$SOURCE_IMAGE" -resize ${width}x${width} "$output_file"
    
    echo "  ✅ $output_file ($size)"
done

echo ""
echo -e "${GREEN}🎉 App icons generated successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Generated files:${NC}"
echo "• AppIcon-iOS/ - Contains all iOS app icon sizes"
echo "• AppIcon-Watch/ - Contains all Apple Watch icon sizes"
echo ""
echo -e "${YELLOW}📱 Next steps:${NC}"
echo "1. Open Xcode and navigate to Assets.xcassets"
echo "2. Select AppIcon.appiconset"
echo "3. Drag and drop the appropriate icons from AppIcon-iOS/"
echo "4. Select AppIcon-Watch.appiconset"
echo "5. Drag and drop the appropriate icons from AppIcon-Watch/"
echo ""
echo -e "${BLUE}📖 Icon naming guide:${NC}"
echo "• icon-20@2x.png → 20pt 2x slot"
echo "• icon-29@3x.png → 29pt 3x slot"
echo "• icon-1024.png → App Store 1024pt slot"
echo ""
echo -e "${GREEN}✨ Your VitalSense app icons are ready!${NC}"