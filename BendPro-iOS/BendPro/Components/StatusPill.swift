import SwiftUI
import BendProCore

public struct StatusPillView: View {
    public let feasibility: Feasibility

    public init(feasibility: Feasibility) {
        self.feasibility = feasibility
    }

    private var label: String {
        switch feasibility.level {
        case .ok:
            return "VALID"
        case .warn:
            return "CHECK CLOSELY"
        case .danger:
            return "NOT POSSIBLE"
        }
    }

    private var pillColor: Color {
        switch feasibility.level {
        case .ok:
            return Color.colorOk
        case .warn:
            return Color.colorWarn
        case .danger:
            return Color.colorDanger
        }
    }

    private var pillWashColor: Color {
        switch feasibility.level {
        case .ok:
            return Color.okWash
        case .warn:
            return Color.warnWash
        case .danger:
            return Color.dangerWash
        }
    }

    public var body: some View {
        HStack(spacing: 8) {
            if feasibility.level == .ok {
                Path { p in
                    p.move(to: CGPoint(x: 5, y: 13))
                    p.addLine(to: CGPoint(x: 9, y: 17))
                    p.addLine(to: CGPoint(x: 19, y: 7))
                }
                .stroke(pillColor, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                .frame(width: 16, height: 16)
            } else {
                Path { p in
                    p.move(to: CGPoint(x: 12, y: 6))
                    p.addLine(to: CGPoint(x: 12, y: 13))
                    p.move(to: CGPoint(x: 12, y: 17))
                    p.addLine(to: CGPoint(x: 12, y: 17.5))
                }
                .stroke(pillColor, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
                .frame(width: 16, height: 16)
            }

            Text(label)
                .font(.poppins(.semibold, size: 12))
                .tracking(0.6)
                .foregroundColor(pillColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(minHeight: 38)
        .background(pillWashColor)
        .cornerRadius(999)
        .overlay(
            RoundedRectangle(cornerRadius: 999)
                .stroke(pillColor.opacity(0.3), lineWidth: 1)
        )
        .accessibilityLabel(feasibility.message)
    }
}
