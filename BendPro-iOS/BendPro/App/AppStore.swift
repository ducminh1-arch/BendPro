import Foundation
import Combine
import BendProCore

public class AppStore: ObservableObject {
    public static let storageKey = "bendpro:v1"

    @Published public var unit: LengthUnit
    @Published public var benderId: String
    @Published public var history: [HistoryEntry]
    @Published public var darkOptimized: Bool

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let data = userDefaults.data(forKey: Self.storageKey),
           let state = try? JSONDecoder().decode(PersistedState.self, from: data) {
            self.unit = state.unit
            self.benderId = state.benderId
            self.history = state.history
            self.darkOptimized = state.darkOptimized
        } else {
            self.unit = .inch
            self.benderId = "klein-emt-standard"
            self.history = []
            self.darkOptimized = true
        }
    }

    public var selectedBender: Bender {
        BENDERS.first(where: { $0.id == benderId }) ?? BENDERS[0]
    }

    public func setUnit(_ newUnit: LengthUnit) {
        unit = newUnit
        persist()
    }

    public func setBenderId(_ newId: String) {
        benderId = newId
        persist()
    }

    public func addHistory(_ entry: HistoryEntry) {
        history.append(entry)
        persist()
    }

    public func clearHistory() {
        history.removeAll()
        persist()
    }

    public func setDarkOptimized(_ enabled: Bool) {
        darkOptimized = enabled
        persist()
    }

    private func persist() {
        let state = PersistedState(
            unit: unit,
            benderId: benderId,
            history: history,
            darkOptimized: darkOptimized
        )
        if let data = try? JSONEncoder().encode(state) {
            userDefaults.set(data, forKey: Self.storageKey)
        }
    }
}
