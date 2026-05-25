# AGENTS.md: LoopWorkspace Development Guide

LoopWorkspace is an iOS/watchOS app for automated insulin delivery, built as a modular ecosystem of interdependent frameworks. This guide helps AI agents understand the architecture and contribute effectively.

## Architecture Overview

**LoopWorkspace** is a workspace containing ~20 submodules orchestrated via Git submodules. The main app (**Loop**) depends on **LoopKit** (core framework) and multiple device/service plugins. Each plugin is a separate repository synced via `Scripts/sync.swift`.

**Key Projects:**
- **Loop**: Main iOS app (Lives in `/Loop/Loop/` directory; not a typical Xcode project root)
- **LoopKit**: Core framework with domain models, algorithms, and UI boilerplate (Swift Package Manager compatible)
- **Device Kits**: Hardware integrations (G7SensorKit, OmniKit, MinimedKit, CGMBLEKit, LibreTransmitter, dexcom-share-client-swift, RileyLinkKit) - each is a plugin
- **Service Frameworks**: Remote integrations (NightscoutService, TidepoolService, AmplitudeService, LogglyService, MixpanelService, NightscoutRemoteCGM) - stateful plugins
- **LoopOnboarding**: Onboarding framework
- **LoopSupport**: Support/debugging utilities

## Build & Development Workflow

**Building the App:**
```bash
cd LoopWorkspace
xed .  # Opens workspace (not project!)
```
Select scheme **"LoopWorkspace"** (not "Loop") and build. The workspace is in `LoopWorkspace.xcworkspace/`.

**Key Config Files:**
- **Loop/Loop.xcconfig**: Base app build settings (bundle ID, display name, deployment target iOS 16.2)
- **LoopConfigOverride.xcconfig**: Developer team ID and feature flags (examples: `EXPERIMENTAL_FEATURES_ENABLED`, `SIMULATORS_ENABLED`, `DEBUG_FEATURES_ENABLED`)
- **Loop/Loop/Info.plist**, **Loop/Version.xcconfig**: Version/capability definitions

**Testing:**
- **Unit tests** in `Loop/LoopTests/` and `LoopKit/LoopKitTests/`  
- Run via Xcode (LoopWorkspace scheme) or `fastlane` (see below)
- Test fixtures usually in `*/Fixtures/` subdirectories

**Continuous Integration:**
Uses **fastlane** (`fastlane/Fastfile`) for GitHub Actions builds. Lanes:
- `build_loop`: Builds and archives for TestFlight
- `identifiers`: Sets up app identifiers  
- `certs`: Manages code signing certificates
Other lanes handle signing and release workflows. Not typically run locally unless modifying CI.

## Plugin Architecture (Critical Pattern)

Loop uses a **Pluggable protocol system** for extensibility. All plugins conform to protocols in `LoopKit/LoopKit/Service/`:

**Base Protocol:**
```swift
// LoopKit/LoopKit/Pluggable.swift
public protocol Pluggable: AnyObject {
    static var pluginIdentifier: String { get }
    func initializationComplete(for pluggables: [Pluggable])
}
```

**Service Plugins (most common):**
Conform to `StatefulPluggable` → `Service`:
```swift
// LoopKit/LoopKit/Service/Service.swift
public protocol Service: StatefulPluggable {
    static var localizedTitle: String { get }
    var serviceDelegate: ServiceDelegate? { get set }
}

// LoopKit/LoopKit/Service/StatefulPluggable.swift
public protocol StatefulPluggable: Pluggable {
    typealias RawStateValue = [String: Any]
    init?(rawState: RawStateValue)
    var rawState: RawStateValue { get }
    var isOnboarded: Bool { get }
    var stateDelegate: StatefulPluggableDelegate? { get set }
}
```

**Key Pattern:**
- Plugins serialize state to `[String: Any]` (persisted to UserDefaults/Core Data)
- Must be `initOnboarded` before runtime use
- Notify `stateDelegate` when state changes via `pluginDidUpdateState(_:)`
- Examples: NightscoutService, AmplitudeService, etc.

**Device Manager Pattern** (for hardware):
Device managers (CGM, Pump) don't fully conform to Service but share similar state serialization patterns. See `Loop/Loop/Managers/CGMManager.swift` and `LoopKit/LoopKit/DeviceManager/` for device-specific protocols.

## Core Manager Classes

Loop bootstraps via state machine in `Loop/Loop/Managers/LoopAppManager.swift`:

**State Flow:**
`initialize` → `checkProtectedDataAvailable` → `launchManagers` → `launchOnboarding` → `launchHomeScreen` → `launchComplete`

**Key Managers** (all in `Loop/Loop/Managers/`):
- **LoopAppManager**: State orchestration, app lifecycle
- **DeviceDataManager**: CGM/Pump data storage (Core Data, HealthKit)
- **LoopDataManager**: Loop calculations (glucose effects, insulin on board, dosing decisions)
- **StatefulPluginManager**: Plugin registry and lifecycle
- **NotificationManager, AlertManager**: User notifications and alerts
- **WatchDataManager**: Watch app synchronization
- **RemoteDataServicesManager**: Syncs to Nightscout, Tidepool
- **LoggingServicesManager, AnalyticsServicesManager**: Observes events and logs to remote services

Pattern: Managers use weak delegates and coordinate via protocols. Heavy use of Combine `@Published` for reactive state.

## Data Storage & Core Data

**Core Data Model:**
Located in `LoopKit/LoopKit/Persistence/Model.xcdatamodeld/`. Uses versioned migrations (`Modelv1v4.xcmappingmodel/`).

**Key Pattern:**
- Glucose, dose, and carb samples typically store in **HealthKit** (HKSampleStore) as well as Core Data for redundancy and watchOS access
- Settings (therapy settings, schedules) in Core Data
- User defaults for app-scoped preferences
- App group container for Watch/extension data sharing

**Important:** Always check `HealthKitSampleStore.swift` and `HealthStoreUnitCache.swift` in LoopKit for sample handling patterns.

## Localization & Strings

**User-Facing Strings:**
- Use `.xcstrings` files (Xcode 15+) in App bundles (e.g., `Loop/Localizable.xcstrings`)
- **Do NOT commit** translations for non-English languages; these come via **Lokalise** (crowdsourced translation service)
- Refer to CONTRIBUTING.md for translation contributor workflow

**Scripts:** `Scripts/manual_*_translations.sh` and `Scripts/*/import_localizations.sh` sync with Lokalise via `crowdin.yml` in module roots.

## Coding Conventions

From CONTRIBUTING.md:
- Follow Xcode's built-in formatting
- Keep indentation and formatting consistent (no formatting-only changes in unrelated files)
- Use clear, readable code over clever solutions
- Follow existing naming and file organization patterns
- Use **`dev`** branch for feature work (not `main`/`master`)
- Branch names: `fix/watchstate-sync`, `feature/onboarding-target-behavior`, `refactor/therapy-editor`

**PR Guidance:**
- Small, focused PRs are easier to review
- Explain **what** changed and **why**
- Test thoroughly before opening PR
- Do NOT submit large AI-generated code; use AI tools for small, well-understood tasks
- All contributions must be intentionally designed and author-driven

## Submodule Management

**Syncing Submodules:**
```bash
git clone --branch=<branch> --recurse-submodules https://github.com/LoopKit/LoopWorkspace
```

**Updating Submodule References:**
Use `Scripts/sync.swift` (requires Swift Scripting tools). This tool:
- Works across all 18+ submodule projects
- Creates cross-repo sync PRs
- Requires `GH_USERNAME`, `GH_TOKEN`, `GH_COMMITTER_NAME`, `GH_COMMITTER_EMAIL` env vars

After submodule changes, ensure workspace builds cleanly and all tests pass.

## Cross-Module Communication

**Device Integration:**
Device managers (CGM, Pump) coordinate via `StatefulPluginManager`. Each device provides:
- State serialization (`rawState`)
- Real-time data delivery callbacks
- UI onboarding/setup controllers
See `CGMBLEKit`, `OmniKit`, `MinimedKit` submodules for implementation examples.

**Remote Services:**
`RemoteDataService` protocol (based in `Service`) handles Nightscout/Tidepool sync. Services:
- Observe data changes via delegates
- Serialize updates and post to remote endpoints
- Handle authentication via `ServiceAuthentication`
See `NightscoutService`, `TidepoolService` for implementations.

**Extensions & Widgets:**
- **Loop Status Extension**: Provides lock screen widget (iOS 16.2+)
- **WatchApp/WatchApp Extension**: Apple Watch companion
- **Loop Widget Extension**: Home screen widgets
All sync via app group container and `ExtensionDataManager`. Model dependencies flow from LoopKit → Loop app → extensions (one-way).

## Algorithms & Math

Core calculation libraries in `LoopKit/LoopKit/`:
- **LoopAlgorithm/**: Insulin dosing recommendations (complex, closed-loop logic)
- **LoopMath.swift**: Foundation glucose/insulin effect calculations
- **InsulinKit/**: Insulin model (IOB, effects)
- **CarbKit/**: Carb absorption models
- Other domain-specific calculations: **RetrospectiveCorrection/**, **GlucoseEffect.swift**, etc.

**Key Pattern:** All calculations are **pure functions** (no side effects). Input: historical glucose, insulin, carbs; Output: predictions and recommendations. See test fixtures in `LoopKitTests/Fixtures/` for example data.

## Feature Flags & Compilation Conditions

Debug features controlled via **xcconfig** compilation conditions:

**Available Flags** (defined in `LoopConfigOverride.xcconfig`):
- `EXPERIMENTAL_FEATURES_ENABLED`: Experimental algorithm features
- `SIMULATORS_ENABLED`: Allow building on simulator (normally disabled for App Store)
- `DEBUG_FEATURES_ENABLED`: Developer debugging UI
- `ALLOW_ALGORITHM_EXPERIMENTS`: Allows tweaking closed-loop algorithm

Use `#if EXPERIMENTAL_FEATURES_ENABLED` in code. App Store builds do NOT include these.

## Common Tasks for Agents

**Adding a Feature:**
1. Open issue/discussion first (CONTRIBUTING.md)
2. Create `feature/*` branch from `dev`
3. Modify in appropriate module (Loop for UI, LoopKit for logic)
4. Add unit tests in `*/Tests/` sibling module
5. Update documentation strings
6. Test on simulator and real device (if possible)
7. Create PR linking issue

**Fixing a Bug:**
1. Reproduce in unit test (add to appropriate test file)
2. Fix in source module
3. Ensure test passes
4. Check no regressions in related managers/tests
5. Keep PR minimal and focused

**Adding Device Integration:**
1. Create new Kit submodule (e.g., `NewDeviceKit/`)
2. Implement device-specific manager conforming to `CGMManager` or pump equivalent protocol
3. Create plugin UI in submodule's UI target
4. Register in `Loop/Loop/Managers/CGMManager.swift` (or pump equivalent)
5. Add onboarding flow in `LoopOnboarding`

**Dependency Updates:**
- Use Xcode to update framework targets
- Update `Package.swift` if using SPM
- Run full test suite after updates
- Check for deprecated API usage (Swift 5.7+ syntax applies)

## Testing & Debugging

**Run Tests:**
Xcode: Select LoopWorkspace scheme → Product → Test (or Cmd+U)

**Diagnostic Logging:**
Loop uses `DiagnosticLog` (custom logging system, see `LoopKit/LoopKit/CriticalEventLog.swift`). Logs available in critical event export feature in app settings.

**Simulator vs Device:**
- Simulator: Builds with `SIMULATORS_ENABLED` flag; uses mock CGM/pump data
- Device: Requires provisioning profile and team ID; uses real Bluetooth devices
Set team ID in `LoopConfigOverride.xcconfig`: `LOOP_DEVELOPMENT_TEAM = YOUR_TEAM_ID`

## Version Management

App version defined in `Loop/Version.xcconfig` (not Info.plist directly). Referenced by:
- Fastlane CI pipeline (auto-increments build number)
- Onboarding version checks

When modifying version logic, verify against `LoopKit/LoopKit/VersionUpdate.swift`.

## Resources & External Docs

- **LoopDocs**: https://loopkit.github.io/loopdocs/ (end-user and developer docs)
- **Loop Zulipchat**: https://loop.zulipchat.com/ (community coordination)
- **Lokalise**: Translation management (for translators)
- **GitHub LoopKit**: https://github.com/LoopKit/ (all submodule repos)

---

**Last Updated:** May 2026  
**For AI Agents:** Use this guide to navigate LoopWorkspace structure. When unsure about a pattern, search for similar implementations in the codebase before inventing new patterns.

