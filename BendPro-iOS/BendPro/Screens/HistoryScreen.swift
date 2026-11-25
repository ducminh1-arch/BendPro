import SwiftUI
import BendProCore

public struct HistoryScreen: View {
    public let entries: [HistoryEntry]
    public var onClear: () -> Void

    @State private var showConfirmDialog = false

    public init(entries: [HistoryEntry], onClear: @escaping () -> Void) {
        self.entries = entries
        self.onClear = onClear
    }

    public var body: some View {
        VStack(spacing: 0) {
            SimpleHeader(title: "History")

            if entries.isEmpty {
                emptyStateView
            } else {
                contentListView
            }
        }
        .background(Color.bgVoid)
        .alert("Clear history?", isPresented: $showConfirmDialog) {
            Button("Clear", role: .destructive) {
                onClear()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All saved calculations will be permanently deleted.")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 6) {
            Spacer()
            Text("No saved bends yet")
                .font(.poppins(.semibold, size: 16))
                .foregroundColor(.textSecondary)

            Text("Calculations you save from the Bends tab will show up here, newest first.")
                .font(.poppins(.regular, size: 13))
                .foregroundColor(.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var contentListView: some View {
        VStack(spacing: 10) {
            // Count and Clear all
            HStack {
                Text("\(entries.count) saved")
                    .font(.poppins(.regular, size: 13))
                    .foregroundColor(.textSecondary)

                Spacer()

                Button("Clear all") {
                    showConfirmDialog = true
                }
                .font(.poppins(.semibold, size: 12.5))
                .foregroundColor(.accent)
                .frame(minHeight: AppTapTarget.min)
                .accessibilityLabel("Clear all saved history")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Items newest first
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(entries.reversed()) { entry in
                        HistoryCard(entry: entry)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}

public struct HistoryCard: View {
    public let entry: HistoryEntry

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.label)
                    .font(.poppins(.medium, size: 14))
                    .foregroundColor(.textPrimary)

                Spacer()

                Text(formattedDate(entry.createdAt))
                    .font(.appMono(size: 11))
                    .foregroundColor(.textTertiary)
            }

            Text(entry.inputSummary)
                .font(.appMono(size: 12))
                .foregroundColor(.textSecondary)

            Text(entry.resultSummary)
                .font(.appMono(size: 12))
                .foregroundColor(.metal200)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bgPanel)
        .cornerRadius(AppRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(Color.lineSoft, lineWidth: 1)
        )
    }

    private func formattedDate(_ epochMillis: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epochMillis) / 1000.0)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
