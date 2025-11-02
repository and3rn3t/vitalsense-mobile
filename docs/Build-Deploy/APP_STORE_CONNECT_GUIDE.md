# VitalSense App Store Connect Setup Guide

## 🍎 Apple Developer Account Requirements

### **Before You Start**
- [ ] **Active Apple Developer Program membership** ($99/year)
- [ ] **Two-factor authentication** enabled on Apple ID
- [ ] **Agreement, Tax, and Banking** completed in App Store Connect

## 📱 Creating Your App Record

### **Step 1: Create App in App Store Connect**
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **"My Apps"** → **"+"** → **"New App"**
3. Fill in app information:
   - **Platform**: iOS
   - **Name**: VitalSense
   - **Primary Language**: English
   - **Bundle ID**: `dev.andernet.VitalSense` (must match your Xcode config)
   - **SKU**: `vitalsense-health-app` (unique identifier)

### **Step 2: App Information**
- **Category**: Medical or Health & Fitness
- **Secondary Category**: Health & Fitness (optional)
- **Content Rights**: Check if your app uses third-party content

### **Step 3: Pricing and Availability**
- **Price**: Free (recommended for health apps)
- **Availability**: All countries (or select specific regions)
- **App Distribution**: App Store (not private distribution)

## 🔐 Code Signing & Certificates

### **Step 1: Create Certificates**
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Create certificates:
   - **iOS Distribution Certificate** (for App Store)
   - **Apple Development Certificate** (for testing)

### **Step 2: Register App IDs**
Create App IDs with these bundle identifiers:
- `dev.andernet.VitalSense` (main app)
- `dev.andernet.VitalSense.watchkitapp` (watch app)
- `dev.andernet.VitalSense.widgets` (widgets)

**Enable capabilities for main app:**
- [x] HealthKit
- [x] App Groups (`group.dev.andernet.VitalSense`)
- [x] Background Modes

### **Step 3: Provisioning Profiles**
Create App Store Distribution profiles for:
1. Main app (`dev.andernet.VitalSense`)
2. Watch app (`dev.andernet.VitalSense.watchkitapp`)
3. Widgets (`dev.andernet.VitalSense.widgets`)

## 📝 App Metadata

### **App Description Example**
```
VitalSense provides advanced gait analysis and fall risk assessment using your iPhone and Apple Watch. 

🏥 HEALTH MONITORING
• Real-time gait pattern analysis
• Fall risk prediction using machine learning
• Integration with Apple Health
• Comprehensive movement tracking

⌚ APPLE WATCH INTEGRATION  
• Independent workout tracking
• Heart rate monitoring during walks
• Seamless data synchronization
• Watch-based health complications

🔒 PRIVACY FIRST
• All health data stays on your device
• No data sharing without consent
• Full control over your health information
• HIPAA-compliant data handling

MEDICAL DISCLAIMER: This app is for informational purposes only and should not be used for medical diagnosis or treatment. Always consult with healthcare professionals.
```

### **Keywords** (100 characters max)
```
health,gait,walking,fall risk,apple watch,fitness,medical,rehabilitation
```

### **App Review Information**
- **Contact Information**: Your email and phone
- **Demo Account**: Not needed for health apps typically
- **Notes for Review**:
```
VitalSense is a health monitoring app that uses HealthKit and Core Motion APIs to analyze walking patterns and assess fall risk. The app:

1. Requests HealthKit permissions for gait-related data types
2. Uses Core Motion for real-time movement analysis  
3. Includes Apple Watch companion app for independent tracking
4. Does not diagnose medical conditions - provides informational data only
5. All processing is done on-device for privacy

Test with physical device - HealthKit requires real hardware.
```

## 🖼️ App Store Assets

### **App Icon Requirements**
- **Size**: 1024 × 1024 pixels
- **Format**: PNG (no transparency)
- **Design**: Health/medical theme, clear at small sizes

### **Screenshots Required**
**iPhone (6.7" Display)**:
1. Main dashboard with health metrics
2. Gait analysis in progress
3. Fall risk assessment results  
4. Apple Watch pairing/sync screen
5. Settings and permissions

**iPhone (6.5" Display)**: Same as above, resized
**iPhone (5.5" Display)**: Same as above, resized

**Apple Watch Series 4+ (44mm)**:
1. Watch face with complications
2. Main app interface
3. Workout session screen

### **App Preview Video** (Optional)
- **Duration**: 15-30 seconds
- **Content**: Show key features, gait analysis, watch integration
- **No sound required** (can include soundtrack)

## 🔒 Privacy Configuration

### **App Privacy Details in App Store Connect**
**Data Collection**: YES
- **Health and Fitness**: Collected for app functionality
- **Motion Activity**: Collected for gait analysis
- **Device ID**: Not collected
- **Usage Data**: Not collected

**Data Use**:
- **Purpose**: App functionality, analytics
- **Linked to User**: No
- **Used for Tracking**: No
- **Shared with Third Parties**: No

### **Privacy Policy** (Required)
Create a privacy policy covering:
- What health data is collected
- How data is used (gait analysis, fall risk assessment)
- Data retention and deletion policies
- User rights and controls
- Contact information

Host at: `https://yourdomain.com/privacy-policy`

## 📋 Health App Specific Requirements

### **Medical Disclaimers**
Include in app description and within app:
```
MEDICAL DISCLAIMER: This app is not intended to diagnose, treat, cure, or prevent any medical condition. The information provided is for educational purposes only. Always consult with qualified healthcare professionals before making medical decisions.
```

### **HealthKit Data Justification**
Be prepared to explain why each HealthKit data type is needed:
- **Step Count**: Basic gait analysis
- **Walking Speed**: Mobility assessment
- **Walking Steadiness**: Fall risk calculation
- **Heart Rate**: Activity intensity monitoring

### **Background Processing Justification**
Explain background modes usage:
- **Workout Processing**: Continuous gait monitoring during walks
- **Health Research**: Long-term mobility pattern analysis

## 🚀 Submission Checklist

### **Final Checks Before Submission**
- [ ] All certificates and profiles created
- [ ] App built with Release configuration
- [ ] All required screenshots uploaded
- [ ] App description written and reviewed
- [ ] Privacy policy published and linked
- [ ] App review information completed
- [ ] Medical disclaimers included
- [ ] HealthKit usage justified

### **Submission Process**
1. **Build and Upload**: Use Xcode Organizer or `deploy-testflight.sh`
2. **Processing Wait**: 30-90 minutes for processing
3. **Select Build**: Choose uploaded build in App Store Connect
4. **Complete Metadata**: Fill all required fields
5. **Submit for Review**: Click "Submit for Review"

### **Review Timeline**
- **Health Apps**: Typically 7-14 days (longer than average)
- **First Submission**: May take longer due to thorough review
- **Updates**: Usually faster (3-7 days)

## 📞 Support Resources

- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **HealthKit Guidelines**: Section 5.1.1 of Review Guidelines
- **Health App Best Practices**: WWDC sessions on HealthKit
- **Developer Forums**: https://developer.apple.com/forums/

## 🎯 Success Tips

1. **Test Thoroughly**: Use physical devices for all testing
2. **Clear Documentation**: Provide detailed review notes
3. **Medical Compliance**: Avoid diagnostic claims
4. **User Experience**: Smooth onboarding and permission flows
5. **Privacy First**: Be transparent about data usage

Your VitalSense health app is ready for the App Store! 🎉