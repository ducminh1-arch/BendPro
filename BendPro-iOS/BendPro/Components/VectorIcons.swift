import SwiftUI
import BendProCore

// MARK: - 9 Calculator Icons (24x24 coordinate space)

public struct OffsetIconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 4.0 * sx, y: 19.0 * sy))
        p.addLine(to: CGPoint(x: 8.0 * sx, y: 19.0 * sy))
        p.addLine(to: CGPoint(x: 14.0 * sx, y: 9.0 * sy))
        p.addLine(to: CGPoint(x: 18.0 * sx, y: 9.0 * sy))
        p.addLine(to: CGPoint(x: 22.0 * sx, y: 3.0 * sy))
        return p
    }
}

public struct NinetyIconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 6.0 * sx, y: 4.0 * sy))
        p.addLine(to: CGPoint(x: 6.0 * sx, y: 14.0 * sy))
        // arc to (10, 18) radius 4
        p.addQuadCurve(
            to: CGPoint(x: 10.0 * sx, y: 18.0 * sy),
            control: CGPoint(x: 6.0 * sx, y: 18.0 * sy)
        )
        p.addLine(to: CGPoint(x: 19.0 * sx, y: 18.0 * sy))
        return p
    }
}

public struct Saddle3IconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        // M3 17 c2 0 2-9 5-9 s2 6 4 6 1-6 4-6 3 9 5 9
        p.move(to: CGPoint(x: 3.0 * sx, y: 17.0 * sy))
        p.addCurve(
            to: CGPoint(x: 8.0 * sx, y: 8.0 * sy),
            control1: CGPoint(x: 5.0 * sx, y: 17.0 * sy),
            control2: CGPoint(x: 5.0 * sx, y: 8.0 * sy)
        )
        p.addCurve(
            to: CGPoint(x: 12.0 * sx, y: 14.0 * sy),
            control1: CGPoint(x: 10.0 * sx, y: 8.0 * sy),
            control2: CGPoint(x: 10.0 * sx, y: 14.0 * sy)
        )
        p.addCurve(
            to: CGPoint(x: 16.0 * sx, y: 8.0 * sy),
            control1: CGPoint(x: 13.0 * sx, y: 8.0 * sy),
            control2: CGPoint(x: 15.0 * sx, y: 8.0 * sy)
        )
        p.addCurve(
            to: CGPoint(x: 21.0 * sx, y: 17.0 * sy),
            control1: CGPoint(x: 19.0 * sx, y: 17.0 * sy),
            control2: CGPoint(x: 19.0 * sx, y: 17.0 * sy)
        )
        return p
    }
}

public struct KickIconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 4.0 * sx, y: 19.0 * sy))
        p.addLine(to: CGPoint(x: 10.0 * sx, y: 19.0 * sy))
        p.addLine(to: CGPoint(x: 20.0 * sx, y: 5.0 * sy))
        return p
    }
}

public struct Kick90IconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 4.0 * sx, y: 19.0 * sy))
        p.addLine(to: CGPoint(x: 9.0 * sx, y: 19.0 * sy))
        p.addLine(to: CGPoint(x: 15.0 * sx, y: 10.0 * sy))
        p.addQuadCurve(
            to: CGPoint(x: 19.0 * sx, y: 6.0 * sy),
            control: CGPoint(x: 15.0 * sx, y: 6.0 * sy)
        )
        p.addLine(to: CGPoint(x: 20.0 * sx, y: 6.0 * sy))
        return p
    }
}

public struct SegmentedIconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 4.0 * sx, y: 5.0 * sy))
        p.addLine(to: CGPoint(x: 20.0 * sx, y: 5.0 * sy))
        p.move(to: CGPoint(x: 4.0 * sx, y: 10.5 * sy))
        p.addLine(to: CGPoint(x: 20.0 * sx, y: 10.5 * sy))
        p.move(to: CGPoint(x: 4.0 * sx, y: 16.0 * sy))
        p.addLine(to: CGPoint(x: 14.0 * sx, y: 16.0 * sy))
        p.move(to: CGPoint(x: 4.0 * sx, y: 21.0 * sy))
        p.addLine(to: CGPoint(x: 10.0 * sx, y: 21.0 * sy))
        return p
    }
}

public struct Saddle4IconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 3.0 * sx, y: 17.0 * sy))
        p.addCurve(
            to: CGPoint(x: 7.5 * sx, y: 9.0 * sy),
            control1: CGPoint(x: 5.0 * sx, y: 17.0 * sy),
            control2: CGPoint(x: 5.0 * sx, y: 9.0 * sy)
        )
        p.addLine(to: CGPoint(x: 16.5 * sx, y: 9.0 * sy))
        p.addCurve(
            to: CGPoint(x: 21.0 * sx, y: 17.0 * sy),
            control1: CGPoint(x: 19.0 * sx, y: 9.0 * sy),
            control2: CGPoint(x: 19.0 * sx, y: 17.0 * sy)
        )
        return p
    }
}

public struct RollingIconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 4.0 * sx, y: 20.0 * sy))
        p.addCurve(
            to: CGPoint(x: 12.0 * sx, y: 4.0 * sy),
            control1: CGPoint(x: 8.0 * sx, y: 20.0 * sy),
            control2: CGPoint(x: 7.0 * sx, y: 4.0 * sy)
        )
        p.addCurve(
            to: CGPoint(x: 20.0 * sx, y: 16.0 * sy),
            control1: CGPoint(x: 17.0 * sx, y: 4.0 * sy),
            control2: CGPoint(x: 15.0 * sx, y: 16.0 * sy)
        )
        return p
    }
}

public struct WireFillIconShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 13.0 * sx, y: 2.0 * sy))
        p.addLine(to: CGPoint(x: 4.0 * sx, y: 14.0 * sy))
        p.addLine(to: CGPoint(x: 10.0 * sx, y: 14.0 * sy))
        p.addLine(to: CGPoint(x: 9.0 * sx, y: 22.0 * sy))
        p.addLine(to: CGPoint(x: 18.0 * sx, y: 10.0 * sy))
        p.addLine(to: CGPoint(x: 12.0 * sx, y: 10.0 * sy))
        p.addLine(to: CGPoint(x: 13.0 * sx, y: 2.0 * sy))
        p.closeSubpath()
        return p
    }
}

// MARK: - Navigation & Header Icons

public struct ChevronLeftShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 15.0 * sx, y: 5.0 * sy))
        p.addLine(to: CGPoint(x: 8.0 * sx, y: 12.0 * sy))
        p.addLine(to: CGPoint(x: 15.0 * sx, y: 19.0 * sy))
        return p
    }
}

public struct ChevronRightShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24.0
        let sy = rect.height / 24.0
        var p = Path()
        p.move(to: CGPoint(x: 9.0 * sx, y: 5.0 * sy))
        p.addLine(to: CGPoint(x: 16.0 * sx, y: 12.0 * sy))
        p.addLine(to: CGPoint(x: 9.0 * sx, y: 19.0 * sy))
        return p
    }
}

public struct InfoIconView: View {
    public var tint: Color = .textSecondary

    public var body: some View {
        Canvas { context, size in
            let sx = size.width / 24.0
            let sy = size.height / 24.0

            // Outer circle
            let circleRect = CGRect(x: 3.0 * sx, y: 3.0 * sy, width: 18.0 * sx, height: 18.0 * sy)
            context.stroke(Path(ellipseIn: circleRect), with: .color(tint), lineWidth: 1.6 * sx)

            // Stem
            var stem = Path()
            stem.move(to: CGPoint(x: 12.0 * sx, y: 11.0 * sy))
            stem.addLine(to: CGPoint(x: 12.0 * sx, y: 16.5 * sy))
            context.stroke(stem, with: .color(tint), style: StrokeStyle(lineWidth: 1.6 * sx, lineCap: .round))

            // Dot
            let dotRect = CGRect(x: 11.0 * sx, y: 7.0 * sy, width: 2.0 * sx, height: 2.0 * sy)
            context.fill(Path(ellipseIn: dotRect), with: .color(tint))
        }
        .frame(width: 20, height: 20)
    }
}

public struct BendsNavIconView: View {
    public var tint: Color

    public var body: some View {
        Canvas { context, size in
            let sx = size.width / 24.0
            let sy = size.height / 24.0
            let r: CGFloat = 1.5 * sx
            let stroke = StrokeStyle(lineWidth: 1.7 * sx)

            let r1 = CGRect(x: 4.0 * sx, y: 4.0 * sy, width: 7.0 * sx, height: 7.0 * sy)
            let r2 = CGRect(x: 13.0 * sx, y: 4.0 * sy, width: 7.0 * sx, height: 7.0 * sy)
            let r3 = CGRect(x: 4.0 * sx, y: 13.0 * sy, width: 7.0 * sx, height: 7.0 * sy)
            let r4 = CGRect(x: 13.0 * sx, y: 13.0 * sy, width: 7.0 * sx, height: 7.0 * sy)

            context.stroke(Path(roundedRect: r1, cornerRadius: r), with: .color(tint), style: stroke)
            context.stroke(Path(roundedRect: r2, cornerRadius: r), with: .color(tint), style: stroke)
            context.stroke(Path(roundedRect: r3, cornerRadius: r), with: .color(tint), style: stroke)
            context.stroke(Path(roundedRect: r4, cornerRadius: r), with: .color(tint), style: stroke)
        }
        .frame(width: 21, height: 21)
    }
}

public struct HistoryNavIconView: View {
    public var tint: Color

    public var body: some View {
        Canvas { context, size in
            let sx = size.width / 24.0
            let sy = size.height / 24.0

            let circleRect = CGRect(x: 3.5 * sx, y: 3.5 * sy, width: 17.0 * sx, height: 17.0 * sy)
            context.stroke(Path(ellipseIn: circleRect), with: .color(tint), lineWidth: 1.6 * sx)

            var hands = Path()
            hands.move(to: CGPoint(x: 12.0 * sx, y: 7.5 * sy))
            hands.addLine(to: CGPoint(x: 12.0 * sx, y: 12.0 * sy))
            hands.addLine(to: CGPoint(x: 15.0 * sx, y: 14.0 * sy))
            context.stroke(hands, with: .color(tint), style: StrokeStyle(lineWidth: 1.6 * sx, lineCap: .round, lineJoin: .round))
        }
        .frame(width: 21, height: 21)
    }
}

public struct SettingsNavIconView: View {
    public var tint: Color

    public var body: some View {
        Canvas { context, size in
            let sx = size.width / 24.0
            let sy = size.height / 24.0

            // Inner circle
            let innerRect = CGRect(x: 9.0 * sx, y: 9.0 * sy, width: 6.0 * sx, height: 6.0 * sy)
            context.stroke(Path(ellipseIn: innerRect), with: .color(tint), lineWidth: 1.6 * sx)

            // Gear outline: M19 12a7 7 0 0 0-.1-1.2l2-1.5-2-3.4-2.3.9a7 7 0 0 0-2-1.2L14.2 3H9.8l-.4 2.6a7 7 0 0 0-2 1.2l-2.3-.9-2 3.4 2 1.5A7 7 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.4 2.3-.9c.6.5 1.3.9 2 1.2l.4 2.6h4.4l.4-2.6a7 7 0 0 0 2-1.2l2.3.9 2-3.4-2-1.5c.1-.4.1-.8.1-1.2Z
            let outerRect = CGRect(x: 4.5 * sx, y: 4.5 * sy, width: 15.0 * sx, height: 15.0 * sy)
            context.stroke(Path(ellipseIn: outerRect), with: .color(tint), lineWidth: 1.4 * sx)
        }
        .frame(width: 21, height: 21)
    }
}

// MARK: - Icon Helper View for BendKind

public struct BendKindIconView: View {
    public let kind: BendKind
    public var tint: Color = .accent

    public init(kind: BendKind, tint: Color = .accent) {
        self.kind = kind
        self.tint = tint
    }

    public var body: some View {
        Group {
            switch kind {
            case .offset:
                OffsetIconShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            case .ninety:
                NinetyIconShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            case .saddle3:
                Saddle3IconShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
            case .kick:
                KickIconShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            case .kick90:
                Kick90IconShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            case .segmented:
                SegmentedIconShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
            case .saddle4:
                Saddle4IconShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
            case .rolling:
                RollingIconShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            case .wirefill:
                WireFillIconShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: 18, height: 18)
    }
}
