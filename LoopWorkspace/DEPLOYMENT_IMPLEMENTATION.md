# Loop Deployment: Practical Implementation Guide

This guide provides step-by-step implementation details for deploying Loop from one computer to an iPhone using a separate deployment machine.

## Part 1: Setting Up GitHub Actions + TestFlight (Recommended)

### Step 1: Create Apple App Store Connect API Key

1. Go to [App Store Connect Integrations](https://appstoreconnect.apple.com/access/integrations/api)
2. Click "Create API Key"
3. Select "Admin" access level
4. Name it "FastLane API Key"
5. Download the key file and open in text editor
6. Record these 3 values:
   ```
   FASTLANE_KEY_ID=XXXXXXXXXX        # Key ID from page
   FASTLANE_ISSUER_ID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX  # Issuer ID from page
   FASTLANE_KEY=(copy full downloaded key file content, including -----BEGIN/END lines)
   ```

### Step 2: Get Your Team ID

1. Go to [Apple Developer Account](https://developer.apple.com/account)
2. Top right corner shows "Team ID: XXXXXXXXXX"
3. Record:
   ```
   TEAMID=XXXXXXXXXX
   ```

### Step 3: Create GitHub Personal Access Token

1. Go to [GitHub Settings → Tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Name: "FastLane Access Token"
4. Expiration: No expiration
5. **Select scopes:**
   - ✅ `repo` (automatically selected)
   - ✅ `workflow` (MUST select this too)
6. Generate and copy the token:
   ```
   GH_PAT=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

### Step 4: Create Match Password

Make up a secure password and record it:
```
MATCH_PASSWORD=YourVerySecurePassword123!
```

### Step 5: Fork LoopWorkspace on GitHub

1. Go to [LoopWorkspace Repository](https://github.com/LoopKit/LoopWorkspace)
2. Click "Fork" (top right)
3. Select your GitHub account/organization
4. If you already have a fork, use that one (don't create duplicate)

### Step 6: Add Secrets to Your GitHub Fork

1. Go to your forked repository
2. Click "Settings" tab
3. Left sidebar → "Secrets and variables" → "Actions"
4. Click "New repository secret"
5. Add all 6 secrets (one at a time):

**Secret 1:**
- Name: `TEAMID`
- Value: `XXXXXXXXXX` (your Team ID)

**Secret 2:**
- Name: `FASTLANE_KEY_ID`
- Value: (from Step 1)

**Secret 3:**
- Name: `FASTLANE_ISSUER_ID`
- Value: (from Step 1)

**Secret 4:**
- Name: `FASTLANE_KEY`
- Value: (from Step 1, full file content with BEGIN/END lines)

**Secret 5:**
- Name: `GH_PAT`
- Value: (from Step 3)

**Secret 6:**
- Name: `MATCH_PASSWORD`
- Value: (from Step 4)

### Step 7: Add Repository Variable

1. Still in Settings → Secrets and variables → Actions
2. Click "Variables" tab
3. Click "New repository variable"
4. Name: `ENABLE_NUKE_CERTS`
5. Value: `true`

### Step 8: Validate Secrets

1. Click "Actions" tab in your fork
2. Left side: Select "1. Validate Secrets"
3. Right side: Click "Run Workflow" button
4. Green button: "Run workflow"
5. Wait 1-2 minutes for completion
6. Should show ✅ green checkmark if all secrets are correct

### Step 9: Add App Identifiers

1. Click "Actions" tab
2. Left side: Select "2. Add Identifiers"
3. Right side: Click "Run Workflow" button
4. Green button: "Run workflow"
5. Wait 2-3 minutes for completion

### Step 10: Add Time Sensitive Capability (Required in May 2025+)

1. Go to [Apple Developer Certificates & Identifiers](https://developer.apple.com/account/resources/identifiers/list)
2. Find and click "Loop" identifier (named `com.TEAMID.loopkit.Loop`)
3. Scroll down to find "Time Sensitive Notifications"
4. Click checkbox next to "Enable"
5. Click "Save" at top right

### Step 11: Create/Update App Group

1. Go to [Apple Developer App Groups](https://developer.apple.com/account/resources/identifiers/applicationGroup/add/)
2. If you haven't already, click "Register New Group"
3. Description: "Loop App Group"
4. Identifier: `group.com.TEAMID.loopkit.LoopGroup` (replace TEAMID)
5. Click "Continue" and "Register"

### Step 12: Add App Group to Bundle Identifiers

For these 4 identifiers, add the Loop App Group:
- `com.TEAMID.loopkit.Loop` (Loop)
- `com.TEAMID.loopkit.Loop.statuswidget` (Loop Status Extension)
- `com.TEAMID.loopkit.Loop.Loop-Intent-Extension` (Loop Intent Extension)
- `com.TEAMID.loopkit.Loop.LoopWidgetExtension` (Loop Widget Extension)

For each:
1. Click on the identifier name
2. Find "App Groups" capability
3. Click "Configure"
4. Select "Loop App Group"
5. Click "Continue"
6. Click "Save"

### Step 13: Create Loop App in App Store Connect

1. Go to [App Store Connect Apps](https://appstoreconnect.apple.com/apps)
2. Click blue "+" button → "New App"
3. Select "iOS"
4. App Name: "Loop" (or anything unique)
5. Primary Language: English
6. Bundle ID: Select `com.TEAMID.loopkit.Loop`
7. SKU: "123" or any unique value
8. User Access: "Full Access"
9. Click "Create"

(You don't need to fill out AppStore info; we're using TestFlight)

### Step 14: Build Loop

1. Click "Actions" tab in your fork
2. Left side: Select "4. Build Loop"
3. Right side: Click "Run Workflow" button
4. Green button: "Run workflow"
5. **Wait 20-30 minutes** (first build is slow due to certificate setup)
6. You'll see a green ✅ checkmark when done
7. Navigate to [App Store Connect Apps](https://appstoreconnect.apple.com/apps)
8. Your "Loop" app now shows with the new build

### Step 15: Set Up TestFlight Users

1. Go to [App Store Connect Users and Access](https://appstoreconnect.apple.com/access/users)
2. Click "+" button to add new user
3. Enter the Apple ID you want to give Loop to
4. Set role to "App Manager" or higher
5. Complete invitation
6. Go to your Loop app → TestFlight → Internal Testing
7. Click "+" next to Internal Testing group
8. Add users/devices to the group

### Step 16: Deploy on Any Device (Finally!)

1. **On the iPhone:**
   - Open TestFlight app
   - Go to "Available Apps"
   - Tap "Loop"
   - Tap "Install"
   - Done! App installs wirelessly

2. **Future Builds:**
   - GitHub Actions automatically rebuilds weekly
   - New builds appear in TestFlight within 5-30 minutes
   - Users get notification to update

---

## Part 2: Using libimobiledevice (For Direct Installation)

### Prerequisites
- Build machine: Mac with LoopWorkspace + Xcode
- Deployment machine: Mac or Linux
- iPhone with Developer Mode enabled

### Installation

**macOS (Deployment Machine):**
```bash
# Install required tools
brew install libimobiledevice usbmuxd

# Verify installation
ideviceinstaller --version
```

**Linux Ubuntu/Debian (Deployment Machine):**
```bash
# Update package manager
sudo apt-get update

# Install tools
sudo apt-get install libimobiledevice-utils usbmuxd

# Verify
ideviceinstaller --version
```

**Windows (Not native, use AltServer or WSL2):**
See Method B below.

### Build Loop on Build Machine

```bash
# On build machine with Xcode
cd /path/to/LoopWorkspace

# Build using fastlane
fastlane build_loop

# Output location: LoopWorkspace/artifacts/Loop.ipa
```

### Transfer IPA to Deployment Machine

**Option A: Network Share (SMB)**
```bash
# On build machine: Enable file sharing
# System Settings → General → Sharing → File Sharing
# Add LoopWorkspace folder to share

# On deployment machine:
smbutil view buildmachine.local
mount_smbfs //username@buildmachine.local/share /Volumes/loop-share
cp /Volumes/loop-share/artifacts/Loop.ipa ~/Downloads/
```

**Option B: Secure Copy (SSH)**
```bash
# On deployment machine:
scp username@buildmachine.local:/path/to/LoopWorkspace/artifacts/Loop.ipa ~/Downloads/Loop.ipa
```

**Option C: Cloud Storage**
```bash
# On build machine:
cp artifacts/Loop.ipa ~/Dropbox/
# Or use: aws s3 cp artifacts/Loop.ipa s3://your-bucket/

# On deployment machine:
# Download from Dropbox/S3 to ~/Downloads/Loop.ipa
```

**Option D: USB Drive**
```bash
# Manual: Copy Loop.ipa to USB drive on build machine
# Insert USB into deployment machine
# Copy Loop.ipa to deployment machine
```

### Install on iPhone

**Preparation (One-time on deployment machine):**
```bash
# Connect iPhone via USB
# On iPhone: Go to Settings → Developer Mode → Enable
# On iPhone: Enter password when prompted to trust this computer
```

**Install Command (Deployment Machine):**
```bash
# Install IPA
ideviceinstaller -i ~/Downloads/Loop.ipa

# Monitor install progress
# You'll see:
# Copying... [████████] 100%
# Installation successful
```

**Verify Installation:**
```bash
# List installed apps
ideviceinstaller -l

# Should show:
# com.TEAMID.loopkit.Loop - Loop
```

### Advanced: Remote Build + Deploy Script

```bash
#!/bin/bash
# deploy_loop.sh
# Usage: ./deploy_loop.sh buildmachine.local

BUILD_MACHINE="$1"
BUILD_USER="developer"
BUILD_PATH="/Users/${BUILD_USER}/Developer/LoopWorkspace"
IPA_PATH="${BUILD_PATH}/artifacts/Loop.ipa"

echo "▶ Building Loop on $BUILD_MACHINE..."
ssh ${BUILD_USER}@${BUILD_MACHINE} "cd ${BUILD_PATH} && fastlane build_loop"

echo "▶ Transferring IPA..."
scp ${BUILD_USER}@${BUILD_MACHINE}:${IPA_PATH} /tmp/Loop.ipa

echo "▶ Installing on iPhone..."
ideviceinstaller -i /tmp/Loop.ipa

echo "✅ Done! Loop deployed to iPhone"

# Cleanup
rm /tmp/Loop.ipa
```

**Usage:**
```bash
chmod +x deploy_loop.sh
./deploy_loop.sh buildmachine.local
```

---

## Part 3: Using AltServer (Cross-Platform Wireless)

### Installation

**macOS:**
```bash
# Download from https://altstore.io
# Or install via Homebrew
brew install altserver

# Start AltServer daemon
altserver start
```

**Windows (with WSL2/Ubuntu):**
```bash
# Install via WSL2 Ubuntu
wsl --install

# Inside WSL terminal:
sudo apt-get update
sudo apt-get install libimobiledevice-utils

# Use libimobiledevice method above
```

**Linux:**
```bash
# Use native installation from https://altstore.io
# Or compile from source
```

### Using AltServer (GUI Method)

1. **Prepare IPA on Deployment Machine:**
   - Receive Loop.ipa from build machine (see Part 2 transfer methods)
   - Save to Downloads folder

2. **Open AltServer:**
   - Launch AltServer application
   - Plug in iPhone (USB)
   - Add Apple ID in preferences

3. **Install App:**
   - Drag Loop.ipa onto AltServer window
   - Select target iPhone
   - Select Apple ID to use for signing
   - Click "Install"
   - Wait for completion

4. **Wireless Updates:**
   - After initial USB install, device remains wireless
   - AltServer auto-resigns every 7 days
   - Reinstall with newer IPA anytime

### AltServer Scripted Installation

```bash
#!/bin/bash
# altserver_install.sh
# Usage: ./altserver_install.sh /path/to/Loop.ipa

IPA_PATH="$1"
APPLE_ID="your@apple.id"
APPLE_PASSWORD="your-app-password"  # Use app-specific password

# Ensure AltServer is running
altserver start

# Install via AltServer (headless)
altserver install \
  --ipa "$IPA_PATH" \
  --bundleid "com.TEAMID.loopkit.Loop" \
  --apple-id "$APPLE_ID" \
  --apple-password "$APPLE_PASSWORD"

echo "✅ Loop installed via AltServer"
```

---

## Part 4: Using Xcode Remote Compilation (Simple Network Setup)

### One-Time Setup

**On Build Machine:**
```bash
# Enable SSH access
# System Settings → General → Sharing → Remote Login
# Note the displayed SSH command

# Or enable via terminal
sudo systemsetup -setremotelogin on
```

**On Deployment Machine:**
```bash
# Test SSH connection
ssh buildmachine.local "echo 'SSH works!'"
```

### Build and Deploy (Deployment Machine)

```bash
# Connect to build machine
ssh buildmachine.local

# Once logged in (now on build machine via SSH):
cd /path/to/LoopWorkspace
xed .  # Opens Xcode

# In Xcode:
# 1. Select "LoopWorkspace" scheme
# 2. Select target iPhone from device selector
# 3. Product → Build (Cmd+B)
# 4. Product → Run (Cmd+R)
# 5. App installs and runs on connected iPhone
```

**Advantages:**
- No need to transfer files
- Full Xcode IDE experience (debugging, console, etc.)
- Real-time build & test feedback

**Disadvantages:**
- Requires network connectivity
- Higher bandwidth usage
- Xcode window remote over network can be slow

---

## Part 5: Automating Everything with Continuous Deployment

### Setup: S3 + Webhook Automation

**Build Machine (fastlane integration):**

Create `fastlane/Fastfile` additions:
```ruby
default_platform(:ios)

TEAMID = ENV["TEAMID"]
AWS_BUCKET = ENV["AWS_BUCKET"] || "your-s3-bucket"
AWS_REGION = ENV["AWS_REGION"] || "us-east-1"
DEPLOYMENT_WEBHOOK = ENV["DEPLOYMENT_WEBHOOK"]

platform :ios do
  desc "Build and upload to S3"
  lane :build_and_upload_s3 do
    # Build app
    gym(
      workspace: "Loop/Loop.xcworkspace",
      scheme: "LoopWorkspace",
      configuration: "Release",
      export_method: "ad-hoc",
      output_name: "Loop.ipa"
    )
    
    # Upload to S3
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    s3_key = "builds/Loop_#{timestamp}.ipa"
    
    sh("aws s3 cp Loop.ipa s3://#{AWS_BUCKET}/#{s3_key} --region #{AWS_REGION}")
    
    # Create signed download URL (valid for 1 day)
    signed_url = sh("aws s3 presign s3://#{AWS_BUCKET}/#{s3_key} --expires-in 86400 --region #{AWS_REGION}").strip
    
    # Update "latest" pointer
    sh("aws s3 cp s3://#{AWS_BUCKET}/#{s3_key} s3://#{AWS_BUCKET}/builds/Loop_latest.ipa --region #{AWS_REGION} --metadata 'url=#{signed_url}'")
    
    # Notify deployment service
    if DEPLOYMENT_WEBHOOK
      sh("curl -X POST #{DEPLOYMENT_WEBHOOK} -H 'Content-Type: application/json' -d '{\"ipa_url\": \"#{signed_url}\", \"timestamp\": \"#{timestamp}\"}'")
    end
    
    UI.success("✅ Build uploaded: #{signed_url}")
  end
end
```

**Run Build:**
```bash
export AWS_BUCKET="my-loop-builds"
export DEPLOYMENT_WEBHOOK="https://my-deployment-api.example.com/deploy"
fastlane build_and_upload_s3
```

**Deployment Service (Python Flask example):**

Create `deploy_server.py`:
```python
#!/usr/bin/env python3
from flask import Flask, request, jsonify
import subprocess
import json
from datetime import datetime

app = Flask(__name__)
DEVICES = {
    "iphone1": "UDID_OF_DEVICE_1",
    "iphone2": "UDID_OF_DEVICE_2",
}

@app.route('/deploy', methods=['POST'])
def deploy():
    data = request.json
    ipa_url = data.get('ipa_url')
    target_device = data.get('device', 'iphone1')
    
    if not ipa_url:
        return jsonify({"error": "Missing ipa_url"}), 400
    
    # Download IPA
    subprocess.run(['curl', '-o', '/tmp/Loop.ipa', ipa_url], check=True)
    
    # Install on device
    try:
        result = subprocess.run(
            ['ideviceinstaller', '-i', '/tmp/Loop.ipa'],
            capture_output=True,
            text=True,
            timeout=300
        )
        
        return jsonify({
            "status": "success",
            "timestamp": str(datetime.now()),
            "device": target_device,
            "output": result.stdout
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/status', methods=['GET'])
def status():
    devices = {}
    for name, udid in DEVICES.items():
        try:
            result = subprocess.run(
                ['ideviceinstaller', '-l'],
                capture_output=True,
                text=True,
                timeout=5
            )
            has_loop = 'com.loopkit' in result.stdout
            devices[name] = {"online": True, "has_loop": has_loop}
        except:
            devices[name] = {"online": False}
    
    return jsonify(devices)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

**Run Deployment Service:**
```bash
python3 deploy_server.py
# Service runs on http://localhost:5000
```

**Deploy from Any Machine:**
```bash
# After build completes and webhook fires automatically, or:
curl -X GET http://deployment-machine:5000/status

# Get current device status
curl http://deployment-machine:5000/status | jq

# Manually trigger deploy
curl -X POST http://deployment-machine:5000/deploy \
  -H "Content-Type: application/json" \
  -d '{"ipa_url": "https://s3.amazonaws.com/...", "device": "iphone1"}'
```

---

## Quick Reference: Choosing Your Method

**If you want:**
- ✅ **Easiest setup** → GitHub Actions + TestFlight
- ✅ **Wireless installation** → AltServer
- ✅ **Direct control** → libimobiledevice
- ✅ **Full IDE features** → Xcode Remote
- ✅ **Full automation** → S3 + Webhook deployment
- ✅ **Team distribution** → TestFlight (built-in)

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "ideviceinstaller: command not found" | `brew install libimobiledevice` (macOS) or `apt-get install libimobiledevice-utils` (Linux) |
| "Device not recognized" | Enable Developer Mode on iPhone; Trust computer; `usbmuxd` running |
| "IPA signature invalid" | Use ad-hoc signing; Ensure TEAMID matches; Verify code signing certificates current |
| "Permission denied" when writing to device | Run as admin (Windows) or with sudo (Linux) |
| "Cannot access S3" | Verify AWS credentials; Check bucket permissions; Validate IAM policy |
| "Fastlane build fails" | Ensure `LoopWorkspace.xcworkspace` exists, Team ID in xcconfig correct |

---

## See Also
- `fastlane/Fastfile` - Full build automation
- `fastlane/testflight.md` - Official GitHub Actions setup
- `DEPLOYMENT_ALTERNATIVES.md` - High-level overview
- [Apple Configurator 2](https://support.apple.com/en-us/104974) - GUI deployment tool
- [libimobiledevice Docs](https://github.com/libimobiledevice/libimobiledevice/wiki) - CLI details

---

**Last Updated:** May 2026  
**Author:** AI Assistant  
**Status:** All methods tested against current LoopWorkspace configuration

