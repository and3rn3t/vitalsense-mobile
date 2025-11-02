#!/bin/bash

# Execute the complete VitalSense setup process
echo "🚀 Starting Complete VitalSense App Store Setup"
echo "=============================================="

# Make all scripts executable
echo "📋 Making scripts executable..."
chmod +x *.sh

echo "✅ All scripts are now executable"
echo ""

# Run screenshot generator
echo "📸 Running screenshot template generator..."
./create-screenshots.sh

echo ""
echo "🔧 Running project setup..."
./setup-xcode-project.sh

echo ""
echo "✅ Running final validation..."
./validate-app-store.sh

echo ""
echo "🎉 Setup Complete! Ready for next steps."