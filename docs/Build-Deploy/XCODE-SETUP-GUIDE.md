# 🚀 VitalSense Xcode Setup - Quick Reference

## ⚡ IMMEDIATE ACTIONS (Do This Now!)

### 1. CREATE XCODE PROJECT (5 minutes)
```
Xcode → Create new project → iOS App
- Product Name: VitalSense
- Bundle Identifier: dev.andernet.VitalSense  
- Language: Swift
- Interface: SwiftUI
- Include Tests: Yes
```

### 2. ADD YOUR VITALSENSE APP CODE (3 minutes)
1. **Delete** default `ContentView.swift` 
2. **Add New File** → Swift File → `VitalSenseApp.swift`
3. **Copy & Paste** the complete code from your `VitalSenseApp.swift` file
4. **Set as main app** in project settings

### 3. ADD HEALTH MANAGERS (2 minutes)  
1. **Drag** `HealthKitManager.swift` into project
2. **Drag** `GaitAnalyzer.swift` into project
3. **Ensure** both are added to main app target (checkboxes)

### 4. ADD REQUIRED FRAMEWORKS (2 minutes)
**Project Settings → Target → Frameworks:**
- ➕ `HealthKit.framework`
- ➕ `CoreMotion.framework` 
- ➕ `WatchConnectivity.framework`

### 5. CONFIGURE CAPABILITIES (3 minutes)
**Signing & Capabilities tab:**
- ➕ Add **HealthKit** capability
- ➕ Add **App Groups** capability
- **Group:** `group.dev.andernet.VitalSense`

### 6. SET UP PERMISSIONS (2 minutes)
1. **Add** `VitalSense.entitlements` to project
2. **Project Settings → Info → Custom iOS Target Properties:**
   - Set **Info.plist File:** to your Info.plist path
3. **Update Team ID** in build settings to your Apple Developer ID

## 🎯 VALIDATION COMMAND
```bash
./validate-app-store.sh
```
**Run this after each step to check progress!**

## ⌚ ADD APPLE WATCH (Optional - 5 minutes)
1. **File → New → Target → watchOS → Watch App**
2. **Target Name:** VitalSenseWatch  
3. **Replace** watch ContentView with `VitalSenseWatchApp.swift` code
4. **Add** same frameworks to watch target

## 🎨 CREATE APP ICON (10 minutes)
1. **Design** 1024x1024 PNG health icon
2. **Run:** `./generate-app-icons.sh your-icon-1024.png`  
3. **Drag** generated icons to `Assets.xcassets/AppIcon.appiconset`

## ✅ TEST ON DEVICE (Required!)
**HealthKit only works on physical devices**
1. **Connect** iPhone via USB
2. **Select** your iPhone as deployment target
3. **Build & Run** (Cmd+R)
4. **Grant** HealthKit permissions when prompted
5. **Test** gait analysis feature

## 🚀 DEPLOY TO TESTFLIGHT
```bash
./deploy-testflight.sh
```
Or manually: **Product → Archive → Distribute App**

---

## ⚠️ TROUBLESHOOTING

### Build Errors?
- **Check** all frameworks are added correctly
- **Verify** Bundle ID matches configuration
- **Update** Apple Developer Team ID
- **Run** `./validate-app-store.sh` for detailed diagnostics

### HealthKit Not Working?
- **Must use physical iPhone** (not simulator)
- **Check** entitlements file is added
- **Verify** Info.plist has usage descriptions
- **Grant permissions** in Settings → Privacy & Security → Health

### Apple Watch Issues?
- **Pair** Apple Watch with iPhone
- **Trust** developer on both devices  
- **Install** companion app manually if needed

---

## 🎉 SUCCESS INDICATORS

✅ **App builds without errors**
✅ **Runs on physical iPhone**  
✅ **HealthKit permissions appear**
✅ **Gait analysis can be started**
✅ **Apple Watch app installs (if added)**
✅ **No warnings in validation script**

**When all ✅ are complete → Ready for App Store submission!**

---

**🏥 Your VitalSense health app with advanced gait analysis is ready to help users monitor their health and assess fall risk!**