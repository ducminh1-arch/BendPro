import type {
  Bender,
  BendResult,
  Feasibility,
  Kick90Result,
  KickResult,
  NinetyResult,
  OffsetResult,
  RollingOffsetResult,
  Saddle3Result,
  Saddle4Result,
  SegmentedResult,
  WireFillResult,
} from '../types'

/**
 * Standard offset/kick angle constants used across the trade:
 * multiplier = 1 / sin(angle)  -> distance between bend marks per inch of offset
 * shrinkPerInch = amount conduit "shrinks" per inch of offset at that angle
 */
const ANGLE_TABLE: Record<number, { multiplier: number; shrinkPerInch: number }> = {
  10: { multiplier: 6.0, shrinkPerInch: 1 / 16 },
  22.5: { multiplier: 2.6, shrinkPerInch: 1 / 4 },
  30: { multiplier: 2.0, shrinkPerInch: 3 / 8 },
  45: { multiplier: 1.4, shrinkPerInch: 3 / 8 },
  60: { multiplier: 1.2, shrinkPerInch: 1 / 4 },
}

export const OFFSET_ANGLES = [10, 22.5, 30, 45, 60]

// Standard 90° deduct (take-up) values in inches by nominal trade size.
const DEDUCT_TABLE: Record<number, number> = {
  0.5: 5,
  0.75: 6,
  1: 8,
  1.25: 11,
  1.5: 13,
  2: 17,
}

/**
 * Wire fill reference data — EMT only, THHN/THWN conductors only.
 * Approximate values drawn from the commonly published NEC Chapter 9 subset
 * (Table 4 internal area, Table 5 conductor area). Not verified against a
 * specific NEC edition — confirm against the current code year for real work.
 */
export const EMT_INTERNAL_AREA_SQIN: Record<number, number> = {
  0.5: 0.304,
  0.75: 0.533,
  1: 0.864,
  1.25: 1.496,
  1.5: 2.036,
  2: 3.356,
}
export const THHN_AREA_SQIN: Record<string, number> = {
  '14': 0.0097,
  '12': 0.0133,
  '10': 0.0211,
  '8': 0.0366,
  '6': 0.0507,
  '4': 0.0824,
  '3': 0.0973,
  '2': 0.1158,
  '1': 0.1562,
}
export const WIRE_AWG_OPTIONS = Object.keys(THHN_AREA_SQIN)

function angleConstants(angleDeg: number) {
  return ANGLE_TABLE[angleDeg] ?? ANGLE_TABLE[45]
}

function arcLengthIn(radiusIn: number, angleDeg: number): number {
  return radiusIn * (angleDeg * Math.PI / 180)
}

function shoeRadiusFor(bender: Bender, tradeSizeIn: number): number {
  return bender.minShoeRadiusIn[tradeSizeIn] ?? 4.0
}

function feasibilityFromRatio(spacing: number, minSpacing: number, comfySpacing: number): Feasibility {
  if (spacing <= 0 || spacing < minSpacing) {
    return { level: 'danger', message: 'Impossible — bends will overlap with this bender/shoe.' }
  }
  if (spacing < comfySpacing) {
    return { level: 'warn', message: 'Tight — double-check clearance before bending.' }
  }
  return { level: 'ok', message: 'Feasible with the selected bender.' }
}

export function calcOffset(
  angleDeg: number,
  offsetIn: number,
  bender: Bender,
  tradeSizeIn: number,
): OffsetResult {
  const { multiplier, shrinkPerInch } = angleConstants(angleDeg)
  const distanceBetweenBendsIn = offsetIn * multiplier
  const travelIn = distanceBetweenBendsIn
  const shrinkIn = shrinkPerInch * offsetIn

  const radius = shoeRadiusFor(bender, tradeSizeIn)
  const arc = arcLengthIn(radius, angleDeg)
  const feasibility = feasibilityFromRatio(distanceBetweenBendsIn, arc * 2, arc * 3)

  return { kind: 'offset', angleDeg, offsetIn, distanceBetweenBendsIn, travelIn, shrinkIn, feasibility }
}

export function calcNinety(
  tradeSizeIn: number,
  stubHeightIn: number,
): NinetyResult {
  const deductIn = DEDUCT_TABLE[tradeSizeIn] ?? 8
  const markIn = stubHeightIn - deductIn

  let feasibility: Feasibility
  if (markIn <= 0) {
    feasibility = { level: 'danger', message: 'Stub is shorter than the deduct — raise the stub height.' }
  } else if (markIn < 2) {
    feasibility = { level: 'warn', message: 'Very short mark — leaves little margin for error.' }
  } else {
    feasibility = { level: 'ok', message: 'Feasible with the selected bender.' }
  }

  return { kind: 'ninety', tradeSizeIn, stubHeightIn, deductIn, markIn, feasibility }
}

export function calcKick(
  angleDeg: number,
  riseIn: number,
  bender: Bender,
  tradeSizeIn: number,
): KickResult {
  const { multiplier, shrinkPerInch } = angleConstants(angleDeg)
  const distanceToMarkIn = riseIn * multiplier
  const gainIn = shrinkPerInch * riseIn

  const radius = shoeRadiusFor(bender, tradeSizeIn)
  const arc = arcLengthIn(radius, angleDeg)
  const feasibility = feasibilityFromRatio(distanceToMarkIn, arc, arc * 1.5)

  return { kind: 'kick', angleDeg, riseIn, distanceToMarkIn, gainIn, feasibility }
}

export function calcSaddle3(
  depthIn: number,
  bender: Bender,
  tradeSizeIn: number,
): Saddle3Result {
  const centerAngleDeg = 45
  const sideAngleDeg = 22.5
  // Standard trade approximation for a 45°-center / 22.5°-side, 3-point saddle.
  const centerToSideIn = depthIn * 2.5
  const totalGainIn = depthIn * 0.25

  const radius = shoeRadiusFor(bender, tradeSizeIn)
  const centerArc = arcLengthIn(radius, centerAngleDeg)
  const sideArc = arcLengthIn(radius, sideAngleDeg)
  const minSpacing = centerArc / 2 + sideArc
  const feasibility = feasibilityFromRatio(centerToSideIn, minSpacing, minSpacing * 1.6)

  return { kind: 'saddle3', depthIn, centerAngleDeg, sideAngleDeg, centerToSideIn, totalGainIn, feasibility }
}

export function calcKick90(
  angleDeg: number,
  kickOffsetIn: number,
  tradeSizeIn: number,
  stubHeightIn: number,
  bender: Bender,
): Kick90Result {
  const { multiplier } = angleConstants(angleDeg)
  const kickMarkIn = kickOffsetIn * multiplier
  const deductIn = DEDUCT_TABLE[tradeSizeIn] ?? 8
  const stubMarkIn = stubHeightIn - deductIn

  const radius = shoeRadiusFor(bender, tradeSizeIn)
  const kickArc = arcLengthIn(radius, angleDeg)

  let feasibility: Feasibility
  if (kickOffsetIn <= 0 || kickMarkIn < kickArc || stubMarkIn <= 0) {
    feasibility = { level: 'danger', message: 'Not possible — increase kick offset or stub length.' }
  } else if (kickMarkIn < kickArc * 1.5 || stubMarkIn < 2) {
    feasibility = { level: 'warn', message: 'Tight on one end — double-check clearance before bending.' }
  } else {
    feasibility = { level: 'ok', message: 'Feasible with the selected bender.' }
  }

  return { kind: 'kick90', angleDeg, kickOffsetIn, kickMarkIn, tradeSizeIn, stubHeightIn, deductIn, stubMarkIn, feasibility }
}

export function calcSegmented(
  totalAngleDeg: number,
  radiusIn: number,
  shots: number,
): SegmentedResult {
  const anglePerShotDeg = shots > 1 ? totalAngleDeg / (shots - 1) : totalAngleDeg
  const rad = (anglePerShotDeg * Math.PI) / 180
  const distanceBetweenShotsIn = 2 * radiusIn * Math.sin(rad / 2)

  let feasibility: Feasibility
  if (totalAngleDeg <= 0 || radiusIn <= 0 || shots < 2) {
    feasibility = { level: 'danger', message: 'Not possible — check angle, radius, and shot count.' }
  } else if (anglePerShotDeg > 15) {
    feasibility = { level: 'warn', message: 'More than ~15° per shot — the sweep will look faceted, add more shots.' }
  } else {
    feasibility = { level: 'ok', message: 'Feasible — smooth sweep with this shot count.' }
  }

  return { kind: 'segmented', totalAngleDeg, radiusIn, shots, anglePerShotDeg, distanceBetweenShotsIn, feasibility }
}

export function calcSaddle4(
  depthIn: number,
  obstructionWidthIn: number,
  bender: Bender,
  tradeSizeIn: number,
): Saddle4Result {
  const sideAngleDeg = 22.5
  // Standard trade approximation for a 4-point saddle, all bends at 22.5°:
  // inner pair spaced at the obstruction width, outer pair at depth × 2.5 beyond each inner mark.
  const innerSpacingIn = obstructionWidthIn
  const outerFromInnerIn = depthIn * 2.5
  const totalGainIn = depthIn * 0.25

  const radius = shoeRadiusFor(bender, tradeSizeIn)
  const sideArc = arcLengthIn(radius, sideAngleDeg)
  const feasibility = feasibilityFromRatio(outerFromInnerIn, sideArc, sideArc * 1.6)

  return { kind: 'saddle4', depthIn, obstructionWidthIn, sideAngleDeg, innerSpacingIn, outerFromInnerIn, totalGainIn, feasibility }
}

export function calcRollingOffset(
  angleDeg: number,
  verticalIn: number,
  horizontalIn: number,
  bender: Bender,
  tradeSizeIn: number,
): RollingOffsetResult {
  const { multiplier, shrinkPerInch } = angleConstants(angleDeg)
  const trueOffsetIn = Math.sqrt(verticalIn * verticalIn + horizontalIn * horizontalIn)
  const rollAngleDeg = (Math.atan2(horizontalIn, verticalIn) * 180) / Math.PI
  const distanceBetweenBendsIn = trueOffsetIn * multiplier
  const shrinkIn = shrinkPerInch * trueOffsetIn

  const radius = shoeRadiusFor(bender, tradeSizeIn)
  const arc = arcLengthIn(radius, angleDeg)
  const feasibility =
    verticalIn <= 0 && horizontalIn <= 0
      ? { level: 'danger' as const, message: 'Enter at least one of vertical or horizontal offset.' }
      : feasibilityFromRatio(distanceBetweenBendsIn, arc * 2, arc * 3)

  return { kind: 'rolling', angleDeg, verticalIn, horizontalIn, trueOffsetIn, rollAngleDeg, distanceBetweenBendsIn, shrinkIn, feasibility }
}

export function calcWireFill(
  conduitSizeIn: number,
  wireAwg: string,
  conductorCount: number,
): WireFillResult {
  const conduitAreaSqIn = EMT_INTERNAL_AREA_SQIN[conduitSizeIn] ?? EMT_INTERNAL_AREA_SQIN[0.75]
  const wireAreaSqIn = THHN_AREA_SQIN[wireAwg] ?? THHN_AREA_SQIN['12']
  const totalConductorAreaSqIn = wireAreaSqIn * conductorCount
  const maxFillPct = conductorCount === 1 ? 53 : conductorCount === 2 ? 31 : 40
  const fillPct = (totalConductorAreaSqIn / conduitAreaSqIn) * 100

  let feasibility: Feasibility
  if (conductorCount <= 0 || fillPct > maxFillPct) {
    feasibility = { level: 'danger', message: `Exceeds the ${maxFillPct}% NEC fill limit for ${conductorCount} conductor(s) — step up conduit size.` }
  } else if (fillPct > maxFillPct - 5) {
    feasibility = { level: 'warn', message: 'Close to the fill limit — little room for a mixed-size pull.' }
  } else {
    feasibility = { level: 'ok', message: 'Within the NEC fill limit.' }
  }

  return { kind: 'wirefill', conduitMaterial: 'EMT', conduitSizeIn, conduitAreaSqIn, wireAwg, wireAreaSqIn, conductorCount, totalConductorAreaSqIn, maxFillPct, fillPct, feasibility }
}

export function feasibilityColor(f: Feasibility): string {
  if (f.level === 'ok') return 'var(--ok)'
  if (f.level === 'warn') return 'var(--warn)'
  return 'var(--danger)'
}

export function summarize(result: BendResult): string {
  switch (result.kind) {
    case 'offset':
      return `Marks ${result.distanceBetweenBendsIn.toFixed(2)}" apart · shrink ${result.shrinkIn.toFixed(3)}"`
    case 'ninety':
      return `Mark at ${result.markIn.toFixed(2)}" · deduct ${result.deductIn}"`
    case 'kick':
      return `Mark at ${result.distanceToMarkIn.toFixed(2)}" · gain ${result.gainIn.toFixed(3)}"`
    case 'saddle3':
      return `Side bends ${result.centerToSideIn.toFixed(2)}" from center · gain ${result.totalGainIn.toFixed(3)}"`
    case 'kick90':
      return `Kick mark ${result.kickMarkIn.toFixed(2)}" from start · stub mark ${result.stubMarkIn.toFixed(2)}" from end`
    case 'segmented':
      return `${result.shots} shots at ${result.anglePerShotDeg.toFixed(1)}° · ${result.distanceBetweenShotsIn.toFixed(2)}" apart`
    case 'saddle4':
      return `Inner ${result.innerSpacingIn.toFixed(2)}" apart · outer ${result.outerFromInnerIn.toFixed(2)}" beyond each`
    case 'rolling':
      return `True offset ${result.trueOffsetIn.toFixed(2)}" · roll ${result.rollAngleDeg.toFixed(1)}° · marks ${result.distanceBetweenBendsIn.toFixed(2)}" apart`
    case 'wirefill':
      return `${result.conductorCount} × ${result.wireAwg} AWG in ${result.conduitSizeIn}" EMT · ${result.fillPct.toFixed(1)}% fill`
  }
}
