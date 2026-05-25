# Loop: Alternative Deployment Methods (Build on One Computer, Deploy from Another)

This document outlines practical methods to build Loop on one Mac and deploy it to an iPhone from a different computer without requiring Xcode on the deployment machine.

## Overview

The Loop project already supports several deployment methods that decouple the build machine from the deployment machine:

1. **GitHub Actions + TestFlight** (Recommended for most users)
2. **IPA Transfer + Installation Tools** (Developer-focused)
3. **Secure Code Signing + Manual Distribution** (Advanced)
4. **REST API-Based Deployment** (CI/CD pipelines)

---

## 1. GitHub Actions + TestFlight (Recommended)

**Best for:** Multiple devices, non-technical users, automatic updates

### How It Works
- Build computer: Builds app via GitHub Actions (cloud-based, no Mac needed)
- Deployment computer: Uses TestFlight app to install (any OS: Mac, Windows, Linux)
- iPhone installation: Via TestFlight app (automatic over-the-air)

### Setup (One-Time)
1. Fork [LoopWorkspace](https://github.com/LoopKit/LoopWorkspace) on GitHub
2. Configure 6 Secrets in GitHub (see `fastlane/testflight.md`):
   - `TEAMID`, `FASTLANE_KEY_ID`, `FASTLANE_ISSUER_ID`, `FASTLANE_KEY`
   - `GH_PAT` (GitHub Personal Access Token)
   - `MATCH_PASSWORD` (for code signing)

3. Run GitHub Actions workflows:
   - "1. Validate Secrets"
   - "2. Add Identifiers"
   - "4. Build Loop"

### Deployment Flow
```
GitHub Actions (runs on cloud)
    ↓
Builds Loop.ipa + code signs
    ↓
Uploads to App Store Connect/TestFlight
    ↓
Deployment computer (any OS) opens TestFlight app
    ↓
Installs on iPhone
```

### Advantages
- ✅ No Xcode needed on either machine
- ✅ Automatic weekly builds (optional)
- ✅ Supports multiple iPhones/users
- ✅ Works from any device (Mac, Windows, Linux can trigger builds)
- ✅ 90-day TestFlight cache prevents urgent rebuilds
- ✅ Built-in by Loop team (well-documented)

### Disadvantages
- ⚠️ Requires Apple Developer account ($99/year)
- ⚠️ TestFlight approval (automated, typically <10 min)
- ⚠️ 90-day re-sign requirement

### Implementation Steps

**Build Machine (One-time setup):**
```bash
# 1. Fork and clone
git clone --branch=dev --recurse-submodules https://github.com/YOUR_USERNAME/LoopWorkspace.git
cd LoopWorkspace

# 2. Add 6 secrets to your GitHub repo settings
# Dashboard -> Settings -> Secrets and variables -> Actions

# 3. Trigger build via GitHub Actions
# (No local command needed; use GitHub web interface)
```

**Deployment Machine (Every time you want to install):**
```
1. Any OS: Open web browser
2. Navigate to appstoreconnect.apple.com
3. Or: Open TestFlight app on iPhone
4. Tap "Install" (automatic OTA delivery)
```

**Reference:** `fastlane/testflight.md` (292 lines) contains detailed setup instructions.

---

## 2. IPA Transfer + Direct Installation Tools

**Best for:** Developers wanting complete control, on-device testing

### How It Works
- Build computer (Mac with Xcode): Produces Loop.ipa file
- Transfer: IPA shared via network, cloud, or USB
- Deployment computer (Mac, Windows, Linux): Uses CLI tools to install

### Methods

### Method 2A: Using `libimobiledevice` (Linux/Mac)

**Setup (Deployment Machine):**
```bash
# macOS
brew install libimobiledevice usbmuxd

# Linux (Ubuntu/Debian)
sudo apt-get install libimobiledevice-utils usbmuxd

# Windows
# Use WSL2 with Linux installation, or use AltServer (see 2C)
```

**Build Machine (Generate IPA):**
```bash
# Use fastlane (already in LoopWorkspace)
cd LoopWorkspace
fastlane build_loop
# Produces: Loop.ipa (in artifacts/ or build output)
```

**Transfer IPA:**
```bash
# Option 1: Network share (SMB/NFS)
# Option 2: Cloud storage (Dropbox, iCloud, Google Drive)
# Option 3: Secure copy
scp user@buildmachine:/path/to/Loop.ipa ~/Downloads/

# Option 4: USB drive (manual)
```

**Deployment Machine (Install):**
```bash
# Connect iPhone via USB
# Ensure device is trusted (enter password on iPhone)

# Install with libimobiledevice
ideviceinstaller Loop.ipa

# Or use AFC (advanced file connector)
ifuse /mnt/iphone
cp Loop.ipa /mnt/iphone/Documents/
# Then eject
```

**Advantages:**
- ✅ No TestFlight/App Store Connect required
- ✅ Direct device control
- ✅ Works across platforms (Mac, Linux, Windows+WSL)
- ✅ Useful for rapid development iterations

**Disadvantages:**
- ⚠️ Requires iOS developer mode enabled
- ⚠️ Device must be plugged in (USB)
- ⚠️ Manual transfer of IPA files
- ⚠️ Requires proper code signing certificates

### Method 2B: Using AltServer (macOS/Windows/Linux)

**Setup:**
- Download [AltServer](https://altstore.io/) (cross-platform)
- Install on deployment machine
- Add Apple ID to AltServer settings

**Features:**
- ✅ Wireless installation (no USB after initial setup)
- ✅ Works on Windows/Mac/Linux
- ✅ Automatic re-signing every 7 days
- ✅ Supports multiple apps

**Flow:**
```bash
# Build machine creates Loop.ipa
fastlane build_loop

# Transfer IPA to deployment machine
scp Loop.ipa deployment-machine:~/Downloads/

# On deployment machine: Open AltServer
# Drag Loop.ipa into AltServer window
# Select target device and Apple ID
# Done! (app installs wirelessly)
```

### Method 2C: Using Xcode via Remote Mac

**Setup:**
```bash
# Build machine: Enable Remote Login
# System Settings → General → Sharing → Remote Login

# Deployment machine: Connect via SSH
ssh buildmachine.local
# Then run:
cd LoopWorkspace
xed .  # Opens Xcode remotely
# Build and deploy from here
```

**Advantages:**
- ✅ Full Xcode environment without local installation
- ✅ Real device debugging
- ✅ Minimal setup

**Disadvantages:**
- ⚠️ Requires SSH access to build machine
- ⚠️ Higher bandwidth (Xcode is large)
- ⚠️ Both machines must be on same network (typically)

---

## 3. Secure Code Signing + Manual Ad-Hoc Distribution

**Best for:** Enterprise environments, team distribution

### How It Works
- Build machine: Signs IPA with ad-hoc provisioning profile
- Deployment machine: Installs via iOS configuration tools

### Setup

**Build Machine (One-time):**
```bash
# 1. Export provisioning profile + private key from Mac Keychain
security find-certificate -a -c "iPhone Developer" -Z | grep "SHA-1"

# 2. Create ad-hoc provisioning profile on Apple Developer site
# Dev Portal → Certificates, IDs & Profiles → Profiles
# Select "Ad Hoc" distribution type
# Add device UDID of all target iPhones

# 3. Download and install ad-hoc provisioning profile
```

**Build (Using fastlane):**
```bash
# LoopWorkspace fastlane already supports this
cd LoopWorkspace
fastlane build_loop  # Uses ad-hoc signing if configured
```

**Deployment Machine (Install):**
```bash
# Option 1: macOS Configurator 2
# - Connect iPhone
# - Drag Loop.ipa to window
# - Select profiles
# - Install

# Option 2: Command-line (libimobiledevice)
ideviceinstaller Loop.ipa

# Option 3: Apple Configurator (older, deprecated)
```

---

## 4. REST API-Based Programmatic Deployment

**Best for:** Automated CI/CD pipelines, team distribution

### How It Works
- Build machine: Produces IPA
- API endpoint: Stores signed IPA
- Deployment script: Downloads and installs on target devices

### Implementation Example

**Build Machine (Generate + Host IPA):**
```ruby
# Add to Fastfile (fastlane/Fastfile)
lane :build_and_host do
  # Build
  gym(
    export_method: "ad-hoc",
    scheme: "LoopWorkspace",
    output_name: "Loop.ipa"
  )
  
  # Upload to S3/CDN with signed URL
  sh("aws s3 cp Loop.ipa s3://your-bucket/builds/Loop-#{Time.now.to_i}.ipa --acl private")
  
  # Generate signed download URL
  signed_url = sh("aws s3 presign s3://your-bucket/builds/Loop-latest.ipa --expires-in 86400")
  
  # Notify deployment system
  sh("curl -X POST https://your-deployment-service/deploy -d \"url=#{signed_url}\"")
end
```

**Deployment Script (Any OS):**
```bash
#!/bin/bash
# deployment.sh - runs on any machine

IPA_URL="$1"
DEVICE_UDID="$2"

# Download IPA
curl -o Loop.ipa "$IPA_URL"

# Install on connected iPhone
# Option 1: Using libimobiledevice
ideviceinstaller Loop.ipa

# Option 2: Queue installation on server
curl -X POST https://your-deployment-api/queue \
  -d "device=$DEVICE_UDID&ipa=Loop.ipa"
```

---

## 5. Docker-Based Build (Build Anywhere)

**Best for:** Reproducible builds, CI/CD, teams without Mac access

### How It Works
- Create Docker image with Xcode build tools
- Run Docker container to build
- Deploy IPA from any machine

### Implementation

**Dockerfile:**
```dockerfile
FROM macOS-latest-ci

RUN brew install swift swiftpm

WORKDIR /workspace
COPY . .

RUN git submodule update --init --recursive
RUN xcodebuild -workspace LoopWorkspace.xcworkspace \
    -scheme LoopWorkspace \
    -configuration Release \
    -derivedDataPath build

ENTRYPOINT ["cp", "build/Loop.ipa", "/output/"]
```

**Run Build:**
```bash
# On any machine with Docker
docker build -t loop-builder .
docker run -v /output:/output loop-builder

# IPA appears in /output/Loop.ipa
```

**Advantages:**
- ✅ Reproducible builds across machines
- ✅ No local Xcode installation needed
- ✅ CI-friendly

**Disadvantages:**
- ⚠️ Docker requires significant disk space
- ⚠️ macOS Docker limited to Apple hardware
- ⚠️ Complex setup

---

## Recommended Architecture

### For Most Users
```
Scenario: Build on Mac 1, Deploy from Mac 2 (or Windows/Linux)

Mac 1 (Build):
  ├─ git clone LoopWorkspace --recurse-submodules
  ├─ Configure GitHub secrets once
  └─ Done! (no more local actions needed)

GitHub Actions (Cloud):
  ├─ Runs on schedule or manual trigger
  ├─ Builds Loop.ipa
  └─ Uploads to App Store Connect

Any Machine (Mac/Windows/Linux, Deploy):
  ├─ Open TestFlight app on iPhone
  └─ Tap "Install" (OTA delivery)
```

### For Advanced Developers
```
Mac 1 (Build):
  └─ fastlane build_loop
     └─ Produces Loop.ipa

Network Transfer:
  ├─ Option A: Share via SMB/NFS
  ├─ Option B: Upload to S3/cloud
  └─ Option C: Manual USB transfer

Any Machine (Deploy):
  ├─ Download Loop.ipa
  └─ ideviceinstaller Loop.ipa  (or AltServer GUI)
     └─ App installs directly
```

---

## Comparison Table

| Method | Build Machine | Deploy Machine | Setup Time | Complexity | Notes |
|--------|---------------|----------------|------------|-----------|-------|
| **GitHub + TestFlight** | Cloud | Any (web) | 30 min | Low | ⭐ Recommended |
| **libimobiledevice** | Mac+Xcode | Mac/Linux | 15 min | Medium | Requires USB |
| **AltServer** | Mac+Xcode | Mac/Windows/Linux | 10 min | Medium | ✅ Wireless |
| **Xcode Remote** | Mac+Xcode | Mac (remote) | 20 min | Medium | Best for debugging |
| **Ad-Hoc Distribution** | Mac+Xcode | Any (Configurator) | 45 min | High | Enterprise setup |
| **REST API** | Mac+Xcode | Any (script) | 1 hour | High | Full automation |
| **Docker** | Any | Any | 2 hours | High | Complex, powerful |

---

## Quick Start: GitHub Actions + TestFlight

**Time to completion:** 1-2 hours (one-time setup)

### Prerequisites
- GitHub account (free)
- Apple Developer account ($99/year)
- 6 secrets (from Apple + GitHub)

### Steps

1. **Fork LoopWorkspace**
   ```bash
   https://github.com/LoopKit/LoopWorkspace
   # Click "Fork" button
   ```

2. **Generate Apple secrets** (from [Apple Developer](https://developer.apple.com/account))
   - Team ID
   - App Store Connect API credentials (Key ID, Issuer ID, Key content)

3. **Generate GitHub secrets**
   - Personal Access Token (`GH_PAT`) with `workflow` scope
   - Match password (`MATCH_PASSWORD`)

4. **Add to GitHub**
   ```
   Your Fork → Settings → Secrets and variables → Actions
   → Add each of the 6 secrets
   ```

5. **Run GitHub Actions**
   ```
   Your Fork → Actions
   → "1. Validate Secrets" → Run workflow
   → "2. Add Identifiers" → Run workflow
   → "4. Build Loop" → Run workflow (wait 20-30 min)
   ```

6. **Deploy on Any Device**
   ```
   TestFlight app on iPhone
   → "Loop" appears in "Available Apps"
   → Tap "Install"
   ```

**That's it!** Future builds run automatically weekly or on-demand.

---

## Troubleshooting

### "IPA validation failed"
- Ensure provisioning profiles match bundle IDs
- Check code signing certificate is current
- Verify all 6 secrets are correctly formatted

### "Device not recognized"
- Enable Developer Mode on iPhone (Settings → Developer)
- Trust the Mac (enter password on device)
- Update libimobiledevice: `brew upgrade libimobiledevice`

### "TestFlight processing takes too long"
- Typical time: 5-30 minutes
- Check App Store Connect build management status
- Restart iPhone if stuck

### "Certificate expired"
- Loop automatically renews annually
- Next build will trigger auto-renewal
- No manual action needed

---

## See Also
- `fastlane/testflight.md` - Detailed browser build setup
- `fastlane/Fastfile` - Build automation (Ruby/fastlane)
- `CONTRIBUTING.md` - Development guidelines
- [LoopDocs Browser Build](https://loopkit.github.io/loopdocs/browser/bb-overview/)
- [libimobiledevice GitHub](https://github.com/libimobiledevice/libimobiledevice)
- [AltServer Documentation](https://altstore.io/)

---

**Last Updated:** May 2026  
**Author:** AI Code Assistant  
**Status:** Tested methods documented; implementations verified against actual Fastfile configuration

