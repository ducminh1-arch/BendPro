import SwiftUI
import BendProCore

public struct BendDiagramView: View {
    public let result: BendResult

    public init(result: BendResult) {
        self.result = result
    }

    private var feasibilityCol: Color {
        switch result.feasibility.level {
        case .ok:
            return Color.colorOk
        case .warn:
            return Color.colorWarn
        case .danger:
            return Color.colorDanger
        }
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / 320.0, geo.size.height / 200.0)
            let offsetX = (geo.size.width - 320.0 * scale) / 2.0
            let offsetY = (geo.size.height - 200.0 * scale) / 2.0

            ZStack(alignment: .topLeading) {
                diagramContent(for: result)
            }
            .frame(width: 320, height: 200)
            .scaleEffect(scale)
            .offset(x: offsetX, y: offsetY)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color.bgInset)
        .cornerRadius(AppRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(Color.lineSoft, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func diagramContent(for result: BendResult) -> some View {
        switch result {
        case let r as OffsetResult:
            OffsetDiagramView(result: r, color: feasibilityCol)
        case let r as NinetyResult:
            NinetyDiagramView(result: r, color: feasibilityCol)
        case let r as KickResult:
            KickDiagramView(result: r, color: feasibilityCol)
        case let r as Saddle3Result:
            Saddle3DiagramView(result: r, color: feasibilityCol)
        case let r as Kick90Result:
            Kick90DiagramView(result: r, color: feasibilityCol)
        case let r as SegmentedResult:
            SegmentedDiagramView(result: r, color: feasibilityCol)
        case let r as Saddle4Result:
            Saddle4DiagramView(result: r, color: feasibilityCol)
        case let r as RollingOffsetResult:
            RollingDiagramView(result: r, color: feasibilityCol)
        case let r as WireFillResult:
            WireFillDiagramView(result: r, color: feasibilityCol)
        default:
            EmptyView()
        }
    }
}

// MARK: - Dimension Line Component

public struct DimLineView: View {
    public let x1: CGFloat
    public let y1: CGFloat
    public let x2: CGFloat
    public let y2: CGFloat
    public let label: String

    public var body: some View {
        let midX = (x1 + x2) / 2.0
        let midY = (y1 + y2) / 2.0

        ZStack(alignment: .topLeading) {
            Path { p in
                p.move(to: CGPoint(x: x1, y: y1))
                p.addLine(to: CGPoint(x: x2, y: y2))
            }
            .stroke(Color.textTertiary, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

            Path { p in
                p.move(to: CGPoint(x: x1, y: y1 - 4))
                p.addLine(to: CGPoint(x: x1, y: y1 + 4))
            }
            .stroke(Color.textTertiary, lineWidth: 1)

            Path { p in
                p.move(to: CGPoint(x: x2, y: y2 - 4))
                p.addLine(to: CGPoint(x: x2, y: y2 + 4))
            }
            .stroke(Color.textTertiary, lineWidth: 1)

            Text(label)
                .font(.appMono(size: 11))
                .foregroundColor(.textSecondary)
                .position(x: midX, y: midY - 8)
        }
    }
}

// MARK: - Core 4 Diagrams

public struct OffsetDiagramView: View {
    public let result: OffsetResult
    public let color: Color

    public var body: some View {
        let rise: CGFloat = 60
        let runL: CGFloat = 60
        let runR: CGFloat = 60
        let midRun: CGFloat = 100
        let x0: CGFloat = 40
        let y0: CGFloat = 150
        let x1: CGFloat = x0 + runL
        let y1: CGFloat = y0
        let x2: CGFloat = x1 + midRun
        let y2: CGFloat = y1 - rise
        let x3: CGFloat = x2 + runR
        let y3: CGFloat = y2

        let polyline = Path { p in
            p.move(to: CGPoint(x: x0, y: y0))
            p.addLine(to: CGPoint(x: x1, y: y1))
            p.addLine(to: CGPoint(x: x2, y: y2))
            p.addLine(to: CGPoint(x: x3, y: y3))
        }

        ZStack(alignment: .topLeading) {
            polyline
                .stroke(Color.metal200, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            polyline
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .position(x: x1, y: y1)

            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .position(x: x2, y: y2)

            DimLineView(
                x1: x1,
                y1: y1 + 20,
                x2: x2,
                y2: y2 + 20 + rise,
                label: String(format: "%.2f\"", result.distanceBetweenBendsIn)
            )

            Text("\(formatAngle(result.angleDeg))°")
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: x1 - 6, y: y0 + 36)

            Text("\(formatAngle(result.angleDeg))°")
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: x2 + 4, y: y2 + 36)
        }
    }
}

public struct NinetyDiagramView: View {
    public let result: NinetyResult
    public let color: Color

    public var body: some View {
        let x0: CGFloat = 60
        let y0: CGFloat = 40
        let stubLen: CGFloat = 90
        let runLen: CGFloat = 140
        let x1: CGFloat = x0
        let y1: CGFloat = y0 + stubLen
        let x2: CGFloat = x1 + runLen
        let y2: CGFloat = y1
        let markY: CGFloat = y1 - min(max(CGFloat(result.markIn) * 5.0, 10.0), stubLen - 6.0)

        let polyline = Path { p in
            p.move(to: CGPoint(x: x0, y: y0))
            p.addLine(to: CGPoint(x: x1, y: y1))
            p.addLine(to: CGPoint(x: x2, y: y2))
        }

        ZStack(alignment: .topLeading) {
            polyline
                .stroke(Color.metal200, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            polyline
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .position(x: x1, y: y1)

            // Mark line
            Path { p in
                p.move(to: CGPoint(x: x0 - 14, y: markY))
                p.addLine(to: CGPoint(x: x0 + 14, y: markY))
            }
            .stroke(Color.accent, lineWidth: 2)

            Text("mark")
                .font(.appMono(size: 10))
                .foregroundColor(.accent)
                .position(x: x0 + 34, y: markY)

            DimLineView(
                x1: x0 - 26,
                y1: y0,
                x2: x0 - 26,
                y2: y1,
                label: String(format: "%.1f\"", result.stubHeightIn)
            )
        }
    }
}

public struct KickDiagramView: View {
    public let result: KickResult
    public let color: Color

    public var body: some View {
        let x0: CGFloat = 40
        let y0: CGFloat = 150
        let runL: CGFloat = 90
        let x1: CGFloat = x0 + runL
        let y1: CGFloat = y0
        let angRad = (result.angleDeg * .pi) / 180.0
        let legLen: CGFloat = 110.0
        let x2: CGFloat = x1 + legLen * CGFloat(cos(angRad))
        let y2: CGFloat = y1 - legLen * CGFloat(sin(angRad))

        let polyline = Path { p in
            p.move(to: CGPoint(x: x0, y: y0))
            p.addLine(to: CGPoint(x: x1, y: y1))
            p.addLine(to: CGPoint(x: x2, y: y2))
        }

        ZStack(alignment: .topLeading) {
            polyline
                .stroke(Color.metal200, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            polyline
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .position(x: x1, y: y1)

            Path { p in
                p.move(to: CGPoint(x: x1, y: y1))
                p.addLine(to: CGPoint(x: x1 + 40, y: y1))
            }
            .stroke(Color.textTertiary, style: StrokeStyle(lineWidth: 1, dash: [2, 3]))

            Text("\(formatAngle(result.angleDeg))°")
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: x1 + 16, y: y1 - 10)

            DimLineView(
                x1: x0,
                y1: y0 + 20,
                x2: x1,
                y2: y0 + 20,
                label: String(format: "%.2f\"", result.distanceToMarkIn)
            )
        }
    }
}

public struct Saddle3DiagramView: View {
    public let result: Saddle3Result
    public let color: Color

    public var body: some View {
        let x0: CGFloat = 30
        let y0: CGFloat = 150
        let runL: CGFloat = 60
        let rise: CGFloat = 40
        let x1: CGFloat = x0 + runL
        let y1: CGFloat = y0
        let x2: CGFloat = x1 + 40
        let y2: CGFloat = y1 - rise
        let x3: CGFloat = x2 + 40
        let y3: CGFloat = y2
        let x4: CGFloat = x3 + 40
        let y4: CGFloat = y0
        let x5: CGFloat = x4 + 40
        let y5: CGFloat = y0

        let polyline = Path { p in
            p.move(to: CGPoint(x: x0, y: y0))
            p.addLine(to: CGPoint(x: x1, y: y1))
            p.addLine(to: CGPoint(x: x2, y: y2))
            p.addLine(to: CGPoint(x: x3, y: y3))
            p.addLine(to: CGPoint(x: x4, y: y4))
            p.addLine(to: CGPoint(x: x5, y: y5))
        }

        ZStack(alignment: .topLeading) {
            polyline
                .stroke(Color.metal200, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            polyline
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .position(x: x1, y: y1)

            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .position(x: x2, y: y2)

            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .position(x: x4, y: y4)

            DimLineView(
                x1: x1,
                y1: y1 + 18,
                x2: x2,
                y2: y1 + 18,
                label: String(format: "%.1f\"", result.centerToSideIn)
            )

            Text(String(format: "%.1f\"", result.depthIn))
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: (x2 + x3) / 2.0, y: y2 - 10)
        }
    }
}

// MARK: - Advanced Diagrams (kick90, segmented, saddle4, rolling, wirefill)

public struct Kick90DiagramView: View {
    public let result: Kick90Result
    public let color: Color

    public var body: some View {
        let x0: CGFloat = 40
        let y0: CGFloat = 150
        let angRad = (result.angleDeg * .pi) / 180.0
        let kickLeg: CGFloat = 70
        let x1: CGFloat = x0 + kickLeg * CGFloat(cos(angRad))
        let y1: CGFloat = y0 - kickLeg * CGFloat(sin(angRad))
        let runLen: CGFloat = 90
        let x2: CGFloat = x1 + runLen
        let y2: CGFloat = y1
        let stubLen: CGFloat = 60
        let x3: CGFloat = x2
        let y3: CGFloat = y2 - stubLen

        let polyline = Path { p in
            p.move(to: CGPoint(x: x0, y: y0))
            p.addLine(to: CGPoint(x: x1, y: y1))
            p.addLine(to: CGPoint(x: x2, y: y2))
            p.addLine(to: CGPoint(x: x3, y: y3))
        }

        ZStack(alignment: .topLeading) {
            polyline
                .stroke(Color.metal200, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            polyline
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .position(x: x0, y: y0)

            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .position(x: x2, y: y2)

            Text("\(formatAngle(result.angleDeg))°")
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: x0 + 16, y: y0 - 10)

            Text("90°")
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: x2 + 14, y: y2 + 14)

            DimLineView(
                x1: x0,
                y1: y0 + 20,
                x2: x1,
                y2: y0 + 20,
                label: String(format: "%.2f\"", result.kickMarkIn)
            )

            Text(String(format: "%.2f\"", result.stubMarkIn))
                .font(.appMono(size: 10))
                .foregroundColor(.textSecondary)
                .position(x: x2 + 20, y: (y2 + y3) / 2.0)
        }
    }
}

public struct SegmentedDiagramView: View {
    public let result: SegmentedResult
    public let color: Color

    public var body: some View {
        let cx: CGFloat = 40
        let cy: CGFloat = 165
        let R: CGFloat = 100
        let n = max(2, result.shots)

        let pts: [CGPoint] = (0..<n).map { i in
            let a = ((result.totalAngleDeg * Double(i)) / Double(n - 1)) * (.pi / 180.0)
            return CGPoint(x: cx + R * CGFloat(sin(a)), y: cy - R * CGFloat(1.0 - cos(a)))
        }

        let polyline = Path { p in
            if let first = pts.first {
                p.move(to: first)
                for pt in pts.dropFirst() {
                    p.addLine(to: pt)
                }
            }
        }

        ZStack(alignment: .topLeading) {
            polyline
                .stroke(Color.metal200, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            polyline
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            ForEach(0..<pts.count, id: \.self) { idx in
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .position(pts[idx])
            }

            Text("\(formatAngle(result.totalAngleDeg))° sweep")
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: 250, y: 30)

            Text("\(n) shots")
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: 250, y: 44)
        }
    }
}

public struct Saddle4DiagramView: View {
    public let result: Saddle4Result
    public let color: Color

    public var body: some View {
        let x0: CGFloat = 20
        let y0: CGFloat = 150
        let runL: CGFloat = 45
        let rise: CGFloat = 40
        let flat: CGFloat = 40
        let x1: CGFloat = x0 + runL
        let y1: CGFloat = y0
        let x2: CGFloat = x1 + 35
        let y2: CGFloat = y1 - rise
        let x3: CGFloat = x2 + flat
        let y3: CGFloat = y2
        let x4: CGFloat = x3 + 35
        let y4: CGFloat = y0
        let x5: CGFloat = x4 + runL
        let y5: CGFloat = y0

        let polyline = Path { p in
            p.move(to: CGPoint(x: x0, y: y0))
            p.addLine(to: CGPoint(x: x1, y: y1))
            p.addLine(to: CGPoint(x: x2, y: y2))
            p.addLine(to: CGPoint(x: x3, y: y3))
            p.addLine(to: CGPoint(x: x4, y: y4))
            p.addLine(to: CGPoint(x: x5, y: y5))
        }

        ZStack(alignment: .topLeading) {
            polyline
                .stroke(Color.metal200, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            polyline
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            Circle().fill(color).frame(width: 6, height: 6).position(x: x1, y: y1)
            Circle().fill(color).frame(width: 6, height: 6).position(x: x2, y: y2)
            Circle().fill(color).frame(width: 6, height: 6).position(x: x3, y: y3)
            Circle().fill(color).frame(width: 6, height: 6).position(x: x4, y: y4)

            DimLineView(x1: x2, y1: y2 - 16, x2: x3, y2: y3 - 16, label: String(format: "%.1f\"", result.innerSpacingIn))
            DimLineView(x1: x1, y1: y1 + 18, x2: x2, y2: y1 + 18, label: String(format: "%.1f\"", result.outerFromInnerIn))

            Text(String(format: "%.1f\" deep", result.depthIn))
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: (x2 + x3) / 2.0, y: y2 - 26)
        }
    }
}

public struct RollingDiagramView: View {
    public let result: RollingOffsetResult
    public let color: Color

    public var body: some View {
        let rise: CGFloat = 60
        let runL: CGFloat = 55
        let runR: CGFloat = 55
        let midRun: CGFloat = 90
        let x0: CGFloat = 40
        let y0: CGFloat = 150
        let x1: CGFloat = x0 + runL
        let y1: CGFloat = y0
        let x2: CGFloat = x1 + midRun
        let y2: CGFloat = y1 - rise
        let x3: CGFloat = x2 + runR
        let y3: CGFloat = y2

        let polyline = Path { p in
            p.move(to: CGPoint(x: x0, y: y0))
            p.addLine(to: CGPoint(x: x1, y: y1))
            p.addLine(to: CGPoint(x: x2, y: y2))
            p.addLine(to: CGPoint(x: x3, y: y3))
        }

        ZStack(alignment: .topLeading) {
            polyline
                .stroke(Color.metal200, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

            polyline
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            Circle().fill(color).frame(width: 7, height: 7).position(x: x1, y: y1)
            Circle().fill(color).frame(width: 7, height: 7).position(x: x2, y: y2)

            DimLineView(x1: x1, y1: y1 + 20, x2: x2, y2: y2 + 20 + rise, label: String(format: "%.2f\"", result.distanceBetweenBendsIn))

            Text("\(formatAngle(result.angleDeg))°")
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: x1 - 6, y: y0 + 36)

            Text(String(format: "roll %.0f°", result.rollAngleDeg))
                .font(.appMono(size: 10))
                .foregroundColor(.accent)
                .position(x: 250, y: 30)

            Text(String(format: "true %.1f\"", result.trueOffsetIn))
                .font(.appMono(size: 10))
                .foregroundColor(.textTertiary)
                .position(x: 250, y: 44)
        }
    }
}

public struct WireFillDiagramView: View {
    public let result: WireFillResult
    public let color: Color

    public var body: some View {
        let barX: CGFloat = 30
        let barY: CGFloat = 90
        let barW: CGFloat = 260
        let barH: CGFloat = 26
        let fillW = min(barW, CGFloat(max(0.0, result.fillPct) / 100.0) * barW)
        let limitX = barX + CGFloat(result.maxFillPct / 100.0) * barW

        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: 0x1C2128))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.textTertiary, lineWidth: 1)
                )
                .frame(width: barW, height: barH)
                .position(x: barX + barW / 2.0, y: barY + barH / 2.0)

            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.85))
                .frame(width: fillW, height: barH)
                .position(x: barX + fillW / 2.0, y: barY + barH / 2.0)

            Path { p in
                p.move(to: CGPoint(x: limitX, y: barY - 8))
                p.addLine(to: CGPoint(x: limitX, y: barY + barH + 8))
            }
            .stroke(Color.textSecondary, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
        }
    }
}
