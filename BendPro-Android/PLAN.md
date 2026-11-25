# BendPro — Native rewrite plan: Android (Kotlin + Jetpack Compose)

Goal: convert the React/Capacitor app **BendPro** into a native Android app. This file is meant to be given to Antigravity. It contains the full spec (Part A), the Android decisions (Part B) and ready-to-paste prompts for each phase.

## How to use

1. Create a new folder `BendPro-Android` and copy the old React project's `src/` and `package.json` into `BendPro-Android/reference-react/` (read-only reference).
2. Put this file in the folder (e.g. `PLAN.md`) and open the folder in Antigravity.
3. Send **Prompt B0**, then **B1**. When a phase is finished and tested, send the next prompt (B2 → B5). Do not skip phases.
4. After each phase: build, run on an emulator or phone, and compare with the web app before continuing.

Phases: **B1** core engine + tests · **B2** shell, Home, History, Settings, storage · **B3** 4 core bends + diagrams · **B4** 5 remaining calculators + wire fill · **B5** polish and release.

---

## PART A — SHARED SPEC (identical for Android and iOS)

### A0. Context and rules for the agent

- **Existing app**: BendPro — Conduit Bending Calc. React 18 + TypeScript + Vite, wrapped by Capacitor (WebView). Offline, no account, no analytics. App id `com.bendpro.app`.
- **Goal**: rebuild it as a **truly native** app. No WebView, no Capacitor, no JavaScript, no React Native, no Flutter.
- **Source of truth**: the React code, copied read-only into `reference-react/src/` inside the new project. Behaviour must match it, except for the deliberate deviations in section A9.
- **Rules**
  1. Never edit `reference-react/`. Read it whenever a detail is unclear.
  2. Do not add features that are not in this spec. Do not remove any.
  3. All calculation code lives in a pure-language "core" module with no UI imports, so it can be unit tested without a device.
  4. Work phase by phase (Part B/C). After each phase print: what was built, how to run it, which tests pass, what is left.
  5. If something here conflicts with the reference code, stop and ask instead of guessing.
  6. App must work with **no network permission**.

### A1. Feature list (9 calculators)

| Kind id | Title (UI) | Group on Home |
|---|---|---|
| offset | Offset | Core Bends |
| ninety | 90° Bend | Core Bends |
| saddle3 | 3-Point Saddle | Core Bends |
| kick | Kick | Core Bends |
| kick90 | Kick + 90° | Advanced Bends |
| segmented | Multi-Shot | Advanced Bends |
| saddle4 | 4-Point Saddle | Advanced Bends |
| rolling | Rolling Offset | Advanced Bends |
| wirefill | Wire Fill | Tools |

Home card subtitles (exact text): Offset "Two bends to clear an obstacle vertically"; 90° Bend "Stub-up from floor or wall"; 3-Point Saddle "Over a round or square obstruction"; Kick "Single angled bend"; Kick + 90° "Kick with a stub-up at the end"; Multi-Shot "Segmented bend for large radius"; 4-Point Saddle "Flat-topped, wide obstruction"; Rolling Offset "Offset across two planes"; Wire Fill "Conduit fill % vs NEC limit". Section labels: "Core Bends", "Advanced Bends", "Tools". Icons: port the SVG paths from `reference-react/src/screens/HomeScreen.tsx`.

### A2. Constants and data (exact values)

All lengths are stored internally in **inches** (Double).

**ANGLE_TABLE** (angle° → multiplier, shrinkPerInch). Unknown angle falls back to the 45° row.

| Angle | multiplier | shrinkPerInch |
|---|---|---|
| 10 | 6.0 | 1/16 |
| 22.5 | 2.6 | 1/4 |
| 30 | 2.0 | 3/8 |
| 45 | 1.4 | 3/8 |
| 60 | 1.2 | 1/4 |

`OFFSET_ANGLES = [10, 22.5, 30, 45, 60]` (shown as chips "10°", "22.5°", …). Default angle: 30.

**DEDUCT_TABLE** (trade size in → 90° deduct in): 0.5→5, 0.75→6, 1→8, 1.25→11, 1.5→13, 2→17. Fallback 8.

**TRADE_SIZES** = [0.5, 0.75, 1, 1.25, 1.5, 2]. Labels: `1/2"`, `3/4"`, `1"`, `1-1/4"`, `1-1/2"`, `2"`.

**EMT internal area (sq in)**: 0.5→0.304, 0.75→0.533, 1→0.864, 1.25→1.496, 1.5→2.036, 2→3.356. Unknown size falls back to the 0.75 value.

**THHN/THWN area (sq in)** by AWG (keys are strings, keep this order for the chips): "14"→0.0097, "12"→0.0133, "10"→0.0211, "8"→0.0366, "6"→0.0507, "4"→0.0824, "3"→0.0973, "2"→0.1158, "1"→0.1562. Unknown falls back to "12".

**Benders** (id, brand, model, supported sizes, centerline radius in per size). Keep this order. `shoeRadius(bender, size)` = radius for that size, or **4.0** if the size is missing.

| id | brand | model | radii (size→in) |
|---|---|---|---|
| klein-emt-standard | Klein Tools | EMT Bender (1/2–1") | 0.5→4.0, 0.75→4.5, 1→5.75 |
| greenlee-855 | Greenlee | 855 Series (1/2–1-1/4") | 0.5→4.0, 0.75→4.5, 1→5.75, 1.25→7.0 |
| milwaukee-emt | Milwaukee | EMT Bender (1/2–1") | 0.5→4.0, 0.75→4.5, 1→5.75 |
| ideal-imc-rigid | Ideal Industries | IMC/Rigid Bender (1/2–1") | 0.5→4.5, 0.75→5.25, 1→6.5 |
| ridgid-emt | Ridgid | EMT Bender (1/2–1") | 0.5→4.0, 0.75→4.5, 1→5.75 |
| itoolco-mega-1-1.5 | iToolco | Mega Bender (1–1-1/2") | 1→5.75, 1.25→7.0, 1.5→8.25 |
| current-tools-1000 | Current Tools | 1000 Series (1/2–1") | 0.5→4.0, 0.75→4.5, 1→5.75 |
| custom | Custom | Add your own | 0.5→4.0, 0.75→4.5, 1→5.75, 1.25→7.0, 1.5→8.25, 2→9.5 |

The supported sizes of each bender are exactly the keys of its radius map. Default bender = first one (Klein). "Custom" is just a built-in entry; there is no editor for it.

### A3. Formulas (exact)

Helpers:
- `arc(radius, angleDeg) = radius * angleDeg * π / 180`
- `feasibilityFromRatio(spacing, minSpacing, comfySpacing)`: if `spacing <= 0 or spacing < minSpacing` → **danger** "Impossible — bends will overlap with this bender/shoe."; else if `spacing < comfySpacing` → **warn** "Tight — double-check clearance before bending."; else **ok** "Feasible with the selected bender."
- Feasibility level ∈ {ok, warn, danger}. Messages are shown as tooltip/accessibility text of the status pill.

Each calculator returns a result object plus feasibility.

1. **offset(angle, offset, bender, size)**: `(mult, shrinkPer) = angleTable[angle]`; `distanceBetweenBends = offset*mult`; `travel = distanceBetweenBends`; `shrink = shrinkPer*offset`; `a = arc(shoeRadius, angle)`; feasibility = ratio(distanceBetweenBends, 2a, 3a).
2. **ninety(size, stub)**: `deduct = DEDUCT[size] ?? 8`; `mark = stub - deduct`. Feasibility: `mark <= 0` → danger "Stub is shorter than the deduct — raise the stub height."; `mark < 2` → warn "Very short mark — leaves little margin for error."; else ok "Feasible with the selected bender." (bender is NOT used).
3. **kick(angle, rise, bender, size)**: `distanceToMark = rise*mult`; `gain = shrinkPer*rise`; `a = arc(shoeRadius, angle)`; feasibility = ratio(distanceToMark, a, 1.5a).
4. **saddle3(depth, bender, size)**: center angle 45, side angle 22.5; `centerToSide = depth*2.5`; `totalGain = depth*0.25`; `centerArc = arc(r,45)`, `sideArc = arc(r,22.5)`; `minSpacing = centerArc/2 + sideArc`; feasibility = ratio(centerToSide, minSpacing, minSpacing*1.6).
5. **kick90(angle, kickOffset, size, stub, bender)**: `kickMark = kickOffset*mult`; `deduct = DEDUCT[size] ?? 8`; `stubMark = stub - deduct`; `kickArc = arc(r, angle)`. If `kickOffset <= 0 or kickMark < kickArc or stubMark <= 0` → danger "Not possible — increase kick offset or stub length."; else if `kickMark < kickArc*1.5 or stubMark < 2` → warn "Tight on one end — double-check clearance before bending."; else ok "Feasible with the selected bender."
6. **segmented(totalAngle, radius, shots)** (no bender): `anglePerShot = shots > 1 ? totalAngle/(shots-1) : totalAngle`; `distanceBetweenShots = 2*radius*sin(anglePerShot_in_radians/2)`. If `totalAngle <= 0 or radius <= 0 or shots < 2` → danger "Not possible — check angle, radius, and shot count."; else if `anglePerShot > 15` → warn "More than ~15° per shot — the sweep will look faceted, add more shots."; else ok "Feasible — smooth sweep with this shot count."
7. **saddle4(depth, obstructionWidth, bender, size)**: side angle 22.5; `innerSpacing = obstructionWidth`; `outerFromInner = depth*2.5`; `totalGain = depth*0.25`; `sideArc = arc(r,22.5)`; feasibility = ratio(outerFromInner, sideArc, sideArc*1.6).
8. **rolling(angle, vertical, horizontal, bender, size)**: `trueOffset = sqrt(v²+h²)`; `rollAngle = atan2(h, v) in degrees`; `distanceBetweenBends = trueOffset*mult`; `shrink = shrinkPer*trueOffset`; `a = arc(r, angle)`. If `v <= 0 and h <= 0` → danger "Enter at least one of vertical or horizontal offset."; else ratio(distanceBetweenBends, 2a, 3a).
9. **wirefill(size, awg, count)**: `conduitArea = EMT[size]`; `wireArea = THHN[awg]`; `totalArea = wireArea*count`; `maxFillPct = count==1 ? 53 : count==2 ? 31 : 40`; `fillPct = totalArea/conduitArea*100`. If `count <= 0 or fillPct > maxFillPct` → danger "Exceeds the {maxFillPct}% NEC fill limit for {count} conductor(s) — step up conduit size."; else if `fillPct > maxFillPct - 5` → warn "Close to the fill limit — little room for a mixed-size pull."; else ok "Within the NEC fill limit."

**summarize(result)** strings (used in History; `toFixed(n)` = fixed decimals; `"` is a literal inch mark):
- offset: `Marks {distanceBetweenBends:.2f}" apart · shrink {shrink:.3f}"`
- ninety: `Mark at {mark:.2f}" · deduct {deduct}"`
- kick: `Mark at {distanceToMark:.2f}" · gain {gain:.3f}"`
- saddle3: `Side bends {centerToSide:.2f}" from center · gain {totalGain:.3f}"`
- kick90: `Kick mark {kickMark:.2f}" from start · stub mark {stubMark:.2f}" from end`
- segmented: `{shots} shots at {anglePerShot:.1f}° · {distanceBetweenShots:.2f}" apart`
- saddle4: `Inner {innerSpacing:.2f}" apart · outer {outerFromInner:.2f}" beyond each`
- rolling: `True offset {trueOffset:.2f}" · roll {rollAngle:.1f}° · marks {distanceBetweenBends:.2f}" apart`
- wirefill: `{count} × {awg} AWG in {size}" EMT · {fillPct:.1f}% fill`  (`{size}` printed as a plain number, e.g. 0.75)

### A4. Units and formatting

Units: `in`, `ft-in`, `mm`. Labels in Settings: `IN`, `FT+IN`, `MM`.

`formatLength(valueIn, unit, precision = 2)`:
- not finite → `—`
- sign = `-` if negative; work with the absolute value.
- **mm**: `round(abs*25.4)` with 0 decimals when precision == 2, otherwise `precision` decimals; append ` mm`. (e.g. 7.375 in → `187 mm`; precision 3 → `106.362 mm` for 4.1875 in)
- **ft-in**: `feet = floor(abs/12)`, `inches = abs - feet*12`, `inchStr = toFraction(inches)`; if feet > 0 → `{feet}' {inchStr}"` else `{inchStr}"`.
- **in**: `{toFraction(abs)}"`.

`toFraction(v)`: round the fractional part to the nearest 1/16; 0/16 → whole number only; 16/16 → whole+1; reduce the fraction by 2s (8/16 → 1/2); `7.375 → "7 3/8"`, `0.3125 → "5/16"`, `0.03 → "0"`, `3.5 → "3 1/2"`.

Note: the `precision` argument (2 or 3) only changes the **mm** output in the reference. Inch/ft-in output ignores it (always 1/16" fractions). Keep that.

### A5. Screens and navigation

**App shell**: dark theme only. Bottom navigation with 3 tabs: **Bends**, **History**, **Settings** (icons: port from `components/BottomNav.tsx`). Height 64. Active tab uses the accent colour. Top header height 56.

**Bends tab** is a small state machine (mirror `screens/BendsTab.tsx`):
- `Home` → tap a card → `Detail(kind)`
- `Detail(kind)` → tap bender row → `BenderPicker(returnTo = kind)`
- `BenderPicker` → pick a bender (or back) → `Detail(returnTo)`
- Back from `Detail` → `Home`. System/hardware back follows the same stack (Android back button; iOS swipe-back/back button).
- Headers: Home header shows the wordmark `BEND` + `PRO` (the `PRO` part in the accent colour, see `HomeHeader.tsx` and `.home-header-mark` in `App.css`) with an info icon button on the right (it does nothing in the reference; keep it as a non-functional icon or hide it); Detail header has a back button + centred title (the TITLE table in A1) and **no** save icon; BenderPicker header title "Select Bender".

**Home screen**: three sections (A1) each a 2-column grid of cards (icon + title + subtitle).

**Bender picker**: intro text: "Select the bender you're working with. Centerline radius per shoe drives every calculation and QuickCheck result." Then a list of cards: brand (small), model, and pills with the supported sizes (labels from A2). The selected card is highlighted and shows a "SELECTED" tag.

**Detail screen** (all kinds except wirefill start with these two rows):
1. **Bender row**: icon + `{brand} · {tradeSizeLabel}` + chevron; tap opens the picker. Shown for every kind except wirefill (even ninety and segmented, which do not use the bender).
2. **CONDUIT chips**: the trade sizes (A2 order) filtered by the selected bender's supported sizes. Default selected size 0.75.
3. **INPUTS section** (table below).
4. **MARKS ON CONDUIT** and **CALCULATIONS** sections (table below).
5. **Diagram card** (see A8).
6. **Status pill**: `VALID` (ok, check icon), `CHECK CLOSELY` (warn), `NOT POSSIBLE` (danger); colours ok/warn/danger from A7; the feasibility message is the accessibility label.
7. **Save button**: "Save to history"; after saving it reads "Saved ✓" until the user leaves the screen.

Inputs per kind (`L` = length input with keypad/slider, `P` = plain numeric field, defaults in bold):

| Kind | Inputs |
|---|---|
| offset | L "RISE" **4** (max 24) · angle chips |
| ninety | L "STUB LENGTH" **12** (max 60) |
| kick | L "RISE" **6** (max 24) · angle chips |
| saddle3 | L "OBSTRUCTION DEPTH" **3** (max 12) |
| kick90 | L "KICK OFFSET" **4** (max 12) · L "STUB LENGTH (FROM FINISHED END)" **18** (max 60) · angle chips |
| segmented | P "TOTAL SWEEP ANGLE" **90** ° (1–180) · L "BEND RADIUS" **24** (max 60) · P "NUMBER OF SHOTS" **6** shots (round to int, min 2, max 20) |
| saddle4 | L "OBSTRUCTION DEPTH" **3** (max 12) · L "OBSTRUCTION WIDTH (FLAT TOP)" **8** (max 36) |
| rolling | L "VERTICAL OFFSET" **6** (max 24) · L "HORIZONTAL OFFSET" **4** (max 24) · angle chips |
| wirefill | chips "CONDUIT SIZE (EMT)" (all 6 sizes, default **0.75**) · chips "WIRE SIZE (AWG, THHN/THWN)" (A2 order, default **"12"**) · P "NUMBER OF CONDUCTORS" **3** ct (round, min 1, max 40) |

Marks / Calculations rows (value formatted with `formatLength` in the active unit unless noted; `LEAD_IN = 3` inches):

| Kind | MARKS ON CONDUIT | CALCULATIONS |
|---|---|---|
| offset | Mark 1 = LEAD_IN; Mark 2 = LEAD_IN + distanceBetweenBends | Spacing = distanceBetweenBends; Shrink = shrink (precision 3) |
| ninety | Mark 1 = mark | Deduct; Gain = max(deduct×0.36, 0.1) (precision 2); Mark = mark |
| kick | Mark = distanceToMark | Gain (precision 3) |
| saddle3 | Center → Side = centerToSide | Total gain (precision 3) |
| kick90 | "Mark 1 · from start" = kickMark; "Mark 2 · from end" = stubMark | "90° deduct" |
| segmented | — (section not shown) | Angle per shot = `{x:.1f}°` (plain); Distance between shots |
| saddle4 | "Inner pair · spacing" = innerSpacing; "Outer · beyond each inner" = outerFromInner | "All 4 bends" = `22.5°` (plain); Total gain (precision 3) |
| rolling | Mark 1 = LEAD_IN; Mark 2 = LEAD_IN + distanceBetweenBends | True offset; Roll angle = `{x:.1f}°` (plain); Shrink (precision 3) |
| wirefill | — | Conduit area = `{:.3f} sq in`; Conductor area = `{:.4f} sq in`; "Fill (max {maxFillPct}%)" = `{:.1f}%`. Footnote (small, tertiary colour): "EMT and THHN/THWN only, approximate NEC Chapter 9 subset — not verified against a specific code edition. Verify against the current NEC tables for other conduit or wire types." |

Rows under MARKS have a small accent dot before the label and an accent-coloured value; rows under CALCULATIONS are plain.

**Length input (ValueInput)**: collapsed = one row (label left, `formatLength` value right). Tap → expands: header with label and three small buttons `KEYPAD` / `SLIDE` (toggle, default keypad) / `DONE` (collapse). Big readout `{value:.3f} in`. Keypad is a 3×4 grid `1 2 3 / 4 5 6 / 7 8 9 / . 0 ⌫`; typing builds a decimal string (leading "0" replaced by the first digit, only one "."; ⌫ removes the last char, empty → "0"). Slider = a horizontal track, press-and-drag, value = min + pct×(max−min), snapped to 0.125 in, `min` default 0, `max` per input (table above, default 96). Entry is plain decimal.

**Plain field (P)**: a row with label on the left and an inline numeric text field + suffix on the right; non-numeric → 0; apply the per-field rounding/min/max in the table.

**History tab**: header "History". Empty state title "No saved bends yet", body "Calculations you save from the Bends tab will show up here, newest first." Otherwise: "{n} saved" on the left, "Clear all" text button on the right (no confirm dialog in the reference — add one, see A9), then a list newest-first. Each item: label + short date (e.g. "Nov 22") on one row, `inputSummary`, `resultSummary` (monospace).

**Settings tab**: header "Settings". Sections: **Units** (three pills IN / FT+IN / MM, one active); **Display** (toggle "High-contrast dark mode", hint "Optimized for bright job-site light and headlamps." — default ON; the reference stores it but has no visual effect, keep it stored and keep the same behaviour); **About**: "BendPro runs the same centerline-radius engine for every calculation and diagram — offline, with no account and no data collection."

### A6. Persistence

One persisted object (the reference key is `bendpro:v1` in localStorage):

```
unit: "in" | "ft-in" | "mm"        default "in"
benderId: string                   default = first bender id
history: [HistoryEntry]            default []
darkOptimized: bool                default true
HistoryEntry { id: string (epoch millis as text), kind, label, createdAt: epoch millis, inputSummary, resultSummary }
```

- History is appended; the UI shows it reversed (newest first). Corrupt/missing data → defaults.
- Calculator input values are **not** persisted across app launches.

Label / inputSummary built at save time (`{L}` = `formatLength(value, unit)`, `{size}` = trade-size label from A2):

| Kind | label | inputSummary |
|---|---|---|
| offset | `{angle}° Offset` | `Offset {L} · {size}` |
| ninety | `90° Bend` | `Stub {L} · {size}` |
| kick | `{angle}° Kick` | `Rise {L} · {size}` |
| saddle3 | `3-Point Saddle` | `Depth {L} · {size}` |
| kick90 | `{angle}° Kick + 90°` | `Kick offset {L} · Stub {L} · {size}` |
| segmented | `Multi-Shot 90°` | `Sweep {totalAngle}° · Radius {L} · {shots} shots` |
| saddle4 | `4-Point Saddle` | `Depth {L} · Width {L} · {size}` |
| rolling | `{angle}° Rolling Offset` | `Vertical {L} · Horizontal {L} · {size}` |
| wirefill | `Wire Fill` | `{count} × {awg} AWG in {size} EMT` |

(Angle prints like `30` or `22.5`. The segmented label says "90°" even if the sweep differs — keep as in the reference.)

### A7. Design tokens (authoritative; for spacing/typography read `reference-react/src/App.css` and `index.css`)

| Token | Value |
|---|---|
| bg-void | #090d16 |
| bg-panel | #121a2c |
| bg-panel-raised | #1a2438 |
| bg-inset | #0c1220 |
| line | #263251 |
| line-soft | #1a2338 |
| metal-200 / 400 / 600 | #cdd4da / #8a939b / #5b646b |
| text-primary / secondary / tertiary | #eef1f6 / #94a1bd / #5c6884 |
| accent / accent-dim | #3d82f6 / #2563eb |
| accent-wash | rgba(61,130,246,0.14) |
| ok / warn / danger | #35c97e / #f0a93b / #ff4d4f |
| ok-wash / warn-wash / danger-wash | 14% alpha of the same colours |
| radius sm / md / lg | 6 / 10 / 16 |
| tap target min | 48 |

Fonts: the reference CSS names Poppins but never loads it (no font files or links), so the web app actually renders in the fallback system font. For native, either use the system font (San Francisco / Roboto) or bundle Poppins (open-source, OFL) — **default: bundle Poppins** to match the intended look; use the system monospace for numbers. Dark only; text on #090d16.

### A8. Diagrams

`reference-react/src/components/BendDiagram.tsx` draws one SVG per kind on a **320×200** canvas using: pipe stroke (width 6, colour metal-200), an overlay stroke of the same path in the **feasibility colour** (width 2), dots at bend points (r 3.5), dashed dimension lines with labels in monospace, and small angle labels. Port every kind (offset, ninety, kick, saddle3, kick90, segmented, saddle4, rolling, wirefill) **1:1** using the platform's vector drawing (Compose `Canvas`/`DrawScope` on Android, SwiftUI `Canvas`/`Path` on iOS). Keep the 320×200 coordinate space and scale it uniformly to the card width. Labels use the same numeric formatting as the reference (`.toFixed(2)` + `"`, angle text).

### A9. Deliberate deviations (improvements over the web app)

1. **Keep inputs when coming back from the bender picker.** In the web app, opening the picker unmounts the detail screen and every input resets to defaults. In native, hold the detail state in the view-model / observable object for the active kind so values survive.
2. **Clamp the trade size to the selected bender.** If the current size is not supported by the chosen bender (e.g. 0.75 with the iToolco bender), switch to that bender's first supported size.
3. **ft-in carry fix**: if the inches part rounds up to 12, show `{feet+1}' 0"` instead of `12"`.
4. **mm mode input**: when the unit is mm, the keypad and slider operate in millimetres (convert to inches internally; readout shows mm). In `in` and `ft-in` the entry stays decimal inches, readout `X.XXX in`.
5. **"Clear all" asks for confirmation.**
6. **No network permission** (the Capacitor Android manifest had `INTERNET`; remove it).
7. Header save icon (a no-op in the web app) is not shown.

### A10. Golden tests (core module unit tests; tolerance 1e-9 unless noted)

Bender `K` = Klein (first), `G` = Greenlee. Results below were produced by running the original TypeScript engine.

| Call | Expected |
|---|---|
| offset(30, 4, K, 0.75) | distanceBetweenBends 8, travel 8, shrink 1.5, ok |
| offset(10, 1, K, 1) | distance 6, shrink 0.0625, ok |
| offset(45, 1, K, 0.75) | distance 1.4, shrink 0.375, **danger** |
| offset(22.5, 2, K, 0.75) | distance 5.2, shrink 0.5, **warn** |
| offset(30, 2, K, 0.75) | distance 4, shrink 0.75, **danger** |
| offset(30, 3, K, 0.75) | distance 6, shrink 1.125, **warn** |
| ninety(0.75, 12) | deduct 6, mark 6, ok |
| ninety(1, 9) | deduct 8, mark 1, **warn** |
| ninety(0.5, 4) | deduct 5, mark −1, **danger** |
| kick(45, 6, K, 0.75) | distanceToMark 8.4 (±1e-9), gain 2.25, ok |
| kick(45, 3, K, 0.75) | distanceToMark 4.2, gain 1.125, **warn** |
| kick(60, 2, K, 0.75) | distanceToMark 2.4, gain 0.5, **danger** |
| saddle3(3, K, 0.75) | centerToSide 7.5, totalGain 0.75, ok |
| saddle3(1, K, 0.75) | centerToSide 2.5, totalGain 0.25, **danger** |
| kick90(30, 4, 0.75, 18, K) | kickMark 8, deduct 6, stubMark 12, ok |
| kick90(45, 1, 0.75, 18, K) | kickMark 1.4, stubMark 12, **danger** |
| segmented(90, 24, 6) | anglePerShot 18, distanceBetweenShots 7.508854321931082, **warn** |
| segmented(90, 24, 8) | anglePerShot 12.857142857142858, distance 5.374294852958777, ok |
| segmented(90, 24, 1) | anglePerShot 90, **danger** |
| saddle4(3, 8, G, 1) | inner 8, outerFromInner 7.5, totalGain 0.75, ok |
| saddle4(1, 8, K, 0.75) | outerFromInner 2.5, totalGain 0.25, **warn** |
| rolling(30, 6, 4, K, 0.75) | trueOffset 7.211102550927978, rollAngle 33.690067525979785, distance 14.422205101855956, shrink 2.7041634565979917, ok |
| rolling(30, 0, 0, K, 0.75) | all 0, **danger** |
| wirefill(0.75, "12", 3) | conduitArea 0.533, total 0.0399, max 40, fill 7.4859287054409, ok |
| wirefill(0.5, "12", 9) | total 0.1197, fill 39.375, **warn** |
| wirefill(0.5, "12", 10) | total 0.133, fill 43.75, **danger** |
| wirefill(0.5, "8", 2) | max 31, fill 24.07894736842105, ok |
| wirefill(1, "1", 5) | fill 90.39351851851852, **danger** |

summarize() for the first results: offset(30,4) → `Marks 8.00" apart · shrink 1.500"`; ninety(0.75,12) → `Mark at 6.00" · deduct 6"`; kick(45,6) → `Mark at 8.40" · gain 2.250"`; saddle3(3) → `Side bends 7.50" from center · gain 0.750"`; kick90 → `Kick mark 8.00" from start · stub mark 12.00" from end`; segmented(90,24,6) → `6 shots at 18.0° · 7.51" apart`; saddle4(3,8) → `Inner 8.00" apart · outer 7.50" beyond each`; rolling → `True offset 7.21" · roll 33.7° · marks 14.42" apart`; wirefill → `3 × 12 AWG in 0.75" EMT · 7.5% fill`.

formatLength: `7.375 in`→`7 3/8"`; `30.5 ft-in`→`2' 6 1/2"`; `12 ft-in`→`1' 0"`; `7.375 mm`→`187 mm`; `0.3125 in`→`5/16"`; `-2.5 in`→`-2 1/2"`; `4.1875 mm, precision 3`→`106.362 mm`; NaN→`—`; `11.99 ft-in`→`1' 0"` (deviation 3; the web app printed `12"`).

### A11. Definition of done (both platforms)

- [ ] All 9 calculators work and match the golden tests and the reference screens.
- [ ] 3 tabs, bender picker, units, history persistence work offline after a cold start.
- [ ] All 9 diagrams drawn natively and recoloured by feasibility.
- [ ] No WebView / Capacitor / JS dependency anywhere. No network permission.
- [ ] Unit tests for the core module pass; app builds from a clean checkout.
- [ ] `.gitignore` excludes build output (see platform part).

---

## PART B — ANDROID (Kotlin + Jetpack Compose)

### B1. Decisions

| Topic | Decision |
|---|---|
| Language / UI | Kotlin, Jetpack Compose, Material 3 used only as a base (custom dark colour scheme from A7) |
| SDK | `minSdk 24`, `compileSdk 36`, `targetSdk 36` (same as the Capacitor project). Use the latest stable AGP, Gradle, Kotlin, Compose BOM that work together |
| Package / id | `com.bendpro.app` (keep the same applicationId so it can replace the old build) |
| Architecture | Single Activity, MVVM. `AppViewModel` holds persisted settings + history; `DetailState` per kind lives in a `DetailViewModel` scoped to the Bends tab so inputs survive the bender picker (A9.1) |
| Navigation | Sealed class `BendsRoute { Home, Detail(kind), BenderPicker(returnTo) }` held in state + `BackHandler`. No Navigation-Compose needed |
| Persistence | Jetpack **DataStore (Preferences)** storing one JSON string (kotlinx.serialization) of the Persisted object (A6) |
| Core module | Package `com.bendpro.core` (pure Kotlin, **no android.\* imports**): models, constants, `Calculations`, `Units`, `Benders`, `summarize` |
| Tests | JUnit 4/5 unit tests for `core` (golden tests A10). Optional Compose UI tests for Home → Detail → Save → History |
| Icons | Convert the SVG paths in the reference into `ImageVector`s (or VectorDrawable XML). No icon library needed |
| Fonts | Poppins `.ttf` in `res/font` (OFL) |
| Orientation | Do not lock; all screens must scroll |
| Permissions | None |

### B2. Folder layout (new project, next to the old one)

```
BendPro-Android/            <- new Android Studio project (Kotlin DSL: settings.gradle.kts, app/build.gradle.kts)
  reference-react/          <- copy of the old project's src/ + package.json (READ ONLY)
  app/src/main/java/com/bendpro/
    core/                   <- pure Kotlin
    data/                   <- DataStore repository
    ui/theme/  ui/components/  ui/screens/  ui/diagrams/
  app/src/test/java/com/bendpro/core/   <- golden tests
```

Reuse these assets from the old Capacitor project (`android/app/src/main/res`): launcher icons (`mipmap-*/ic_launcher*.png`, adaptive icon XML) and the splash image. Use the AndroidX SplashScreen API.

`.gitignore` must contain at least: `.gradle/`, `build/`, `app/build/`, `local.properties`, `.idea/`, `*.apk`, `*.aab`, `*.jks`, `*.keystore`, `captures/`.

### B3. Phase prompts (send one at a time; wait for "done" before the next)

**Prompt B0 — master context (send once at the start; re-send if the agent loses context)**

> You are building a native Android app (Kotlin + Jetpack Compose) that replaces an existing React/Capacitor app called BendPro. Read the whole document "BendPro native rewrite — Part A (shared spec)" and "Part B (Android)" first. The React source is in `reference-react/src` and is read-only; it is the source of truth. Do not add or remove features. Core logic must be pure Kotlin in `com.bendpro.core` with unit tests. We work in phases; after every phase print what you built, how to run it, which tests pass, and what remains. Ask before deviating from the spec.

**Prompt B1 — scaffold + core engine + tests (no UI)**

> Phase 1. Create the Android project `BendPro-Android` (Kotlin DSL, applicationId `com.bendpro.app`, minSdk 24, compile/target 36, Compose enabled) with the `.gitignore` from B2. Copy the old React `src/` and `package.json` into `reference-react/`. Implement `com.bendpro.core`: models (BendKind, Unit, Feasibility, Bender and one result class per kind), constants and benders exactly as in A2, all 9 calculators exactly as in A3, `summarize`, and `Units` (`formatLength`, `toFraction`, `parseToInches`) as in A4 including deviation A9.3. Write JUnit tests for every row of the golden table A10 and for formatLength examples. Do not build any UI yet. Done when `./gradlew testDebugUnitTest` passes.

**Prompt B2 — theme, shell, Home, bender picker, History, Settings, persistence**

> Phase 2. Build the dark theme from A7 (colours, shapes, Poppins). Implement the app shell with the 3-tab bottom navigation, the Bends route state machine (Home / Detail placeholder / BenderPicker) with `BackHandler`, the Home grid with all 9 cards and icons (A1), the bender picker (A5), the History screen (empty state, list, "Clear all" with a confirmation dialog) and the Settings screen (units, display toggle, about). Add DataStore persistence for unit, benderId, history, darkOptimized (A6) with safe fallback on corrupt data. The Detail route can show a placeholder title for now. Add the launcher icon and splash from the old project's resources. Done when the app runs on an emulator, tabs/units/bender selection survive a cold restart, and History can be cleared.

**Prompt B3 — Detail screen for the 4 core bends**

> Phase 3. Implement the Detail screen for `offset`, `ninety`, `kick`, `saddle3` following A5: bender row, CONDUIT chips (filtered by the bender, with deviation A9.2), INPUTS with the `ValueInput` component (collapsed row ↔ expanded keypad/slider, behaviour in A5, mm handling per A9.4), angle chips, MARKS ON CONDUIT and CALCULATIONS rows per the table, status pill, "Save to history" → "Saved ✓" and the history entry labels/summaries from A6. Hold the detail state in a ViewModel so inputs survive the bender picker (A9.1). Port the diagrams for these four kinds from `BendDiagram.tsx` into a Compose `Canvas` (A8) recoloured by feasibility. Add ViewModel unit tests for the save label/summary text. Done when each of the 4 screens matches the web app for the same inputs and saving appears in History.

**Prompt B4 — remaining 5 calculators + wire fill + diagrams**

> Phase 4. Add `kick90`, `segmented`, `saddle4`, `rolling`, and `wirefill` to the Detail screen: inputs (including the plain numeric fields with their rounding and min/max), marks/calculations rows, the wire-fill footnote, wire-fill chips (no bender row for wire fill), and their diagrams from `BendDiagram.tsx`. Save-to-history labels and summaries as in A6. Done when all 9 kinds work and match the golden numbers shown on screen.

**Prompt B5 — polish, QA, release**

> Phase 5. Run a parity pass screen by screen against `reference-react` and fix differences (spacing, typography, colours, text). Check: system back at every level, small phones (360dp wide) and large phones, font scale 130%, TalkBack labels for the status pill and icon buttons, rotating the device keeps inputs, no WebView or Capacitor classes, no INTERNET permission, `versionName 1.0`, release build config (R8 on, signing config read from `local.properties`/environment, never commit the keystore). Update `README.md` with build/run/test instructions and the checklist A11. Produce a final report listing any remaining differences from the web app.

### B4. Manual test checklist (run before shipping)

1. Offset 30°, rise 4 in, Klein 3/4" → marks 3" and 11", spacing 8", shrink 1 1/2".
2. 90° bend, stub 12", 3/4" → deduct 6", mark 6", gain 2.16 → shown `2 3/16"` (inches use 1/16" fractions).
3. Switch to iToolco: trade size jumps to 1" automatically; chips show 1", 1-1/4", 1-1/2".
4. Open the bender picker from a screen with edited inputs and come back: inputs are unchanged.
5. Units: IN → FT+IN → MM changes every displayed number; History entries keep the text they were saved with.
6. Save two bends, kill the app, reopen: both are listed newest first. Clear all → confirm → empty state.
7. Wire fill: 0.5" EMT, 12 AWG, 10 conductors → NOT POSSIBLE (43.8%).
8. Airplane mode: everything works.
