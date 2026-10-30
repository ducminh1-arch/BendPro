# BendPro — Conduit Bending Calc

A mobile-first conduit bending calculator, built as a React + TypeScript + Vite app.
UI restyled to a dark-navy, signal-blue theme with a home grid of bend types,
matching BendPro's App Store screenshot style.

## What's included

- **Home screen**: a grid of Core Bends (Offset, 90° Bend, 3-Point Saddle, Kick) and
  Advanced Bends (Kick + 90°, Multi-Shot — placeholders for a future update).
- **Bend detail screens**: bender selector row, INPUTS, MARKS ON CONDUIT, and
  CALCULATIONS sections, a live SVG bend diagram, and a compact VALID / CHECK /
  NOT POSSIBLE status pill — each with real centerline-radius trade formulas
  (multiplier/shrink tables by angle, standard 90° deduct table).
- **QuickCheck**: color-coded feasibility (green / amber / red) computed from the
  selected bender's shoe radius vs. the geometry of the bend.
- **Bender database**: 8 entries (Klein, Greenlee, Milwaukee, Ideal, Ridgid, iToolco,
  Current Tools, plus a Custom entry) with per-size centerline radii, opened from the
  bender-select row on any bend screen.
- **Two input styles**: tap a value row to expand into a number keypad or a
  press-and-slide touch slider.
- **Units**: inches, feet+inches, millimeters — switchable from Settings.
- **History**: saved calculations persisted locally (localStorage), newest first.
- **Mobile app shell**: 3-tab bottom navigation (Bends / History / Settings), dark,
  high-contrast, large tap targets.

## Running it

This project was built without network access, so dependencies are **not** installed yet.
From this folder:

```bash
npm install
npm run dev      # local dev server
npm run build    # production build to dist/
```

Requires Node 18+.

## Project structure

```
src/
  App.tsx                    shell + tab routing + persisted state
  App.css / index.css        design tokens + component styles
  types.ts                   shared TypeScript types
  data/benders.ts            bender database
  lib/calculations.ts        bend math (offset, 90°, kick, 3-point saddle)
  lib/units.ts                unit conversion + formatting
  components/
    HomeHeader / DetailHeader   headers for the home grid vs. bend-detail screens
    BenderSelectRow             tappable bender + trade-size summary row
    BendDiagram                 live SVG bend diagram
    StatusPill                  compact VALID / CHECK / NOT POSSIBLE pill
    ValueInput                  collapsible numeric row (keypad or slider)
    BottomNav                   3-tab bottom navigation
  screens/
    HomeScreen                  Core / Advanced bend grid
    BendsTab                    home ⇄ detail ⇄ bender-picker sub-router
    BendDetailScreen            inputs, marks, calculations, diagram, status pill
    BendersScreen                bender picker
    HistoryScreen / SettingsScreen
```

## Notes on the math

Offset/kick use standard trade multiplier and shrink-per-inch constants for 10°, 22.5°,
30°, 45°, 60°. The 90° bend uses a standard deduct table by trade size, with an
approximated gain value. The 3-point saddle uses a common 45°-center / 22.5°-side
approximation. These are widely used field approximations — always verify critical
dimensions against your bender's own documentation before cutting conduit to length.
