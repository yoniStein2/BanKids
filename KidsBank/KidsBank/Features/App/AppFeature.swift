import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var children: IdentifiedArrayOf<ChildFeature.State> = []
        var path = StackState<Path.State>()
        var childToDelete: IndexSet?
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case addChildTapped
        case childCardTapped(ChildFeature.State)
        case deleteChildTapped(IndexSet)
        case alert(PresentationAction<Alert>)
        
        enum Alert: Equatable {
            case confirmDeletion
        }
    }
    
    @Reducer
    enum Path {
        case childDetail(ChildFeature)
    }
        
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addChildTapped:
                let newChild = ChildFeature.State(id: UUID(), name: "New Child")
                state.path.append(.childDetail(newChild))
//
//                state.children.append(newChild)
                return .none
                
            case let .childCardTapped(child):
                state.path.append(.childDetail(child))
                return .none
                
            case let .deleteChildTapped(indexSet):
                state.childToDelete = indexSet
                state.alert = AlertState {
                    TextState("Delete Child?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDeletion) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Are you sure you want to delete this child account? This action cannot be undone.")
                }
                return .none
                
            case .alert(.presented(.confirmDeletion)):
                if let indexSet = state.childToDelete {
                    state.children.remove(atOffsets: indexSet)
                }
                state.childToDelete = nil
                return .none
                
            case .alert:
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$alert, action: \.alert)
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
// sdfsdf


extension AppFeature.Path.State: Equatable {}
