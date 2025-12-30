import Foundation
import ComposableArchitecture

/// A Codable representation of ChildFeature.State for persistence
struct PersistedChild: Codable, Equatable {
    let id: UUID
    var name: String
    var themeColor: ChildFeature.State.ThemeColor
    var avatar: ChildFeature.State.Avatar
    var avatarData: Data?
    var transactions: [Transaction]
    
    init(from state: ChildFeature.State) {
        self.id = state.id
        self.name = state.name
        self.themeColor = state.themeColor
        self.avatar = state.avatar
        self.avatarData = state.avatarData
        self.transactions = Array(state.transactions)
    }
    
    func toState() -> ChildFeature.State {
        var state = ChildFeature.State(
            id: id,
            name: name,
            themeColor: themeColor,
            avatar: avatar,
            avatarData: avatarData
        )
        state.transactions = IdentifiedArrayOf(uniqueElements: transactions)
        return state
    }
}

/// Dependency for persisting children data
struct DataPersistenceClient {
    var saveChildren: @Sendable (IdentifiedArrayOf<ChildFeature.State>) async throws -> Void
    var loadChildren: @Sendable () async throws -> IdentifiedArrayOf<ChildFeature.State>
}

extension DataPersistenceClient: DependencyKey {
    static let liveValue = DataPersistenceClient(
        saveChildren: { children in
            let persisted = children.map { PersistedChild(from: $0) }
            let data = try JSONEncoder().encode(persisted)
            let url = Self.childrenFileURL
            try data.write(to: url)
        },
        loadChildren: {
            let url = Self.childrenFileURL
            guard FileManager.default.fileExists(atPath: url.path) else {
                return []
            }
            let data = try Data(contentsOf: url)
            let persisted = try JSONDecoder().decode([PersistedChild].self, from: data)
            return IdentifiedArrayOf(uniqueElements: persisted.map { $0.toState() })
        }
    )
    
    private static var childrenFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("children.json")
    }
}

extension DependencyValues {
    var dataPersistence: DataPersistenceClient {
        get { self[DataPersistenceClient.self] }
        set { self[DataPersistenceClient.self] = newValue }
    }
}
