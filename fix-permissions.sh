#!/bin/bash
# Quick permission fix for all VitalSense scripts
chmod +x *.sh 2>/dev/null || true
chmod +x ci_scripts/*.sh 2>/dev/null || true
echo "✅ All script permissions fixed! Run ./launch-vitalsense.sh to start"