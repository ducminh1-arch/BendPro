import type { ReactNode } from 'react'
import type { BendResult } from '../types'
import { feasibilityColor } from '../lib/calculations'

interface Props {
  result: BendResult
}

const W = 320
const H = 200
const PIPE = 'var(--metal-200)'

function DimLine({ x1, y1, x2, y2, label }: { x1: number; y1: number; x2: number; y2: number; label: string }) {
  const midX = (x1 + x2) / 2
  const midY = (y1 + y2) / 2
  return (
    <g>
      <line x1={x1} y1={y1} x2={x2} y2={y2} stroke="var(--text-tertiary)" strokeWidth={1} strokeDasharray="3 3" />
      <line x1={x1} y1={y1 - 4} x2={x1} y2={y1 + 4} stroke="var(--text-tertiary)" strokeWidth={1} />
      <line x1={x2} y1={y2 - 4} x2={x2} y2={y2 + 4} stroke="var(--text-tertiary)" strokeWidth={1} />
      <text x={midX} y={midY - 8} textAnchor="middle" fontSize="11" fill="var(--text-secondary)" className="mono">
        {label}
      </text>
    </g>
  )
}

export default function BendDiagram({ result }: Props) {
  const color = feasibilityColor(result.feasibility)

  let body: ReactNode = null

  if (result.kind === 'offset') {
    const rise = 60
    const runL = 60
    const runR = 60
    const midRun = 100
    const x0 = 40
    const y0 = 150
    const x1 = x0 + runL
    const y1 = y0
    const x2 = x1 + midRun
    const y2 = y1 - rise
    const x3 = x2 + runR
    const y3 = y2
    body = (
      <g>
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3}`} fill="none" stroke={PIPE} strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" />
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3}`} fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        <circle cx={x1} cy={y1} r={3.5} fill={color} />
        <circle cx={x2} cy={y2} r={3.5} fill={color} />
        <DimLine x1={x1} y1={y1 + 20} x2={x2} y2={y2 + 20 + rise} label={`${result.distanceBetweenBendsIn.toFixed(2)}"`} />
        <text x={x1 - 6} y={y0 + 36} fontSize="10" fill="var(--text-tertiary)" className="mono">{result.angleDeg}°</text>
        <text x={x2 + 4} y={y2 + 36} fontSize="10" fill="var(--text-tertiary)" className="mono">{result.angleDeg}°</text>
      </g>
    )
  }

  if (result.kind === 'ninety') {
    const x0 = 60
    const y0 = 40
    const stubLen = 90
    const runLen = 140
    const x1 = x0
    const y1 = y0 + stubLen
    const x2 = x1 + runLen
    const y2 = y1
    const markY = y1 - Math.min(Math.max(result.markIn * 5, 10), stubLen - 6)
    body = (
      <g>
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2}`} fill="none" stroke={PIPE} strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" />
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2}`} fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        <circle cx={x1} cy={y1} r={3.5} fill={color} />
        <line x1={x0 - 14} y1={markY} x2={x0 + 14} y2={markY} stroke="var(--accent)" strokeWidth={2} />
        <text x={x0 + 20} y={markY + 4} fontSize="10" fill="var(--accent)" className="mono">mark</text>
        <DimLine x1={x0 - 26} y1={y0} x2={x0 - 26} y2={y1} label={`${result.stubHeightIn.toFixed(1)}"`} />
      </g>
    )
  }

  if (result.kind === 'kick') {
    const x0 = 40
    const y0 = 150
    const runL = 90
    const x1 = x0 + runL
    const y1 = y0
    const angRad = (result.angleDeg * Math.PI) / 180
    const legLen = 110
    const x2 = x1 + legLen * Math.cos(angRad)
    const y2 = y1 - legLen * Math.sin(angRad)
    body = (
      <g>
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2}`} fill="none" stroke={PIPE} strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" />
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2}`} fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        <circle cx={x1} cy={y1} r={3.5} fill={color} />
        <line x1={x1} y1={y1} x2={x1 + 40} y2={y1} stroke="var(--text-tertiary)" strokeDasharray="2 3" strokeWidth={1} />
        <text x={x1 + 6} y={y1 - 6} fontSize="10" fill="var(--text-tertiary)" className="mono">{result.angleDeg}°</text>
        <DimLine x1={x0} y1={y0 + 20} x2={x1} y2={y0 + 20} label={`${result.distanceToMarkIn.toFixed(2)}"`} />
      </g>
    )
  }

  if (result.kind === 'saddle3') {
    const x0 = 30
    const y0 = 150
    const runL = 60
    const rise = 40
    const x1 = x0 + runL
    const y1 = y0
    const x2 = x1 + 40
    const y2 = y1 - rise
    const x3 = x2 + 40
    const y3 = y2
    const x4 = x3 + 40
    const y4 = y0
    const x5 = x4 + 40
    const y5 = y0
    body = (
      <g>
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3} ${x4},${y4} ${x5},${y5}`} fill="none" stroke={PIPE} strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" />
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3} ${x4},${y4} ${x5},${y5}`} fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        <circle cx={x1} cy={y1} r={3} fill={color} />
        <circle cx={x2} cy={y2} r={3} fill={color} />
        <circle cx={x4} cy={y4} r={3} fill={color} />
        <DimLine x1={x1} y1={y1 + 18} x2={x2} y2={y1 + 18} label={`${result.centerToSideIn.toFixed(1)}"`} />
        <text x={(x2 + x3) / 2 - 10} y={y2 - 10} fontSize="10" fill="var(--text-tertiary)" className="mono">{result.depthIn.toFixed(1)}"</text>
      </g>
    )
  }

  if (result.kind === 'kick90') {
    const x0 = 40
    const y0 = 150
    const angRad = (result.angleDeg * Math.PI) / 180
    const kickLeg = 70
    const x1 = x0 + kickLeg * Math.cos(angRad)
    const y1 = y0 - kickLeg * Math.sin(angRad)
    const runLen = 90
    const x2 = x1 + runLen
    const y2 = y1
    const stubLen = 60
    const x3 = x2
    const y3 = y2 - stubLen
    body = (
      <g>
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3}`} fill="none" stroke={PIPE} strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" />
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3}`} fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        <circle cx={x0} cy={y0} r={3.5} fill={color} />
        <circle cx={x2} cy={y2} r={3.5} fill={color} />
        <text x={x0 + 4} y={y0 - 10} fontSize="10" fill="var(--text-tertiary)" className="mono">{result.angleDeg}°</text>
        <text x={x2 + 6} y={y2 + 14} fontSize="10" fill="var(--text-tertiary)" className="mono">90°</text>
        <DimLine x1={x0} y1={y0 + 20} x2={x1} y2={y0 + 20} label={`${result.kickMarkIn.toFixed(2)}"`} />
        <text x={x2 + 8} y={(y2 + y3) / 2} fontSize="10" fill="var(--text-secondary)" className="mono">{result.stubMarkIn.toFixed(2)}"</text>
      </g>
    )
  }

  if (result.kind === 'segmented') {
    const cx = 40
    const cy = 165
    const R = 100
    const n = Math.max(2, result.shots)
    const pts: [number, number][] = []
    for (let i = 0; i < n; i++) {
      const a = ((result.totalAngleDeg * i) / (n - 1)) * (Math.PI / 180)
      pts.push([cx + R * Math.sin(a), cy - R * (1 - Math.cos(a))])
    }
    body = (
      <g>
        <polyline points={pts.map((p) => p.join(',')).join(' ')} fill="none" stroke={PIPE} strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" />
        <polyline points={pts.map((p) => p.join(',')).join(' ')} fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        {pts.map((p, i) => (
          <circle key={i} cx={p[0]} cy={p[1]} r={3} fill={color} />
        ))}
        <text x={220} y={30} fontSize="10" fill="var(--text-tertiary)" className="mono">{result.totalAngleDeg}° sweep</text>
        <text x={220} y={44} fontSize="10" fill="var(--text-tertiary)" className="mono">{n} shots</text>
      </g>
    )
  }

  if (result.kind === 'saddle4') {
    const x0 = 20
    const y0 = 150
    const runL = 45
    const rise = 40
    const flat = 40
    const x1 = x0 + runL
    const y1 = y0
    const x2 = x1 + 35
    const y2 = y1 - rise
    const x3 = x2 + flat
    const y3 = y2
    const x4 = x3 + 35
    const y4 = y0
    const x5 = x4 + runL
    const y5 = y0
    body = (
      <g>
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3} ${x4},${y4} ${x5},${y5}`} fill="none" stroke={PIPE} strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" />
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3} ${x4},${y4} ${x5},${y5}`} fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        <circle cx={x1} cy={y1} r={3} fill={color} />
        <circle cx={x2} cy={y2} r={3} fill={color} />
        <circle cx={x3} cy={y3} r={3} fill={color} />
        <circle cx={x4} cy={y4} r={3} fill={color} />
        <DimLine x1={x2} y1={y2 - 16} x2={x3} y2={y3 - 16} label={`${result.innerSpacingIn.toFixed(1)}"`} />
        <DimLine x1={x1} y1={y1 + 18} x2={x2} y2={y1 + 18} label={`${result.outerFromInnerIn.toFixed(1)}"`} />
        <text x={(x2 + x3) / 2 - 8} y={y2 - 26} fontSize="10" fill="var(--text-tertiary)" className="mono">{result.depthIn.toFixed(1)}" deep</text>
      </g>
    )
  }

  if (result.kind === 'rolling') {
    const rise = 60
    const runL = 55
    const runR = 55
    const midRun = 90
    const x0 = 40
    const y0 = 150
    const x1 = x0 + runL
    const y1 = y0
    const x2 = x1 + midRun
    const y2 = y1 - rise
    const x3 = x2 + runR
    const y3 = y2
    body = (
      <g>
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3}`} fill="none" stroke={PIPE} strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" />
        <polyline points={`${x0},${y0} ${x1},${y1} ${x2},${y2} ${x3},${y3}`} fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        <circle cx={x1} cy={y1} r={3.5} fill={color} />
        <circle cx={x2} cy={y2} r={3.5} fill={color} />
        <DimLine x1={x1} y1={y1 + 20} x2={x2} y2={y2 + 20 + rise} label={`${result.distanceBetweenBendsIn.toFixed(2)}"`} />
        <text x={x1 - 6} y={y0 + 36} fontSize="10" fill="var(--text-tertiary)" className="mono">{result.angleDeg}°</text>
        <text x={220} y={30} fontSize="10" fill="var(--accent)" className="mono">roll {result.rollAngleDeg.toFixed(0)}°</text>
        <text x={220} y={44} fontSize="10" fill="var(--text-tertiary)" className="mono">true {result.trueOffsetIn.toFixed(1)}"</text>
      </g>
    )
  }

  if (result.kind === 'wirefill') {
    const barX = 30
    const barY = 90
    const barW = 260
    const barH = 26
    const fillW = Math.min(barW, (Math.max(0, result.fillPct) / 100) * barW)
    const limitX = barX + (result.maxFillPct / 100) * barW
    body = (
      <g>
        <rect x={barX} y={barY} width={barW} height={barH} rx={6} fill="#1c2128" stroke="var(--text-tertiary)" strokeWidth={1} />
        <rect x={barX} y={barY} width={fillW} height={barH} rx={6} fill={color} opacity={0.85} />
        <line x1={limitX} y1={barY - 8} x2={limitX} y2={barY + barH + 8} stroke="var(--text-secondary)" strokeWidth={1.5} strokeDasharray="3 3" />
        <text x={limitX} y={barY - 12} textAnchor="middle" fontSize="10" fill="var(--text-secondary)" className="mono">{result.maxFillPct}% limit</text>
        <text x={barX + barW / 2} y={barY + barH / 2 + 4} textAnchor="middle" fontSize="12" fill="var(--text-primary)" className="mono">{result.fillPct.toFixed(1)}%</text>
        <text x={barX} y={barY + barH + 28} fontSize="10" fill="var(--text-tertiary)" className="mono">{result.conductorCount} × {result.wireAwg} AWG THHN in {result.conduitSizeIn}" EMT</text>
      </g>
    )
  }

  return (
    <svg viewBox={`0 0 ${W} ${H}`} width="100%" height="100%" role="img" aria-label="Bend diagram">
      {body}
    </svg>
  )
}
