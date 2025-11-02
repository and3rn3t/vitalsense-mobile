#!/bin/bash

# VitalSense Screenshot Template Generator
# Creates mockup templates for App Store screenshots

set -euo pipefail

echo "📸 VitalSense Screenshot Template Generator"
echo "==========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick not found${NC}"
    echo "Install ImageMagick to generate screenshot templates:"
    echo "  macOS: brew install imagemagick"
    echo "  Ubuntu: sudo apt-get install imagemagick"
    echo ""
    echo "💡 Alternative: Use Xcode Simulator to take screenshots manually"
    echo "   1. Run your app in iPhone 14 Pro Max simulator"
    echo "   2. Navigate to each screen"
    echo "   3. Press Cmd+S to save screenshot"
    echo "   4. Use same process for Apple Watch simulator"
    exit 1
fi

# Create directories
mkdir -p "Screenshots/iPhone-6.7"
mkdir -p "Screenshots/iPhone-6.5" 
mkdir -p "Screenshots/iPhone-5.5"
mkdir -p "Screenshots/AppleWatch-44mm"
mkdir -p "Screenshots/Templates"

echo -e "${BLUE}📱 Generating iPhone screenshot templates...${NC}"

# iPhone 6.7" (iPhone 14 Pro Max) - 1290x2796
create_iphone_template() {
    local filename="$1"
    local title="$2"
    local subtitle="$3"
    local width="$4"
    local height="$5"
    
    convert -size ${width}x${height} xc:white \
        -fill "#F2F2F7" -draw "rectangle 0,0 ${width},150" \
        -fill "#007AFF" -pointsize 48 -gravity north -annotate +0+50 "VitalSense" \
        -fill "#000000" -pointsize 36 -gravity center -annotate +0-200 "$title" \
        -fill "#666666" -pointsize 24 -gravity center -annotate +0-100 "$subtitle" \
        -fill "#34C759" -draw "circle $((width/2)),$((height/2+100)) $((width/2)),$((height/2-100))" \
        -fill "white" -pointsize 72 -gravity center -annotate +0+100 "❤️" \
        -fill "#007AFF" -draw "rectangle 50,$((height-200)) $((width-50)),$((height-50))" \
        -fill "white" -pointsize 32 -gravity center -annotate +0+$((height/2+200)) "Start Analysis" \
        "$filename"
}

# Generate iPhone templates
create_iphone_template "Screenshots/iPhone-6.7/01-dashboard.png" "Health Dashboard" "Your mobility overview" 1290 2796
create_iphone_template "Screenshots/iPhone-6.5/01-dashboard.png" "Health Dashboard" "Your mobility overview" 1242 2688  
create_iphone_template "Screenshots/iPhone-5.5/01-dashboard.png" "Health Dashboard" "Your mobility overview" 1242 2208

echo -e "${GREEN}✅ iPhone templates created${NC}"

# Apple Watch template (44mm) - 368x448
echo -e "${BLUE}⌚ Generating Apple Watch templates...${NC}"

convert -size 368x448 xc:black \
    -fill "#007AFF" -draw "circle 184,120 184,80" \
    -fill "white" -pointsize 24 -gravity center -annotate +0-100 "VitalSense" \
    -fill "#34C759" -pointsize 36 -gravity center -annotate +0-50 "78" \
    -fill "white" -pointsize 16 -gravity center -annotate +0-20 "Gait Score" \
    -fill "#FF9500" -pointsize 20 -gravity center -annotate +0+50 "82 BPM" \
    -fill "white" -pointsize 14 -gravity center -annotate +0+80 "Heart Rate" \
    "Screenshots/AppleWatch-44mm/01-main-app.png"

echo -e "${GREEN}✅ Apple Watch template created${NC}"

# Create screenshot guidelines
echo -e "${BLUE}📋 Creating screenshot guidelines...${NC}"

cat > "Screenshots/SCREENSHOT_GUIDE.md" << 'EOF'
# VitalSense App Store Screenshot Guide

## 📱 Required Screenshot Sizes

### iPhone Screenshots
- **6.7" Display (iPhone 14 Pro Max)**: 1290 × 2796 pixels
- **6.5" Display (iPhone 11 Pro Max, XS Max)**: 1242 × 2688 pixels  
- **5.5" Display (iPhone 8 Plus)**: 1242 × 2208 pixels

### Apple Watch Screenshots
- **Series 4+ (44mm)**: 368 × 448 pixels
- **Series 4+ (40mm)**: 324 × 394 pixels (optional)

## 🎯 Screenshot Content Requirements

### iPhone Screenshot 1: Main Dashboard
**Show:**
- App name/logo clearly visible
- Current health status/gait score
- "Start Analysis" or similar CTA button
- Clean, professional interface
- Apple Health integration indicator

### iPhone Screenshot 2: Gait Analysis
**Show:**
- Real-time motion analysis interface
- Walking pattern visualization
- Progress indicator
- "Keep phone in pocket" instruction
- Motion sensors active

### iPhone Screenshot 3: Results & Assessment
**Show:**
- Fall risk score with color coding
- Detailed gait metrics (speed, cadence, etc.)
- Trend charts or graphs
- Actionable recommendations
- Time period selector

### iPhone Screenshot 4: Apple Watch Integration
**Show:**
- iPhone displaying watch connection
- Side-by-side view of iPhone and Watch
- Data synchronization indicators
- Heart rate or other watch metrics
- "Paired" or "Connected" status

### iPhone Screenshot 5: Health Data
**Show:**
- Apple Health app integration
- Historical data trends
- Export/share options
- Privacy settings visible
- Healthcare provider sharing

### Apple Watch Screenshot 1: Main Interface
**Show:**
- VitalSense watch app main screen
- Current gait score or health metric
- Navigation crown usage hint
- Clear, readable text on small screen

### Apple Watch Screenshot 2: Workout Session
**Show:**
- Active gait monitoring session
- Real-time metrics (heart rate, time)
- "End Workout" button
- Digital Crown controls
- Complications visible

## 🎨 Design Guidelines

### Visual Style
- **Clean, medical aesthetic**
- **High contrast for readability**
- **Consistent color scheme (blues, greens)**
- **Professional typography**
- **Minimal distractions**

### Text Content
- **Large, readable fonts**
- **Clear metric labels**
- **Actionable button text**
- **Medical disclaimers where appropriate**
- **Apple Watch constraints considered**

### Status Bar
- **Show realistic signal/battery**
- **Use 9:41 AM time (Apple standard)**
- **Clean notification bar**
- **Carrier name generic (Carrier, Verizon, etc.)**

## 📸 Capture Methods

### Option 1: Xcode Simulator
1. Build app for iPhone 14 Pro Max simulator
2. Navigate to each required screen
3. Use Cmd+S to save screenshot
4. Repeat for other iPhone sizes
5. Use Watch simulator for watch screenshots

### Option 2: Physical Device
1. Use iPhone 14 Pro Max or similar
2. Connect to Mac and use QuickTime Player screen recording
3. Extract frames from recording
4. Use Apple Configurator 2 for screenshots

### Option 3: Design Tools
1. Use Figma, Sketch, or similar
2. Create mockups based on your actual UI
3. Export at exact required dimensions
4. Ensure realistic device bezels/frames

## ✅ Quality Checklist

### Before Uploading
- [ ] All text is readable at thumbnail size
- [ ] Screenshots show actual app functionality
- [ ] No placeholder or Lorem ipsum text
- [ ] Consistent visual style across all screenshots
- [ ] Apple Watch screenshots work independently
- [ ] Medical disclaimers visible where needed
- [ ] Privacy/health permissions shown appropriately
- [ ] Loading states avoided (show completed screens)
- [ ] Error states avoided
- [ ] Realistic data (not obviously fake numbers)

### App Store Optimization
- [ ] First screenshot is most compelling (dashboard)
- [ ] Screenshots tell a story in sequence
- [ ] Key features highlighted visually
- [ ] Apple Watch integration clearly shown
- [ ] Health benefits communicated clearly
- [ ] Professional medical aesthetic maintained

## 📱 Screenshot Naming Convention

```
01-dashboard-67.png          (iPhone 6.7")
01-dashboard-65.png          (iPhone 6.5") 
01-dashboard-55.png          (iPhone 5.5")
02-gait-analysis-67.png      (iPhone 6.7")
...
watch-01-main-44mm.png       (Apple Watch 44mm)
watch-02-workout-44mm.png    (Apple Watch 44mm)
```

Your screenshots are the first impression users have of VitalSense - make them count! 🎯
EOF

# Create a simple web viewer for reviewing screenshots
cat > "Screenshots/view-screenshots.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>VitalSense Screenshots Review</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; background: #f5f5f5; }
        .device-group { margin: 30px 0; padding: 20px; background: white; border-radius: 10px; }
        .screenshot { margin: 10px; display: inline-block; text-align: center; }
        .screenshot img { max-width: 200px; border: 1px solid #ddd; border-radius: 8px; }
        .screenshot p { margin-top: 10px; font-size: 14px; color: #666; }
        h2 { color: #007AFF; }
    </style>
</head>
<body>
    <h1>📱 VitalSense App Store Screenshots</h1>
    
    <div class="device-group">
        <h2>iPhone Screenshots</h2>
        <div class="screenshot">
            <img src="iPhone-6.7/01-dashboard.png" alt="Dashboard">
            <p>Main Dashboard</p>
        </div>
        <!-- Add more screenshots as you create them -->
    </div>
    
    <div class="device-group">
        <h2>Apple Watch Screenshots</h2>
        <div class="screenshot">
            <img src="AppleWatch-44mm/01-main-app.png" alt="Watch App">
            <p>Main Watch App</p>
        </div>
    </div>
    
    <p><strong>Note:</strong> Replace template screenshots with actual app screenshots before submission.</p>
</body>
</html>
EOF

echo -e "${GREEN}✅ Screenshot templates and guide created${NC}"

echo ""
echo -e "${BLUE}📋 Screenshot Package Created:${NC}"
echo "• Templates for all required iPhone sizes"
echo "• Apple Watch template"
echo "• Comprehensive screenshot guide"
echo "• HTML viewer for reviewing screenshots"

echo ""
echo -e "${YELLOW}🎯 Next Steps:${NC}"
echo "1. Replace templates with actual app screenshots"
echo "2. Use Xcode Simulator or physical device capture"
echo "3. Follow the guide in Screenshots/SCREENSHOT_GUIDE.md"
echo "4. Review with: open Screenshots/view-screenshots.html"

echo ""
echo -e "${GREEN}📸 Screenshot package ready!${NC}"