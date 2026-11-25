import SwiftUI

public struct HomeHeader: View {
    public var onInfoClick: () -> Void = {}

    public init(onInfoClick: @escaping () -> Void = {}) {
        self.onInfoClick = onInfoClick
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 0)

                ZStack {
                    // Wordmark centered
                    HStack(spacing: 0) {
                        Text("BEND")
                            .font(.poppins(.semibold, size: 17))
                            .foregroundColor(.textPrimary)
                        Text("PRO")
                            .font(.poppins(.semibold, size: 17))
                            .foregroundColor(.accent)
                    }
                    .tracking(0.5)

                    // Info button on the right
                    HStack {
                        Spacer()
                        Button(action: onInfoClick) {
                            InfoIconView(tint: .textSecondary)
                                .frame(width: 48, height: 48)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel("About BendPro")
                    }
                }
                .frame(maxWidth: 640)

                Spacer(minLength: 0)
            }
            .frame(height: 56)
            .padding(.horizontal, 16)
            .background(Color.bgPanel)

            // Bottom hairline border
            Rectangle()
                .fill(Color.lineSoft)
                .frame(height: 1)
        }
    }
}

public struct DetailHeader: View {
    public let title: String
    public var onBack: () -> Void

    public init(title: String, onBack: @escaping () -> Void) {
        self.title = title
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 0)

                HStack(spacing: 0) {
                    // Back button
                    Button(action: onBack) {
                        ChevronLeftShape()
                            .stroke(Color.textSecondary, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                            .frame(width: 22, height: 22)
                            .frame(width: 48, height: 48)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Navigate back")

                    Spacer()

                    // Centered title
                    Text(title)
                        .font(.poppins(.semibold, size: 16))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    // Spacer to balance the 48pt back button
                    Color.clear
                        .frame(width: 48, height: 48)
                }
                .frame(maxWidth: 640)

                Spacer(minLength: 0)
            }
            .frame(height: 56)
            .padding(.horizontal, 6)
            .background(Color.bgPanel)

            // Bottom hairline border
            Rectangle()
                .fill(Color.lineSoft)
                .frame(height: 1)
        }
    }
}

public struct SimpleHeader: View {
    public let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 0)

                ZStack {
                    Text(title)
                        .font(.poppins(.semibold, size: 16))
                        .foregroundColor(.textPrimary)
                }
                .frame(maxWidth: 640)

                Spacer(minLength: 0)
            }
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Color.bgPanel)

            // Bottom hairline border
            Rectangle()
                .fill(Color.lineSoft)
                .frame(height: 1)
        }
    }
}
