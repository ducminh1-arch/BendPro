import SwiftUI
import BendProCore

public enum ValueInputStyle {
    case keypad
    case slider
}

private let PAD_KEYS = [
    "1", "2", "3",
    "4", "5", "6",
    "7", "8", "9",
    ".", "0", "⌫"
]

public struct ValueInput: View {
    public let label: String
    public let valueIn: Double
    public let onChangeIn: (Double) -> Void
    public let unit: LengthUnit
    public let minIn: Double
    public let maxIn: Double
    public let stepIn: Double

    @State private var expanded = false
    @State private var style: ValueInputStyle = .keypad
    @State private var rawString = ""

    public init(
        label: String,
        valueIn: Double,
        onChangeIn: @escaping (Double) -> Void,
        unit: LengthUnit,
        minIn: Double = 0.0,
        maxIn: Double = 96.0,
        stepIn: Double = 0.125
    ) {
        self.label = label
        self.valueIn = valueIn
        self.onChangeIn = onChangeIn
        self.unit = unit
        self.minIn = minIn
        self.maxIn = maxIn
        self.stepIn = stepIn
    }

    public var body: some View {
        Group {
            if !expanded {
                collapsedView
            } else {
                expandedView
            }
        }
        .onAppear {
            syncRawString()
        }
        .onChange(of: valueIn) { _ in
            syncRawString()
        }
        .onChange(of: unit) { _ in
            syncRawString()
        }
    }

    private var collapsedView: some View {
        Button(action: {
            syncRawString()
            expanded = true
        }) {
            HStack {
                Text(label.uppercased())
                    .font(.poppins(.medium, size: 11))
                    .tracking(0.8)
                    .foregroundColor(.textTertiary)

                Spacer()

                Text(formatLength(valueIn, unit: unit))
                    .font(.appMono(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: AppTapTarget.min)
            .background(Color.bgPanel)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(Color.lineSoft, lineWidth: 1)
            )
        }
        .accessibilityLabel("\(label), \(formatLength(valueIn, unit: unit)). Tap to edit.")
    }

    private var expandedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: label + style toggle buttons
            HStack {
                Text(label.uppercased())
                    .font(.poppins(.medium, size: 11))
                    .tracking(0.8)
                    .foregroundColor(.textTertiary)

                Spacer()

                // KEYPAD | SLIDE | DONE
                HStack(spacing: 0) {
                    Button(action: { style = .keypad }) {
                        Text("KEYPAD")
                            .font(.poppins(.semibold, size: 10))
                            .foregroundColor(style == .keypad ? .accent : .textTertiary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(style == .keypad ? Color.accentWash : Color.clear)
                    }

                    Button(action: { style = .slider }) {
                        Text("SLIDE")
                            .font(.poppins(.semibold, size: 10))
                            .foregroundColor(style == .slider ? .accent : .textTertiary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(style == .slider ? Color.accentWash : Color.clear)
                    }

                    Button(action: { expanded = false }) {
                        Text("DONE")
                            .font(.poppins(.semibold, size: 10))
                            .foregroundColor(.textTertiary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                    }
                }
                .background(Color.bgInset)
                .cornerRadius(AppRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .stroke(Color.line, lineWidth: 1)
                )
            }

            // Big numeric readout
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                if unit == .mm {
                    let mmVal = Int((valueIn * 25.4).rounded())
                    Text("\(mmVal)")
                        .font(.appMono(size: 28, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("mm")
                        .font(.poppins(.medium, size: 13))
                        .foregroundColor(.textTertiary)
                } else {
                    Text(String(format: "%.3f", valueIn))
                        .font(.appMono(size: 28, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("in")
                        .font(.poppins(.medium, size: 13))
                        .foregroundColor(.textTertiary)
                }
            }

            if style == .keypad {
                keypadGrid
            } else {
                sliderTrack
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.bgPanel)
        .cornerRadius(AppRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(Color.lineSoft, lineWidth: 1)
        )
    }

    private var keypadGrid: some View {
        VStack(spacing: 8) {
            ForEach(0..<4) { row in
                HStack(spacing: 8) {
                    ForEach(0..<3) { col in
                        let key = PAD_KEYS[row * 3 + col]
                        Button(action: { pressKey(key) }) {
                            Text(key)
                                .font(.appMono(size: 17, weight: .medium))
                                .foregroundColor(.textPrimary)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(Color.bgInset)
                                .cornerRadius(AppRadius.sm)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.sm)
                                        .stroke(Color.line, lineWidth: 1)
                                )
                        }
                        .accessibilityLabel(key == "⌫" ? "Backspace" : (key == "." ? "Decimal point" : key))
                    }
                }
            }
        }
    }

    private var sliderTrack: some View {
        GeometryReader { geo in
            let trackWidth = max(geo.size.width, 1.0)
            let pct: CGFloat = {
                if unit == .mm {
                    let minMm = minIn * 25.4
                    let maxMm = maxIn * 25.4
                    let curMm = valueIn * 25.4
                    let p = (curMm - minMm) / max(maxMm - minMm, 1.0)
                    return CGFloat(max(0.0, min(1.0, p)))
                } else {
                    let p = (valueIn - minIn) / max(maxIn - minIn, 0.001)
                    return CGFloat(max(0.0, min(1.0, p)))
                }
            }()

            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 999)
                    .fill(Color.bgInset)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.line, lineWidth: 1)
                    )

                // Fill
                RoundedRectangle(cornerRadius: 999)
                    .fill(Color.accentWash)
                    .frame(width: max(0, trackWidth * pct))

                // Thumb
                Circle()
                    .fill(Color.accent)
                    .frame(width: 28, height: 28)
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: max(0, min(trackWidth - 28, trackWidth * pct - 14)))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        handleSlider(xPos: gesture.location.x, trackWidth: trackWidth)
                    }
            )
        }
        .frame(height: 48)
    }

    private func handleSlider(xPos: CGFloat, trackWidth: CGFloat) {
        let pct = Double(max(0.0, min(1.0, xPos / trackWidth)))
        if unit == .mm {
            let minMm = minIn * 25.4
            let maxMm = maxIn * 25.4
            let valMm = minMm + pct * (maxMm - minMm)
            let snappedMm = valMm.rounded()
            rawString = "\(Int(snappedMm))"
            onChangeIn(snappedMm / 25.4)
        } else {
            let val = minIn + pct * (maxIn - minIn)
            let snapped = (val / stepIn).rounded() * stepIn
            rawString = String(format: "%.3f", snapped)
            onChangeIn(snapped)
        }
    }

    private func pressKey(_ key: String) {
        if key == "⌫" {
            let next = String(rawString.dropLast())
            rawString = next.isEmpty ? "0" : next
            commit(rawString)
        } else if key == "." {
            if !rawString.contains(".") {
                rawString += "."
            }
        } else {
            if rawString == "0" {
                rawString = key
            } else {
                rawString += key
            }
            commit(rawString)
        }
    }

    private func commit(_ text: String) {
        guard let num = Double(text) else { return }
        if unit == .mm {
            onChangeIn(num / 25.4)
        } else {
            onChangeIn(num)
        }
    }

    private func syncRawString() {
        if unit == .mm {
            let mmVal = Int((valueIn * 25.4).rounded())
            rawString = "\(mmVal)"
        } else {
            if valueIn.truncatingRemainder(dividingBy: 1.0) == 0 {
                rawString = "\(Int(valueIn))"
            } else {
                rawString = String(format: "%.3f", valueIn)
            }
        }
    }
}
