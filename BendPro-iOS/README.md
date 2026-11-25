# BendPro — Native iOS (Swift + SwiftUI)

A native iOS rewrite of the **BendPro — Conduit Bending Calculator** app. Built with **Swift 5.9** and **SwiftUI** targeting **iOS 15.0+**, replacing the legacy React/Capacitor WebView implementation with zero external dependencies, zero web technologies, and offline-first execution.

---

## Supported Devices & Architecture

- **Deployment Target**: iOS 15.0 minimum. Strictly uses iOS 15-compatible APIs.
- **Device Support**: Universal (iPhone & iPad).
  - On iPhone (including small screens like iPhone SE and large screens like iPhone Pro Max), views stretch fluidly across the device width with 48pt tap targets.
  - On iPad, content is constrained to a readable maximum width (`640pt`) and centered against the edge-to-edge dark void background.
- **Architecture**:
  - `Packages/BendProCore`: Pure Swift package (no SwiftUI or UIKit imports) containing models, constants, centerline-radius calculation engine, unit conversions/fractions, and golden test fixtures.
  - `BendPro/ViewModels`: `DetailViewModel` managing calculation state, clamping trade sizes per bender, and providing history summaries.
  - `BendPro/App`: `AppStore` managing persistent settings and calculation history via `UserDefaults` with safe fallback; `ShellViewModel` state machine managing 3-tab navigation and sub-routes.
  - `BendPro/Screens`: Home grid, Benders picker, History, Settings, and Detail screen.
  - `BendPro/Diagrams`: 320×200 proportional vector diagrams rendered with SwiftUI `Path` and `Shape`.
  - `BendPro/Components`: Custom 3×4 numerical keypad and 0.125" snap slider (`ValueInput`), numeric field with keyboard toolbar (`PlainField`), custom bottom navigation bar, headers, and status pill badges.

---

## Build & Test Instructions

### Prerequisites
- macOS running Xcode 15 or newer.
- XcodeGen:
  ```bash
  brew install xcodegen
  ```

### 1. Test Pure-Swift Core Calculations
Run the 28 golden table unit tests and fraction formatting checks:
```bash
cd Packages/BendProCore
swift test
```

### 2. Generate Xcode Project
Generate `BendPro.xcodeproj` from `project.yml`:
```bash
xcodegen generate
```

### 3. Build & Run Tests in Xcode
Open `BendPro.xcodeproj` in Xcode or compile via CLI:
```bash
xcodebuild -project BendPro.xcodeproj \
  -scheme BendPro \
  -destination 'generic/platform=iOS Simulator' \
  build CODE_SIGNING_ALLOWED=NO
```

To run unit tests across both core and view models:
```bash
xcodebuild test \
  -project BendPro.xcodeproj \
  -scheme BendProTests \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## App Store Metadata Notes

- **App Name**: BendPro
- **Subtitle**: Conduit Bending Calculator
- **Bundle ID**: `com.bendpro.app`
- **Version**: `1.0` (Build `1`)
- **Category**: Utilities
- **Age Rating**: 4+
- **Pricing**: Free (No ads, no subscriptions, no in-app purchases)
- **Privacy & Permissions**:
  - **No Network Permission**: Completely offline. No HTTP requests, analytics, or remote tracking.
  - **Privacy Manifest (`PrivacyInfo.xcprivacy`)**:
    - `NSPrivacyTracking`: `false`
    - `NSPrivacyTrackingDomains`: `[]`
    - `NSPrivacyCollectedDataTypes`: `[]` (No data collected)
    - `NSPrivacyAccessedAPITypes`: Declares `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1` for local app preferences (active unit, selected bender, saved history, dark mode preference).

---

## Definition of Done (Checklist A11)

- [x] **All 9 calculators work and match golden tests and reference screens**:
  - Core Bends: Offset, 90° Bend, 3-Point Saddle, Kick.
  - Advanced Bends: Kick + 90°, Multi-Shot, 4-Point Saddle, Rolling Offset.
  - Tools: Wire Fill (conduit area, conductor area, fill % against NEC limits).
- [x] **3 tabs, bender picker, units, history persistence work offline after cold start**:
  - Bends, History, Settings navigation state machine.
  - UserDefaults JSON storage (`bendpro:v1`) with corruption fallback.
  - "Clear all" history dialog with confirmation.
- [x] **All 9 diagrams drawn natively and recoloured by feasibility**:
  - Vector pipe stroke, feasibility color overlay, bend point circles, dashed dimension lines, angle and dimension labels.
- [x] **No WebView / Capacitor / JS dependency anywhere. No network permission**:
  - Pure Swift & SwiftUI. Zero JavaScript or web views.
- [x] **Unit tests pass**:
  - All 28 rows from golden table A10 verified in `BendProCoreTests`.
  - Format length examples, fraction reductions, and 11.99" carry fix verified.
  - View model tests covering defaults, resets, bender picker round-trips, and label formatting verified.
- [x] **Project Generation & CI**:
  - Declarative XcodeGen configuration (`project.yml`).
  - `.github/workflows/ios.yml` running on push/PR with `macos-latest`.
  - `.gitignore` excluding build artifacts and intermediate files.
