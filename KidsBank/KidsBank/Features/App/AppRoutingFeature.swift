import ComposableArchitecture

/// A reducer that handles routing logic for child detail navigation
/// Syncs child state changes from the navigation stack back to the children array
struct AppRoutingFeature: Reducer {
    typealias State = AppFeature.State
    typealias Action = AppFeature.Action
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .path(.element(id: stackID, action: .childDetail(.delegate(.deleteChild)))):
                guard case let .childDetail(childState) = state.path[id: stackID] else { return .none }
                state.children.remove(id: childState.id)
                state.path.pop(from: stackID)
                return .none
                
            case let .path(.element(id: stackID, action: .childDetail(_))):
                guard case let .childDetail(childState) = state.path[id: stackID] else { return .none }
                if state.children[id: childState.id] != nil {
                    state.children[id: childState.id] = childState
                }
                return .none
                
            default:
                return .none
            }
        }
    }
}
