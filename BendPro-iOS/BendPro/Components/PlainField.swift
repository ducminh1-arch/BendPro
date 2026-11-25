import SwiftUI
import BendProCore

public struct PlainField: View {
    public let label: String
    public let suffix: String
    public let value: Double
    public let onChange: (Double) -> Void
    public let min: Double?
    public let max: Double?
    public let isInteger: Bool

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    public init(
        label: String,
        suffix: String,
        value: Double,
        onChange: @escaping (Double) -> Void,
        min: Double? = nil,
        max: Double? = nil,
        isInteger: Bool = false
    ) {
        self.label = label
        self.suffix = suffix
        self.value = value
        self.onChange = onChange
        self.min = min
        self.max = max
        self.isInteger = isInteger
    }

    public var body: some View {
        HStack {
            Text(label.uppercased())
                .font(.poppins(.medium, size: 11))
                .tracking(0.8)
                .foregroundColor(.textTertiary)

            Spacer()

            HStack(spacing: 4) {
                TextField("", text: $text)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .multilineTextAlignment(.trailing)
                    .font(.appMono(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 64)
                    .accessibilityLabel("\(label), current value \(text) \(suffix)")
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isFocused = false
                                commit()
                            }
                            .font(.poppins(.semibold, size: 14))
                            .foregroundColor(.accent)
                        }
                    }
                    .onSubmit {
                        commit()
                    }

                Text(suffix)
                    .font(.appMono(size: 15, weight: .regular))
                    .foregroundColor(.textPrimary)
            }
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
        .onAppear {
            syncText(with: value)
        }
        .onChange(of: value) { newVal in
            if !isFocused {
                syncText(with: newVal)
            }
        }
        .onChange(of: isFocused) { focused in
            if !focused {
                commit()
            }
        }
    }

    private func commit() {
        let parsed = Double(text) ?? 0.0
        var clamped = parsed
        if let min = min, clamped < min {
            clamped = min
        }
        if let max = max, clamped > max {
            clamped = max
        }
        let finalVal = isInteger ? round(clamped) : clamped
        onChange(finalVal)
        syncText(with: finalVal)
    }

    private func syncText(with val: Double) {
        if isInteger || val.truncatingRemainder(dividingBy: 1.0) == 0 {
            text = "\(Int(val))"
        } else {
            text = "\(val)"
        }
    }
}
