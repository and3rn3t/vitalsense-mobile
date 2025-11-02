#!/bin/bash

# Make all VitalSense scripts executable
chmod +x setup-xcode-project.sh
chmod +x generate-app-icons.sh  
chmod +x deploy-testflight.sh
chmod +x validate-app-store.sh
chmod +x preflight-xcode-finalization.sh

echo "✅ All scripts are now executable!"
echo ""
echo "🚀 Quick Start Commands:"
echo "./setup-xcode-project.sh      # Set up Xcode project structure"
echo "./generate-app-icons.sh       # Generate app icons from 1024x1024 source"
echo "./validate-app-store.sh       # Validate app store readiness"
echo "./deploy-testflight.sh        # Build and deploy to TestFlight"
echo ""
echo "📖 Read APP_STORE_CONNECT_GUIDE.md for complete submission guide"