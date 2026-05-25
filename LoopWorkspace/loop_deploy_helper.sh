#!/bin/bash
# Loop Deployment Helper Script
# Provides interactive setup and deployment for various strategies
# Usage: bash loop_deploy_helper.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Main menu
show_menu() {
    print_header "Loop Deployment Options"
    echo "Choose your deployment strategy:"
    echo ""
    echo "  1) GitHub Actions + TestFlight (Recommended)"
    echo "     • Cloud-based build"
    echo "     • No Xcode on deployment machine"
    echo "     • Automatic weekly builds"
    echo ""
    echo "  2) Direct IPA + libimobiledevice"
    echo "     • Local build with fastlane"
    echo "     • Manual installation via CLI"
    echo "     • Requires developer tools"
    echo ""
    echo "  3) AltServer (Wireless Installation)"
    echo "     • Local build with fastlane"
    echo "     • Wireless OTA installation"
    echo "     • Cross-platform support"
    echo ""
    echo "  4) Xcode Remote Compilation (SSH)"
    echo "     • Full IDE over network"
    echo "     • Debugging support"
    echo "     • Real-time build feedback"
    echo ""
    echo "  5) View Documentation"
    echo "     • Show available guides"
    echo ""
    echo "  0) Exit"
    echo ""
    read -p "Enter your choice [0-5]: " choice
}

# Method 1: GitHub Actions
setup_github_actions() {
    print_header "Setting Up GitHub Actions + TestFlight"

    print_info "This will guide you through the one-time setup process"
    print_info "Total time: 1-2 hours (mostly waiting for GitHub Actions)"

    echo ""
    read -p "Ready to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi

    echo ""
    print_header "Prerequisites Check"

    # Check for GitHub account
    read -p "Do you have a GitHub account? (y/n) " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Please create one at https://github.com/signup"
        return
    fi
    echo ""

    # Check for Apple Developer account
    read -p "Do you have a paid Apple Developer account? (y/n) " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Please sign up at https://developer.apple.com"
        return
    fi
    echo ""

    print_success "Prerequisites met!"

    echo ""
    print_header "Step 1: Generate Apple API Credentials"
    echo "Visit: https://appstoreconnect.apple.com/access/integrations/api"
    echo ""
    echo "Record these values:"
    echo "  • Team ID (from Apple Developer Account top right)"
    echo "  • Key ID"
    echo "  • Issuer ID"
    echo "  • API Key file (full content)"
    echo ""
    read -p "Press Enter once you have saved these values..."

    echo ""
    print_header "Step 2: Create GitHub Personal Access Token"
    echo "Visit: https://github.com/settings/tokens/new"
    echo ""
    echo "Create token with:"
    echo "  • Name: 'FastLane Access Token'"
    echo "  • Expiration: 'No expiration'"
    echo "  • Scopes: ✅ repo, ✅ workflow"
    echo ""
    read -p "Press Enter once you have saved your token..."

    echo ""
    print_header "Step 3: Create Match Password"
    echo "This secures your code signing certificates"
    echo ""
    read -sp "Enter a secure password: " match_password
    echo ""

    echo ""
    print_header "Step 4: Fork LoopWorkspace"
    echo "Visit: https://github.com/LoopKit/LoopWorkspace"
    echo "Click the 'Fork' button"
    echo ""
    read -p "Press Enter once you have forked the repository..."

    echo ""
    print_header "Step 5: Add Secrets to GitHub"
    echo "Go to your forked repository"
    echo "Settings → Secrets and variables → Actions"
    echo ""
    echo "Add these secrets:"
    echo "  1. TEAMID"
    echo "  2. FASTLANE_KEY_ID"
    echo "  3. FASTLANE_ISSUER_ID"
    echo "  4. FASTLANE_KEY (full file content)"
    echo "  5. GH_PAT (your personal access token)"
    echo "  6. MATCH_PASSWORD (password from Step 3)"
    echo ""
    read -p "Press Enter once you have added all secrets..."

    echo ""
    print_header "Step 6: Add Variables"
    echo "Go to your forked repository"
    echo "Settings → Secrets and variables → Actions → Variables tab"
    echo ""
    echo "Create variable:"
    echo "  • Name: ENABLE_NUKE_CERTS"
    echo "  • Value: true"
    echo ""
    read -p "Press Enter once you have added the variable..."

    echo ""
    print_header "Step 7: Validate Secrets"
    echo "Go to: Your Fork → Actions tab → '1. Validate Secrets'"
    echo "Click 'Run Workflow' button"
    echo ""
    echo "This will verify all your secrets are correct"
    echo "Expected time: 1-2 minutes"
    echo ""
    read -p "Press Enter once the workflow completes with ✅..."

    echo ""
    print_header "Step 8: Add Identifiers"
    echo "Go to: Your Fork → Actions tab → '2. Add Identifiers'"
    echo "Click 'Run Workflow' button"
    echo ""
    echo "Expected time: 2-3 minutes"
    echo ""
    read -p "Press Enter once the workflow completes with ✅..."

    echo ""
    print_header "Step 9: Configure App Identifiers"
    echo "Go to: https://developer.apple.com/account/resources/identifiers/list"
    echo ""
    echo "For each identifier, add 'App Groups' capability:"
    echo "  1. Loop (com.TEAMID.loopkit.Loop)"
    echo "     - Also enable 'Time Sensitive Notifications'"
    echo "  2. Loop Intent Extension"
    echo "  3. Loop Status Extension"
    echo "  4. Loop Widget Extension"
    echo ""
    read -p "Press Enter once you have configured all identifiers..."

    echo ""
    print_header "Step 10: Create App in App Store Connect"
    echo "Go to: https://appstoreconnect.apple.com/apps"
    echo "Click blue '+' → New App"
    echo ""
    echo "Values:"
    echo "  • Platform: iOS"
    echo "  • Name: Loop"
    echo "  • Bundle ID: com.TEAMID.loopkit.Loop"
    echo "  • SKU: 123"
    echo "  • Access: Full Access"
    echo ""
    read -p "Press Enter once your app is created..."

    echo ""
    print_header "Step 11: Build Loop"
    echo "Go to: Your Fork → Actions tab → '4. Build Loop'"
    echo "Click 'Run Workflow' button"
    echo ""
    echo "⏳ This takes 20-30 minutes..."
    echo "Go get a coffee! ☕"
    echo ""
    read -p "Press Enter once the workflow completes with ✅..."

    echo ""
    print_header "Step 12: Deploy to iPhone"
    echo ""
    echo "🎉 You're done with setup!"
    echo ""
    echo "To deploy Loop to your iPhone:"
    echo "  1. Open TestFlight app on iPhone"
    echo "  2. Go to 'Available Apps'"
    echo "  3. Tap 'Install' next to Loop"
    echo ""
    echo "To deploy to other devices:"
    echo "  1. Add users at: https://appstoreconnect.apple.com/access/users"
    echo "  2. Add to TestFlight Internal Testing group"
    echo "  3. They receive invitation via their Apple ID"
    echo "  4. They install via TestFlight"
    echo ""
    print_success "GitHub Actions setup complete!"
}

# Method 2: IPA + libimobiledevice
setup_ideviceinstaller() {
    print_header "Setting Up IPA + libimobiledevice"

    echo ""
    print_info "Build Machine: Mac with Xcode (creates Loop.ipa)"
    print_info "Deploy Machine: Mac or Linux (installs app)"

    echo ""
    read -p "Press Enter to begin installation..."

    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="linux"
        distro=$(lsb_release -si 2>/dev/null || echo "linux")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
    else
        print_error "Unsupported OS. Use macOS or Linux."
        return
    fi

    print_header "Installing libimobiledevice"

    if [[ "$OS_TYPE" == "macos" ]]; then
        print_info "Installing via Homebrew..."
        brew install libimobiledevice usbmuxd
        print_success "Installed: libimobiledevice, usbmuxd"
    else
        print_info "Installing via apt-get..."
        sudo apt-get update
        sudo apt-get install -y libimobiledevice-utils usbmuxd
        print_success "Installed: libimobiledevice-utils, usbmuxd"
    fi

    echo ""
    print_header "Verifying Installation"
    if command -v ideviceinstaller &> /dev/null; then
        version=$(ideviceinstaller --version 2>&1 || echo "unknown")
        print_success "ideviceinstaller installed: $version"
    else
        print_error "Installation failed. Please try again."
        return
    fi

    echo ""
    print_header "Next Steps"
    echo ""
    echo "1. Build on Mac:"
    echo "   cd /path/to/LoopWorkspace"
    echo "   fastlane build_loop"
    echo ""
    echo "2. Transfer IPA to deployment machine:"
    echo "   scp user@buildmachine:LoopWorkspace/artifacts/Loop.ipa ~/Downloads/"
    echo ""
    echo "3. On deployment machine, enable Developer Mode on iPhone:"
    echo "   Settings → Developer Mode → Enable"
    echo ""
    echo "4. Plug in iPhone and install:"
    echo "   ideviceinstaller ~/Downloads/Loop.ipa"
    echo ""
    print_success "libimobiledevice installation complete!"
}

# Method 3: AltServer
setup_altserver() {
    print_header "Setting Up AltServer"

    echo ""
    print_info "AltServer allows wireless installation of apps"
    print_info "Works on: macOS, Windows (WSL2), Linux"

    echo ""
    echo "Installation Instructions:"
    echo ""
    echo "macOS:"
    echo "  brew install altserver"
    echo ""
    echo "Windows (requires WSL2 with Ubuntu):"
    echo "  wsl --install"
    echo "  # Inside Ubuntu WSL:"
    echo "  sudo apt-get install libimobiledevice-utils"
    echo ""
    echo "Or download from: https://altstore.io"
    echo ""

    read -p "Have you installed AltServer? (y/n) " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi
    echo ""

    print_header "Using AltServer"
    echo ""
    echo "1. Build Loop on Mac:"
    echo "   cd /path/to/LoopWorkspace"
    echo "   fastlane build_loop"
    echo "   → Creates Loop.ipa"
    echo ""
    echo "2. Launch AltServer application"
    echo ""
    echo "3. Drag Loop.ipa into AltServer window"
    echo ""
    echo "4. Select:"
    echo "   • Target device (your iPhone)"
    echo "   • Apple ID to sign with"
    echo ""
    echo "5. Wait for installation (usually <2 min)"
    echo ""
    echo "6. Future updates:"
    echo "   • Can reinstall wirelessly (no USB after initial install)"
    echo "   • AltServer auto-renews certificate every 7 days"
    echo ""
    print_success "AltServer setup complete!"
}

# Method 4: Xcode Remote
setup_xcode_remote() {
    print_header "Setting Up Xcode Remote Compilation"

    echo ""
    print_info "Build machine: Mac with Xcode"
    print_info "Deploy machine: Any Mac (accesses Xcode via SSH)"

    echo ""
    echo "Setup Steps:"
    echo ""
    echo "1. On Build Machine:"
    echo "   System Settings → General → Sharing → Remote Login"
    echo "   (Note the SSH command shown)"
    echo ""
    echo "2. On Deploy Machine:"
    echo "   Test SSH connection:"
    echo "   ssh buildmachine.local"
    echo ""
    echo "3. Once logged in to build machine via SSH:"
    echo "   cd /path/to/LoopWorkspace"
    echo "   xed .  # Opens Xcode"
    echo ""
    echo "4. In Xcode:"
    echo "   • Select scheme: LoopWorkspace"
    echo "   • Select device: Your iPhone"
    echo "   • Product → Build & Run (Cmd+R)"
    echo ""
    print_success "Xcode remote setup complete!"
}

# View documentation
show_docs() {
    print_header "Available Documentation"

    echo "Local files:"
    echo ""
    if [ -f "DEPLOYMENT_ALTERNATIVES.md" ]; then
        echo "✅ DEPLOYMENT_ALTERNATIVES.md"
        echo "   → Detailed comparison of all methods"
    fi

    if [ -f "DEPLOYMENT_IMPLEMENTATION.md" ]; then
        echo "✅ DEPLOYMENT_IMPLEMENTATION.md"
        echo "   → Step-by-step implementation guides"
    fi

    if [ -f "DEPLOYMENT_STRATEGY_SUMMARY.md" ]; then
        echo "✅ DEPLOYMENT_STRATEGY_SUMMARY.md"
        echo "   → Quick decision guide and timelines"
    fi

    echo ""
    echo "Online Resources:"
    echo "  • LoopDocs: https://loopkit.github.io/loopdocs/"
    echo "  • Browser Build: https://loopkit.github.io/loopdocs/browser/bb-overview/"
    echo "  • AltStore: https://altstore.io/"
    echo "  • libimobiledevice: https://github.com/libimobiledevice/libimobiledevice"
    echo ""
    echo "Local project files:"
    echo "  • fastlane/testflight.md (official GitHub build guide)"
    echo "  • fastlane/Fastfile (build automation)"
    echo "  • CONTRIBUTING.md (development guidelines)"
    echo ""
}

# Main loop
main() {
    while true; do
        show_menu

        case $choice in
            1)
                setup_github_actions
                ;;
            2)
                setup_ideviceinstaller
                ;;
            3)
                setup_altserver
                ;;
            4)
                setup_xcode_remote
                ;;
            5)
                show_docs
                ;;
            0)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main
main

