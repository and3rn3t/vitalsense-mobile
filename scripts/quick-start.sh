#!/bin/bash

# Run this first to make all scripts executable and start setup
echo "🚀 VitalSense App Store Preparation - Quick Start"
echo "================================================="

# Make scripts executable
chmod +x *.sh 2>/dev/null

echo "✅ Scripts are now executable"
echo ""
echo "🔧 Running project setup..."
echo ""

# Run the setup script
./setup-xcode-project.sh

echo ""
echo "✅ Setup complete! Next run: ./validate-app-store.sh"