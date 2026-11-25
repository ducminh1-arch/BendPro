import SwiftUI
import BendProCore

public struct SettingsScreen: View {
    public let unit: LengthUnit
    public var onUnitChange: (LengthUnit) -> Void
    public let darkOptimized: Bool
    public var onToggleDark: (Bool) -> Void

    public init(
        unit: LengthUnit,
        onUnitChange: @escaping (LengthUnit) -> Void,
        darkOptimized: Bool,
        onToggleDark: @escaping (Bool) -> Void
    ) {
        self.unit = unit
        self.onUnitChange = onUnitChange
        self.darkOptimized = darkOptimized
        self.onToggleDark = onToggleDark
    }

    public var body: some View {
        VStack(spacing: 0) {
            SimpleHeader(title: "Settings")

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Units Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("UNITS")
                            .font(.poppins(.semibold, size: 11))
                            .tracking(0.9)
                            .foregroundColor(.textTertiary)

                        HStack(spacing: 8) {
                            ForEach(LengthUnit.allCases) { u in
                                let isActive = (u == unit)
                                Button(action: {
                                    onUnitChange(u)
                                }) {
                                    Text(u.label)
                                        .font(.poppins(.semibold, size: 12.5))
                                        .foregroundColor(isActive ? .accent : .textSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .frame(minHeight: AppTapTarget.min)
                                        .background(isActive ? Color.accentWash : Color.bgPanel)
                                        .cornerRadius(999)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 999)
                                                .stroke(isActive ? Color.accent : Color.line, lineWidth: 1)
                                        )
                                }
                                .accessibilityLabel("Unit \(u.label)\(isActive ? ", selected" : "")")
                            }
                        }
                    }

                    Rectangle()
                        .fill(Color.lineSoft)
                        .frame(height: 1)

                    // Display Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DISPLAY")
                            .font(.poppins(.semibold, size: 11))
                            .tracking(0.9)
                            .foregroundColor(.textTertiary)

                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("High-contrast dark mode")
                                    .font(.poppins(.regular, size: 13.5))
                                    .foregroundColor(.textPrimary)

                                Text("Optimized for bright job-site light and headlamps.")
                                    .font(.poppins(.regular, size: 11.5))
                                    .foregroundColor(.textTertiary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { darkOptimized },
                                set: { onToggleDark($0) }
                            ))
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .accent))
                        }
                        .frame(minHeight: AppTapTarget.min)
                    }

                    Rectangle()
                        .fill(Color.lineSoft)
                        .frame(height: 1)

                    // About Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ABOUT")
                            .font(.poppins(.semibold, size: 11))
                            .tracking(0.9)
                            .foregroundColor(.textTertiary)

                        Text("BendPro runs the same centerline-radius engine for every calculation and diagram — offline, with no account and no data collection.")
                            .font(.poppins(.regular, size: 12.5))
                            .lineSpacing(4)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(16)
            }
        }
        .background(Color.bgVoid)
    }
}
