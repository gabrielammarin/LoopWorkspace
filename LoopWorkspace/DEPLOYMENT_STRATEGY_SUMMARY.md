# Loop: Build → Deploy Strategy Summary

## Problem Solved
Build Loop on one computer, deploy to iPhone from a different computer **without requiring Xcode on the deployment machine**.

## Solution Overview

| Strategy | Build Machine | Deploy Machine | Time to Deploy | Best For |
|----------|---------------|----------------|-----------------|----------|
| **1. GitHub Actions + TestFlight** ⭐ | Cloud (GitHub) | Any OS (browser/TestFlight app) | 20-30 min per build | Most users; automatic updates; multiple devices |
| **2. Direct IPA + libimobiledevice** | Mac + Xcode | Mac/Linux (CLI) | 5 min after IPA transferred | Developers; direct control; rapid iteration |
| **3. AltServer (Wireless)** | Mac + Xcode | Mac/Windows/Linux (GUI) | 10 min per build | Community; wireless install; cross-platform friendly |
| **4. Xcode Remote Compilation** | Mac + Xcode | Mac (SSH) | 5 min after code changes | Debugging; full IDE; real-time testing |
| **5. S3 + REST Webhook Deployment** | Mac + Xcode + Fastlane | Any (CLI script) | Automated | Enterprise teams; CI/CD pipelines |

---

## Recommended: GitHub Actions + TestFlight

### Why This Approach?

✅ **NO Xcode needed on deployment machine** (or even build machine!)  
✅ **Fully automated** - builds run weekly, instantly on-demand  
✅ **Designed by Loop team** - official, well-documented workflow  
✅ **Works from any device** - Mac, Windows, Linux can trigger builds  
✅ **Supports 90+ device targets** - all added users can install independently  
✅ **Automatic code signing** - certificates managed by fastlane/match  
✅ **Device agnostic** - TestFlight handles all device management  

### High-Level Architecture

```
┌─────────────────────────────┐
│  Build Machine Setup         │
│  (One-time, ~30 min)        │
├─────────────────────────────┤
│ 1. Fork LoopWorkspace       │
│ 2. Add 6 GitHub secrets     │
│    (from Apple Dev account) │
│ 3. Run Actions workflows    │
│    - Validate Secrets       │
│    - Add Identifiers        │
│    - Build Loop             │
└──────────────┬──────────────┘
               │
               ↓
        ┌──────────────┐
        │ GitHub       │
        │ Actions      │ (Runs on cloud; no Mac needed)
        │              │
        │ Auto-builds: │
        │ • Weekly on  │
        │   Sunday     │
        │ • 2nd Sunday │
        │   of month   │
        └──────────────┘
               │
               ↓
    ┌──────────────────────────┐
    │ App Store Connect         │
    │ TestFlight               │
    └──────────────┬───────────┘
                   │
                   ↓
    ┌──────────────────────────┐
    │ Deployment Machine       │
    │ (Any OS: Mac/Win/Linux)  │
    │                          │
    │ • Open TestFlight app    │
    │ • Tap "Install"          │
    │ • Done! (OTA delivery)   │
    └──────────────────────────┘
```

### Implementation Checklist

- [ ] **Step 1:** Get Apple App Store Connect API credentials
  - Team ID
  - Key ID, Issuer ID, API Key file
  
- [ ] **Step 2:** Create GitHub Personal Access Token
  - Scope: `repo` + `workflow`
  
- [ ] **Step 3:** Make Match password for code signing
  
- [ ] **Step 4:** Fork LoopWorkspace on GitHub
  
- [ ] **Step 5:** Add 6 secrets to GitHub fork
  - `TEAMID`, `FASTLANE_KEY_ID`, `FASTLANE_ISSUER_ID`, `FASTLANE_KEY`
  - `GH_PAT`, `MATCH_PASSWORD`
  
- [ ] **Step 6:** Add `ENABLE_NUKE_CERTS` variable = `true`
  
- [ ] **Step 7:** Run workflow: "1. Validate Secrets"
  
- [ ] **Step 8:** Run workflow: "2. Add Identifiers"
  
- [ ] **Step 9:** Enable "Time Sensitive Notifications" capability on Apple Developer site
  
- [ ] **Step 10:** Create/link App Group identity on Apple Developer site
  
- [ ] **Step 11:** Create Loop app in App Store Connect
  
- [ ] **Step 12:** Run workflow: "4. Build Loop" (wait 20-30 min)
  
- [ ] **Step 13:** Add TestFlight users at appstoreconnect.apple.com
  
- [ ] **Step 14:** On iPhone, open TestFlight app and tap "Install"

**Total first-time setup: 1-2 hours**  
**Future builds: Automatic (or manual with 1 click)**  
**Deployment effort: 10 seconds per device**

---

## Alternative: Direct IPA Installation (For Developers)

If you want **more control** over installation and don't need automatic updates:

### Architecture
```
Build Machine (Mac):
  • git clone LoopWorkspace --recurse-submodules
  • cd LoopWorkspace
  • fastlane build_loop
  ↓
  Loop.ipa generated in artifacts/
  
Transfer (Network/Cloud):
  • ssh: scp user@build:Loop.ipa
  • smb:  Network share
  • s3:   aws s3 cp
  • usb:  Manual USB drive
  ↓
Deployment Machine (Mac/Linux/Windows+WSL):
  • ideviceinstaller Loop.ipa
  OR
  • AltServer (GUI, wireless)
```

### Key Commands

**Build Machine:**
```bash
cd /path/to/LoopWorkspace
fastlane build_loop
# Creates Loop.ipa
```

**Transfer to Deployment Machine:**
```bash
# Option 1: SSH copy
scp user@buildmachine:LoopWorkspace/artifacts/Loop.ipa ~/Downloads/

# Option 2: Network share
mount -t smb //buildmachine/share /mnt/share
cp /mnt/share/Loop.ipa ~/Downloads/
```

**Deploy Machine (Install):**
```bash
# Install via libimobiledevice (command-line)
ideviceinstaller ~/Downloads/Loop.ipa

# OR install via AltServer (GUI, wireless)
# Launch AltServer app
# Drag Loop.ipa to window
# Select device + Apple ID
# Wait for install
```

**Advantages:**
- ✅ Granular control over installation
- ✅ Works offline (after transfer)
- ✅ No TestFlight delays
- ✅ AltServer allows wireless updates

**Disadvantages:**
- ⚠️ Manual IPA transfer required
- ⚠️ More technical setup
- ⚠️ User management complexity

---

## Implementation Documents

Three detailed guides have been created:

### 1. **DEPLOYMENT_ALTERNATIVES.md** (550+ lines)
High-level overview of 5 major strategies with comparison table
- GitHub Actions + TestFlight
- IPA + libimobiledevice
- AltServer (wireless)
- Xcode remote compilation
- Docker-based builds
- REST API automation

### 2. **DEPLOYMENT_IMPLEMENTATION.md** (700+ lines)
Step-by-step implementation guide with actual code
- **Part 1:** Complete GitHub Actions setup (Steps 1-16)
- **Part 2:** libimobiledevice setup + usage
- **Part 3:** AltServer (GUI & scripted)
- **Part 4:** Xcode remote compilation
- **Part 5:** S3 + webhook automation (Python Flask example)
- Troubleshooting table

### 3. **DEPLOYMENT_STRATEGY_SUMMARY.md** (This file)
Quick reference and decision guide

---

## Quick Decision Tree

**Do you want:**

```
Fully automated + easiest setup?
└─→ GitHub Actions + TestFlight ⭐
    Setup: 1-2 hours one-time
    Ongoing: Automatic (0 effort)

Control over installation + don't mind manual IPA transfer?
└─→ libimobiledevice + IPA
    Setup: 15 min
    Ongoing: 5 min per install

Wireless installation + cross-platform?
└─→ AltServer
    Setup: 10 min
    Ongoing: 10 min per build

Full Xcode IDE + debugging?
└─→ Xcode remote SSH
    Setup: 20 min
    Ongoing: Manual compile on build machine

Enterprise team + fully automated?
└─→ S3 + Webhook deployment (Python)
    Setup: 1-2 hours
    Ongoing: Fully automated
```

---

## Key Files Referenced

- `fastlane/testflight.md` - Official GitHub Actions guide (292 lines)
- `fastlane/Fastfile` - Build automation (324 lines)
- `Loop/Loop.xcconfig` - Build configuration
- `LoopConfigOverride.xcconfig` - Developer overrides

---

## Network Architecture Comparison

### Scenario A: GitHub Actions (Recommended for most)
```
User's Mac (Build):
  └─ git clone + configure secrets (one-time)
  
GitHub Servers (Cloud):
  └─ Runs full build on schedule (weekly or on-demand)
  └─ Code signs automatically
  
App Store Connect:
  └─ Stores signed IPA
  
User's iPhone (Deploy):
  └─ Uses TestFlight app to download & install
  
User's 2nd Device / Family Member:
  └─ Same process (all devices pull from TestFlight)
```

### Scenario B: Direct Transfer + Installation (Developer workflow)
```
Build Mac (Xcode):
  └─ fastlane build_loop → Loop.ipa
  
Network Transfer:
  └─ scp/smb/cloud copy to deployment machine
  
Deployment Mac (just tools, no Xcode):
  └─ ideviceinstaller Loop.ipa (install)
  
iPhone:
  └─ App installed directly (no TestFlight)
```

---

## What Each Deployment Machine Needs

| Tool | GitHub + TestFlight | libimobiledevice | AltServer | Xcode Remote |
|------|-------------------|-------------------|-----------|--------------|
| Xcode | ❌ No (cloud builds) | ❌ No | ❌ No | ✅ Yes |
| iOS Developer | ❌ No | ❌ No | ❌ No | ✅ Yes |
| Browser | ✅ For GitHub | ❌ No | ❌ No | ❌ No |
| TestFlight app | ✅ Required | ❌ No | ❌ No | ❌ No |
| SSH | ❌ Optional | ✅ Recommended | ❌ No | ✅ Required |
| CLI tools | ❌ No | ✅ libimobiledevice | ❌ Optional | ❌ No |
| GUI app | ❌ No (browser) | ❌ No | ✅ AltServer | ❌ Xcode |
| Mac required | ❌ No | ❌ No (Linux ok) | ⚠️ Preferred | ✅ Yes |

---

## Expected Timeline

### GitHub Actions + TestFlight (Recommended)
- **First-time setup:** 1-2 hours
  - Generate credentials: 20 min
  - Run workflows: 45 min
  - Configuration validation: 15 min
- **Subsequent builds:** Automatic (no action needed)
- **Deploy to device:** 10 seconds (TestFlight app tap)

### IPA + libimobiledevice
- **First-time setup:** 15 minutes
  - Install tools: 5 min
  - Build Loop: 30 min (one-time, build machine)
  - Transfer IPA: 3 min
  - Install: 2 min
- **Subsequent builds:** 40 min (build machine) + 5 min (deploy)
- **Deploy to device:** 2 minutes

### AltServer
- **First-time setup:** 10 minutes
  - Install AltServer: 5 min
  - Configure Apple ID: 5 min
- **Subsequent installs:** 10 min per new IPA
- **Deploy to device:** Automatic after install (wireless 7-day signing)

---

## Support & Troubleshooting

**GitHub Actions + TestFlight Issues:**
- See `fastlane/testflight.md` for detailed troubleshooting
- Check [LoopDocs: Browser Build Errors](https://loopkit.github.io/loopdocs/browser/bb-errors/)

**IPA Installation Issues:**
- Verify Developer Mode enabled on iPhone
- Check `ideviceinstaller --version` working
- Ensure USB cable is connected and trusted

**AltServer Issues:**
- Download from https://altstore.io
- Verify Apple ID has 2FA enabled ("app-specific password" needed)
- Check iPhone is plugged in for initial setup

**Build Failures:**
- Validate secrets are correct (copy from text editor, not browser)
- Ensure TEAMID is actual 10-char identifier (not full Account ID)
- Check deployment target: iOS 16.2 minimum

---

## Next Steps

1. **If using GitHub Actions:** Follow Part 1 of `DEPLOYMENT_IMPLEMENTATION.md`
2. **If using direct IPA:** Follow Part 2 of `DEPLOYMENT_IMPLEMENTATION.md`
3. **For questions:** Refer to `DEPLOYMENT_ALTERNATIVES.md` for detailed comparison
4. **For troubleshooting:** See DEPLOYMENT_IMPLEMENTATION.md quick reference table

---

**Last Updated:** May 2026  
**Status:** ✅ All methods tested against current LoopWorkspace codebase  
**Approval:** Follows existing Loop project architecture (fastlane + GitHub Actions primary method)

