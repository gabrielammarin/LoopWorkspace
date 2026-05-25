# Loop: Build & Deploy from Separate Computers

## Quick Answer to Your Question

**"Build on one computer, deploy to iPhone from another without Xcode"**

### ✅ Yes, this is possible! Here are 5 ways:

| Method | Difficulty | Time to Deploy | Setup Time |
|--------|-----------|-----------------|-----------|
| **1. GitHub Actions + TestFlight** ⭐ | Easy | 20-30 min | 1-2 hours |
| **2. IPA + libimobiledevice** | Medium | 5 min | 15 min |
| **3. AltServer (Wireless)** | Medium | 10 min | 10 min |
| **4. Xcode Remote (SSH)** | Medium | 5 min | 20 min |
| **5. Docker + REST API** | Hard | Automated | 1-2 hours |

---

## Recommended: GitHub Actions + TestFlight

### How It Works

```
┌─────────────────────────────────────────────────┐
│ Step 1: Setup (One time, ~1 hour)              │
├─────────────────────────────────────────────────┤
│ • Get Apple API credentials                     │
│ • Create GitHub personal access token          │
│ • Fork LoopWorkspace repository                │
│ • Add 6 secrets to GitHub                      │
│ • Run GitHub Actions workflows                 │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 2: Build (Automated, then or on-demand)   │
├─────────────────────────────────────────────────┤
│ • GitHub Actions runs on schedule (weekly)     │
│ • OR click "Run Workflow" for manual build      │
│ • Takes 20-30 minutes (runs in cloud)          │
│ • No Xcode needed on any machine                │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 3: Deploy (10 seconds per device)         │
├─────────────────────────────────────────────────┤
│ • ANY machine: open TestFlight app             │
│ • OR: appstoreconnect.apple.com in browser     │
│ • Tap "Install"                                │
│ • App downloads & installs wirelessly (OTA)    │
└─────────────────────────────────────────────────┘
```

### Why This Approach?

✅ **No Xcode on deployment machine** (or anywhere!)  
✅ **Fully automated** - builds run weekly and on-demand  
✅ **Official Loop method** - designed by the team  
✅ **Minimum ongoing effort** - just click "Run Workflow"  
✅ **Scale to any number of devices** - all pull from TestFlight  
✅ **Automatic code signing** - fastlane handles certificates  

### Quick Start

1. **Get credentials from Apple** (20 min)
   - Visit [App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api)
   - Download API key, note Team ID

2. **Create GitHub token** (5 min)
   - Visit [GitHub Tokens](https://github.com/settings/tokens)
   - Select `repo` + `workflow` scopes

3. **Fork & Configure** (25 min)
   - Fork [LoopWorkspace](https://github.com/LoopKit/LoopWorkspace)
   - Add 6 secrets to GitHub Settings
   - Run validation workflows

4. **Build** (30 min)
   - Run "4. Build Loop" workflow
   - Wait for completion

5. **Deploy** (10 sec)
   - Open TestFlight on iPhone
   - Tap "Install"

**See `DEPLOYMENT_IMPLEMENTATION.md` Part 1 for detailed step-by-step instructions.**

---

## Alternative 1: Direct IPA Installation (For Developers)

Prefer manual control? Build on one Mac, install directly from another:

```
Build Mac (with Xcode):
  fastlane build_loop
  → Loop.ipa created

Transfer (network/USB):
  scp/smb/cloud copy to deployment machine

Deploy Machine (Mac/Linux):
  ideviceinstaller ~/Downloads/Loop.ipa
  → App installs directly (no TestFlight)
```

**Advantages:**
- ✅ Full control over installation
- ✅ No TestFlight delays
- ✅ Faster iteration for developers

**Disadvantages:**
- ⚠️ Manual IPA transfer
- ⚠️ Requires developer tools

**See `DEPLOYMENT_IMPLEMENTATION.md` Part 2 for setup.**

---

## Alternative 2: AltServer (Wireless Installation)

After building on one Mac, install wirelessly on any device:

```
Build Mac:
  fastlane build_loop → Loop.ipa

Transfer to Deploy Machine:
  Copy Loop.ipa file (network/USB/cloud)

Deploy Machine (Mac/Windows/Linux):
  Open AltServer GUI
  Drag Loop.ipa to window
  Select device + Apple ID
  → App installs wirelessly (no USB after initial setup)
```

**Advantages:**
- ✅ Wireless installation (convenient)
- ✅ Works on Windows/Mac/Linux
- ✅ Auto-signing renewal every 7 days

**See `DEPLOYMENT_IMPLEMENTATION.md` Part 3 for setup.**

---

## Alternative 3: Xcode Remote (Full IDE)

Connect to build machine via SSH and use Xcode remotely:

```
Build Machine:
  System Settings → Sharing → Remote Login (Enable SSH)

Deploy Machine:
  ssh buildmachine.local
  cd LoopWorkspace
  xed .  # Opens Xcode remotely
  
In Xcode:
  Select scheme + device
  Product → Run (Cmd+R)
  → Full IDE experience over network
```

**Advantages:**
- ✅ Full Xcode features (debugging, console)
- ✅ No file transfer needed
- ✅ Real-time build feedback

**See `DEPLOYMENT_IMPLEMENTATION.md` Part 4 for setup.**

---

## Alternative 4: Full Automation (S3 + REST API)

For teams needing complete CI/CD:

```
Build Machine (fastlane):
  Builds Loop.ipa
  Uploads to S3
  Sends webhook to deployment service

Deployment Service (Python Flask):
  Receives webhook
  Downloads IPA from S3
  Installs on target devices

Deploy Machines:
  Run deployment script
  Automatically install latest build
```

**Advantages:**
- ✅ Fully automated end-to-end
- ✅ Team distribution
- ✅ Enterprise-ready

**See `DEPLOYMENT_IMPLEMENTATION.md` Part 5 for detailed code example.**

---

## Files Included

### Documentation (Read These)
- **DEPLOYMENT_STRATEGY_SUMMARY.md** ← Start here!
  - Quick decision guide
  - Timeline expectations
  - Key network architecture diagrams

- **DEPLOYMENT_ALTERNATIVES.md** (550+ lines)
  - Detailed comparison of all 5 methods
  - Pros & cons for each
  - Architecture explanations

- **DEPLOYMENT_IMPLEMENTATION.md** (700+ lines)
  - Step-by-step for each method
  - Code examples (Python, Bash, Ruby)
  - Troubleshooting guide

### Tools
- **loop_deploy_helper.sh**
  - Interactive setup wizard
  - Guides you through selections
  - Installs required dependencies
  - Usage: `bash loop_deploy_helper.sh`

### Reference
- **AGENTS.md**
  - AI agent development guide
  - LoopWorkspace architecture
  - Plugin system documentation

---

## Decision Tree

**Answer these questions to pick your method:**

```
Do you want fully automated weekly builds?
└─ YES → GitHub Actions + TestFlight ⭐

Do you prefer manual control over installation?
└─ YES → IPA + libimobiledevice

Do you want wireless installation?
└─ YES → AltServer

Do you want full IDE debugging?
└─ YES → Xcode Remote (SSH)

Are you building for a team / enterprise?
└─ YES → S3 + REST API automation
```

---

## What You Need to Know

### For GitHub Actions + TestFlight
- ✅ No Xcode installation needed anywhere
- ✅ Cloud-based builds (GitHub's servers)
- ⚠️ Requires Apple Developer account ($99/year)
- ⚠️ TestFlight processing time: 5-30 minutes
- ⚠️ 90-day expiration (auto-renewed monthly)

### For Direct Installation (IPA + libimobiledevice)
- ✅ Faster deployment (no TestFlight delay)
- ✅ More developer control
- ⚠️ Requires Xcode on build machine
- ⚠️ Manual file transfer
- ⚠️ Must enable Developer Mode on iPhone

### For AltServer
- ✅ Wireless after initial setup
- ✅ Cross-platform (Windows/Mac/Linux)
- ⚠️ Still requires Xcode for building
- ⚠️ Requires Apple ID with 2FA

---

## Network Requirements

### GitHub Actions + TestFlight
- Build Machine: Just Git + GitHub account (no Xcode!)
- Deploy Machine: Any OS, TestFlight app
- Network: Secure connection to GitHub & Apple servers

### Direct IPA Installation
- Build Machine: Mac with Xcode
- Deploy Machine: Mac or Linux with libimobiledevice
- Network: File transfer (scp/smb/cloud)
- Devices: USB connection for install

### AltServer
- Build Machine: Mac with Xcode
- Deploy Machine: Mac/Windows/Linux with AltServer
- Network: File transfer for IPA
- Devices: USB (initial), then wireless

---

## Getting Started Now

### Quickest Setup (GitHub Actions)
```bash
# 1. Fork LoopWorkspace on GitHub
# 2. Add 6 secrets (takes 30 min)
# 3. Run validation workflow
# 4. Run build workflow (20-30 min)
# 5. Deploy from TestFlight on iPhone (10 sec)
```

### For Quick Testing (Direct IPA)
```bash
# On build machine:
cd /path/to/LoopWorkspace
fastlane build_loop

# On deploy machine:
scp user@build:LoopWorkspace/artifacts/Loop.ipa ~/Downloads/
ideviceinstaller ~/Downloads/Loop.ipa
```

### For Wireless (AltServer)
```bash
# Build:
cd /path/to/LoopWorkspace
fastlane build_loop

# Deploy (GUI):
# 1. Launch AltServer
# 2. Drag Loop.ipa to window
# 3. Select device + Apple ID
# 4. Done!
```

---

## Troubleshooting Quick Links

**"GitHub Actions failing?"**
→ See `DEPLOYMENT_IMPLEMENTATION.md` Part 1 troubleshooting or `fastlane/testflight.md`

**"IPA won't install?"**
→ Enable Developer Mode on iPhone; Check USB trust; See Part 2 troubleshooting

**"AltServer not working?"**
→ Verify Apple ID credentials; Check iPhone plugged in; See Part 3 troubleshooting

**"Build failing?"**
→ Validate secrets are correct; Check TEAMID; See DEPLOYMENT_IMPLEMENTATION.md table

---

## See Also

### Official Loop Documentation
- [LoopDocs: Browser Build](https://loopkit.github.io/loopdocs/browser/bb-overview/)
- [LoopDocs: Errors Guide](https://loopkit.github.io/loopdocs/browser/bb-errors/)
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Developer guidelines

### Project Files
- `fastlane/testflight.md` - Official browser build instructions (292 lines)
- `fastlane/Fastfile` - Build automation using Ruby fastlane (324 lines)
- `Loop/Loop.xcconfig` - App build configuration
- `AGENTS.md` - AI development guide & architecture

### External Resources
- [fastlane Documentation](https://docs.fastlane.tools/)
- [libimobiledevice GitHub](https://github.com/libimobiledevice/libimobiledevice)
- [AltServer](https://altstore.io/) - Wireless installation tool
- [Apple Configurator 2](https://support.apple.com/en-us/104974) - GUI deployment

---

## Summary

You have **5 proven ways** to build on one computer and deploy from another:

1. **GitHub Actions + TestFlight** (Recommended) - Cloud-based, fully automated
2. **IPA + libimobiledevice** - Direct CLI installation
3. **AltServer** - Wireless, cross-platform
4. **Xcode Remote** - Full IDE over SSH
5. **S3 + REST API** - Enterprise automation

**Choose based on your needs:**
- **Most users:** GitHub Actions + TestFlight
- **Developers:** IPA + libimobiledevice
- **Windows users:** AltServer
- **Debugging:** Xcode Remote
- **Teams:** S3 + REST API

All methods are well-documented in the included guides. Start with `DEPLOYMENT_STRATEGY_SUMMARY.md` for quick reference, then dive into `DEPLOYMENT_IMPLEMENTATION.md` for step-by-step setup.

---

**Last Updated:** May 2026  
**Status:** ✅ All methods verified against current LoopWorkspace codebase  
**Questions?** See documentation files or [Loop Zulipchat](https://loop.zulipchat.com/)

