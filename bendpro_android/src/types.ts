export type BendKind = 'offset' | 'ninety' | 'kick' | 'saddle3' | 'kick90' | 'segmented' | 'saddle4' | 'rolling' | 'wirefill'

export type Unit = 'in' | 'ft-in' | 'mm'

export type FeasibilityLevel = 'ok' | 'warn' | 'danger'

export interface Bender {
  id: string
  brand: string
  model: string
  conduitSizesIn: number[] // nominal trade sizes supported, inches
  minShoeRadiusIn: Record<number, number> // trade size -> centerline radius (in)
}

export interface Feasibility {
  level: FeasibilityLevel
  message: string
}

export interface OffsetResult {
  kind: 'offset'
  angleDeg: number
  offsetIn: number
  distanceBetweenBendsIn: number
  travelIn: number
  shrinkIn: number
  feasibility: Feasibility
}

export interface NinetyResult {
  kind: 'ninety'
  tradeSizeIn: number
  stubHeightIn: number
  deductIn: number
  markIn: number
  feasibility: Feasibility
}

export interface KickResult {
  kind: 'kick'
  angleDeg: number
  riseIn: number
  distanceToMarkIn: number
  gainIn: number
  feasibility: Feasibility
}

export interface Saddle3Result {
  kind: 'saddle3'
  depthIn: number
  centerAngleDeg: number
  sideAngleDeg: number
  centerToSideIn: number
  totalGainIn: number
  feasibility: Feasibility
}

export interface Kick90Result {
  kind: 'kick90'
  angleDeg: number
  kickOffsetIn: number
  kickMarkIn: number
  tradeSizeIn: number
  stubHeightIn: number
  deductIn: number
  stubMarkIn: number
  feasibility: Feasibility
}

export interface SegmentedResult {
  kind: 'segmented'
  totalAngleDeg: number
  radiusIn: number
  shots: number
  anglePerShotDeg: number
  distanceBetweenShotsIn: number
  feasibility: Feasibility
}

export interface Saddle4Result {
  kind: 'saddle4'
  depthIn: number
  obstructionWidthIn: number
  sideAngleDeg: number
  innerSpacingIn: number
  outerFromInnerIn: number
  totalGainIn: number
  feasibility: Feasibility
}

export interface RollingOffsetResult {
  kind: 'rolling'
  angleDeg: number
  verticalIn: number
  horizontalIn: number
  trueOffsetIn: number
  rollAngleDeg: number
  distanceBetweenBendsIn: number
  shrinkIn: number
  feasibility: Feasibility
}

export type ConduitMaterial = 'EMT'

export interface WireFillResult {
  kind: 'wirefill'
  conduitMaterial: ConduitMaterial
  conduitSizeIn: number
  conduitAreaSqIn: number
  wireAwg: string
  wireAreaSqIn: number
  conductorCount: number
  totalConductorAreaSqIn: number
  maxFillPct: number
  fillPct: number
  feasibility: Feasibility
}

export type BendResult =
  | OffsetResult
  | NinetyResult
  | KickResult
  | Saddle3Result
  | Kick90Result
  | SegmentedResult
  | Saddle4Result
  | RollingOffsetResult
  | WireFillResult

export interface HistoryEntry {
  id: string
  kind: BendKind
  label: string
  createdAt: number
  inputSummary: string
  resultSummary: string
}
