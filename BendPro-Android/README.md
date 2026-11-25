# BendPro — Native Android Conduit Bending Calculator

A 100% native Android application written in **Kotlin** and **Jetpack Compose**, replacing the legacy React/Capacitor WebView app with zero web dependencies, offline-first execution, and zero network permissions.

---

## Highlights

- **Pure Kotlin Engine (`com.bendpro.core`)**: Centerline-radius calculation engine isolated with zero Android dependencies, 100% covered by unit tests.
- **Native Vector Diagrams (`com.bendpro.ui.diagrams`)**: 9 responsive vector diagrams rendered via Jetpack Compose `Canvas` on a 320×200 virtual coordinate space, recolored by calculation feasibility.
- **Offline & Permissionless**: Requires **zero permissions** (no `INTERNET` permission in `AndroidManifest.xml`).
- **No WebView / Capacitor / JavaScript**: True native Android app leveraging Material 3 tokens, custom dark theme, and bundled Poppins typography.
- **Jetpack DataStore Persistence**: Unit preferences, selected benders, and saved history entries survive process death and app restarts.
- **Full TalkBack Accessibility & Responsive Layout**: Accessible touch targets (≥ 48dp), TalkBack semantics, high font scaling (130%+), and scrolling support across small (360dp) and large displays.

---

## 9 Conduit Bending Calculators

1. **Offset**: Two bends to clear an obstacle vertically (lead-in mark, spacing, shrink).
2. **90° Bend**: Stub-up from floor or wall (deduct, gain, mark).
3. **3-Point Saddle**: Over a round or square obstruction (center mark, side marks, total gain).
4. **Kick**: Single angled bend (distance to mark, gain).
5. **Kick + 90°**: Kick with a stub-up at the end (start mark, end mark, 90° deduct).
6. **Multi-Shot**: Segmented bend for large sweep radius (angle per shot, distance between shots).
7. **4-Point Saddle**: Flat-topped, wide obstruction (inner pair spacing, outer mark beyond each inner).
8. **Rolling Offset**: Offset across two planes (true offset, roll angle, spacing, shrink).
9. **Wire Fill**: Conduit fill percentage vs NEC limit (conduit area, conductor area, fill percentage).

---

## Prerequisites & Environment

- **JDK**: Java 17 or higher
- **Android SDK**: `compileSdk 36`, `targetSdk 36`, `minSdk 24` (Android 7.0+)
- **Build System**: Gradle 8.14.3 with Android Gradle Plugin 8.8.0

---

## Build, Test & Run

### 1. Run Unit Tests
```bash
./gradlew testDebugUnitTest
```
Runs all 31 core engine, calculation golden tests, unit formatting tests, and ViewModel lifecycle tests.

### 2. Build Debug APK
```bash
./gradlew assembleDebug
```
Output: `app/build/outputs/apk/debug/app-debug.apk`

### 3. Build Release APK (R8 Minified)
```bash
./gradlew assembleRelease
```
Output: `app/build/outputs/apk/release/app-release.apk` (approx. 4.3 MB).

### 4. Release Signing Configuration
Release signing credentials can be supplied through `local.properties` or environment variables without committing keystores to source control:

- `RELEASE_STORE_FILE` or `KEYSTORE_PATH`: Path to the `.jks` / `.keystore` file
- `RELEASE_STORE_PASSWORD` or `KEYSTORE_PASSWORD`: Keystore password
- `RELEASE_KEY_ALIAS` or `KEY_ALIAS`: Key alias
- `RELEASE_KEY_PASSWORD` or `KEY_PASSWORD`: Key password

If these properties are not set, `assembleRelease` falls back gracefully to debug signing so testing release builds works out of the box.

---

## Definition of Done Checklist (A11)

- [x] All 9 calculators work and match the golden tests and the reference screens.
- [x] 3 tabs (Bends, History, Settings), bender picker, units (`IN`, `FT+IN`, `MM`), and history persistence work offline after a cold start.
- [x] All 9 diagrams drawn natively using Compose `Canvas` and recolored by feasibility (`OK`, `WARN`, `DANGER`).
- [x] No WebView / Capacitor / JS dependency anywhere. No network permission in `AndroidManifest.xml`.
- [x] Unit tests for the core module pass (31/31 passed); app builds cleanly from a checkout.
- [x] `.gitignore` excludes build outputs, caches, and keystore files.

---

## Deliberate Deviations from Web App (A9)

1. **Retain inputs across Bender Picker round trips (A9.1)**: In the web app, opening the bender picker unmounted the detail screen and reset all user inputs to defaults. In native BendPro, the state is held in `DetailViewModel` scoped across the Bends tab so inputs survive.
2. **Trade size clamping (A9.2)**: When switching to a bender that does not support the currently selected trade size (e.g. 3/4" with an iToolco bender), the trade size automatically jumps to the bender's first supported size.
3. **Feet-inch carry fix (A9.3)**: When the inches component rounds up to 12 (e.g., 11.99"), it correctly carries into feet (`1' 0"` instead of `12"`).
4. **Millimeter input mode (A9.4)**: When the active unit is `MM`, keypad and slider operate directly in integer millimetres with mm readouts, converting to inches internally.
5. **Clear all confirmation dialog (A9.5)**: Tapping "Clear all" in History presents a confirmation dialog to prevent accidental deletion.
6. **No network permission (A9.6)**: The legacy Capacitor manifest declared `android.permission.INTERNET`. The native manifest removes all permissions.
7. **Removed dead save icon (A9.7)**: The non-functional header save icon from the web app has been removed.
8. **Consistent Round-Half-Up MM Formatting**: JavaScript's `toFixed` rounds half-up; native formatting matches JS formatting precisely for all metric values.

---

## Manual Test Verification

1. **Offset**: 30°, rise 4 in, Klein 3/4" → Mark 1 = `3"`, Mark 2 = `11"`, Spacing = `8"`, Shrink = `1 1/2"`.
2. **90° Bend**: Stub 12", 3/4" → Deduct = `6"`, Mark = `6"`, Gain = `2 3/16"`.
3. **Bender Selection**: Switch to iToolco Mega Bender → Trade size clamps to 1", supported chips: `1"`, `1-1/4"`, `1-1/2"`.
4. **Input Retention**: Enter custom values in any calculator, navigate into Bender Picker, select bender, navigate back → Values remain intact.
5. **Units**: Switching `IN` → `FT+IN` → `MM` updates all displayed values immediately; saved history items preserve their original formatted text.
6. **Persistence**: Save bends, force close app, restart → History items remain listed in reverse chronological order; "Clear all" with confirmation clears the list.
7. **Wire Fill**: 1/2" EMT, 12 AWG, 10 conductors → `NOT POSSIBLE` status pill (43.8% fill vs 40% max).
8. **Accessibility & Orientation**: Complete TalkBack coverage on buttons, inputs, and status pills; orientation changes preserve all input values and scroll position without crashing.
