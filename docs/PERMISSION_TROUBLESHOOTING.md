# VitalSense Script Permission Troubleshooting

## 🔧 Quick Fix for Permission Issues

If you're getting permission denied errors when trying to run VitalSense scripts, here are the solutions:

### ⚡ Quick Fix (Recommended)

Run this single command to fix all permissions at once:

```bash
chmod +x *.sh && chmod +x ci_scripts/*.sh 2>/dev/null && echo "✅ All permissions fixed!"
```

### 🛠️ Step-by-Step Fix

1. **Make the permission fixer executable:**
   ```bash
   chmod +x fix-permissions.sh
   ```

2. **Run the permission fixer:**
   ```bash
   ./fix-permissions.sh
   ```

3. **Test the main launch script:**
   ```bash
   ./launch-vitalsense.sh
   ```

### 📋 Manual Permission Setting

If the automated fixes don't work, set permissions manually for each script:

```bash
# Core scripts
chmod +x launch-vitalsense.sh
chmod +x setup-project.sh
chmod +x setup-xcode-cloud.sh
chmod +x validate-xcode-cloud.sh
chmod +x cleanup-project.sh
chmod +x validate-app-store.sh
chmod +x setup-permissions.sh
chmod +x fix-permissions.sh

# CI scripts (if they exist)
chmod +x ci_scripts/ci_post_clone.sh
chmod +x ci_scripts/ci_pre_xcodebuild.sh
chmod +x ci_scripts/ci_post_xcodebuild.sh
```

### 🔍 Verify Permissions

Check that scripts are executable:

```bash
ls -la *.sh
```

You should see `-rwxr-xr-x` permissions (the `x` means executable).

### ❌ Common Permission Errors

**Error:** `permission denied: ./launch-vitalsense.sh`
**Solution:** Run `chmod +x launch-vitalsense.sh`

**Error:** `No such file or directory`
**Solution:** Make sure you're in the VitalSense project directory

**Error:** `command not found`
**Solution:** Use `./script-name.sh` not just `script-name.sh`

### 🚀 Quick Start After Fixing Permissions

Once permissions are fixed, start with:

```bash
./launch-vitalsense.sh
```

This will guide you through the complete VitalSense setup process.

### 📱 VitalSense Script Overview

After permissions are fixed, these scripts will be available:

- **`./launch-vitalsense.sh`** - Main setup guide and launcher
- **`./setup-project.sh`** - Generate core Swift files
- **`./setup-xcode-cloud.sh`** - Configure CI/CD automation
- **`./validate-xcode-cloud.sh`** - Verify Xcode Cloud setup
- **`./cleanup-project.sh`** - Remove duplicates and organize
- **`./validate-app-store.sh`** - Pre-submission validation

### 🏥 Health App Ready

Once permissions are working, VitalSense provides:

- Complete iOS health monitoring app
- Apple Watch companion app
- HealthKit integration with gait analysis
- Automated testing and deployment
- Privacy-compliant health data handling

### 💡 Pro Tip

Add this to your `.bashrc` or `.zshrc` to automatically fix permissions in any project:

```bash
alias fix-perms='chmod +x *.sh && chmod +x ci_scripts/*.sh 2>/dev/null'
```

Then just run `fix-perms` in any directory to fix script permissions.

---

**✅ Permission issues resolved? Run `./launch-vitalsense.sh` to start building your health app!**