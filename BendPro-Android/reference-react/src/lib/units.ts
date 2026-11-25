import type { Unit } from '../types'

const MM_PER_IN = 25.4

/** Format a value stored internally in inches into the display unit. */
export function formatLength(valueIn: number, unit: Unit, precision = 2): string {
  if (!isFinite(valueIn)) return '—'
  const sign = valueIn < 0 ? '-' : ''
  const abs = Math.abs(valueIn)

  if (unit === 'mm') {
    return `${sign}${(abs * MM_PER_IN).toFixed(precision === 2 ? 0 : precision)} mm`
  }

  if (unit === 'ft-in') {
    const totalIn = abs
    const feet = Math.floor(totalIn / 12)
    const inches = totalIn - feet * 12
    const inchStr = toFraction(inches)
    if (feet > 0) return `${sign}${feet}' ${inchStr}"`
    return `${sign}${inchStr}"`
  }

  // default: inches, as a friendly fraction
  return `${sign}${toFraction(abs)}"`
}

/** Round to nearest 1/16 and render as a mixed fraction, e.g. 7.375 -> 7 3/8 */
export function toFraction(value: number): string {
  const whole = Math.floor(value)
  const frac = value - whole
  const sixteenths = Math.round(frac * 16)

  if (sixteenths === 0) return `${whole}`
  if (sixteenths === 16) return `${whole + 1}`

  let num = sixteenths
  let den = 16
  while (num % 2 === 0 && den % 2 === 0) {
    num /= 2
    den /= 2
  }
  return whole > 0 ? `${whole} ${num}/${den}` : `${num}/${den}`
}

/** Parse a user-entered numeric string (in the active unit) into inches. */
export function parseToInches(raw: string, unit: Unit): number {
  const cleaned = raw.trim()
  if (!cleaned) return 0
  const n = parseFloat(cleaned)
  if (isNaN(n)) return 0
  if (unit === 'mm') return n / MM_PER_IN
  return n // 'in' and 'ft-in' entry pads work directly in decimal inches for simplicity
}

export const UNIT_LABEL: Record<Unit, string> = {
  in: 'IN',
  'ft-in': 'FT+IN',
  mm: 'MM',
}
