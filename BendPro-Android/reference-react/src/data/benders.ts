import type { Bender } from '../types'

// Centerline bend radii (inches) per nominal EMT/rigid trade size, by shoe.
// Representative values drawn from published manufacturer bender spec sheets.
export const BENDERS: Bender[] = [
  {
    id: 'klein-emt-standard',
    brand: 'Klein Tools',
    model: 'EMT Bender (1/2–1")',
    conduitSizesIn: [0.5, 0.75, 1],
    minShoeRadiusIn: { 0.5: 4.0, 0.75: 4.5, 1: 5.75 },
  },
  {
    id: 'greenlee-855',
    brand: 'Greenlee',
    model: '855 Series (1/2–1-1/4")',
    conduitSizesIn: [0.5, 0.75, 1, 1.25],
    minShoeRadiusIn: { 0.5: 4.0, 0.75: 4.5, 1: 5.75, 1.25: 7.0 },
  },
  {
    id: 'milwaukee-emt',
    brand: 'Milwaukee',
    model: 'EMT Bender (1/2–1")',
    conduitSizesIn: [0.5, 0.75, 1],
    minShoeRadiusIn: { 0.5: 4.0, 0.75: 4.5, 1: 5.75 },
  },
  {
    id: 'ideal-imc-rigid',
    brand: 'Ideal Industries',
    model: 'IMC/Rigid Bender (1/2–1")',
    conduitSizesIn: [0.5, 0.75, 1],
    minShoeRadiusIn: { 0.5: 4.5, 0.75: 5.25, 1: 6.5 },
  },
  {
    id: 'ridgid-emt',
    brand: 'Ridgid',
    model: 'EMT Bender (1/2–1")',
    conduitSizesIn: [0.5, 0.75, 1],
    minShoeRadiusIn: { 0.5: 4.0, 0.75: 4.5, 1: 5.75 },
  },
  {
    id: 'itoolco-mega-1-1.5',
    brand: 'iToolco',
    model: 'Mega Bender (1–1-1/2")',
    conduitSizesIn: [1, 1.25, 1.5],
    minShoeRadiusIn: { 1: 5.75, 1.25: 7.0, 1.5: 8.25 },
  },
  {
    id: 'current-tools-1000',
    brand: 'Current Tools',
    model: '1000 Series (1/2–1")',
    conduitSizesIn: [0.5, 0.75, 1],
    minShoeRadiusIn: { 0.5: 4.0, 0.75: 4.5, 1: 5.75 },
  },
  {
    id: 'custom',
    brand: 'Custom',
    model: 'Add your own',
    conduitSizesIn: [0.5, 0.75, 1, 1.25, 1.5, 2],
    minShoeRadiusIn: { 0.5: 4.0, 0.75: 4.5, 1: 5.75, 1.25: 7.0, 1.5: 8.25, 2: 9.5 },
  },
]

export const TRADE_SIZES_IN = [0.5, 0.75, 1, 1.25, 1.5, 2]

export function tradeSizeLabel(sizeIn: number): string {
  const map: Record<number, string> = {
    0.5: '1/2"',
    0.75: '3/4"',
    1: '1"',
    1.25: '1-1/4"',
    1.5: '1-1/2"',
    2: '2"',
  }
  return map[sizeIn] ?? `${sizeIn}"`
}
