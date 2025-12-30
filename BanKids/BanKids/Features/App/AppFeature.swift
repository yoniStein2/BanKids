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
        @Presents var addChild: AddChildFeature.State?
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case addChildTapped
        case childCardTapped(ChildFeature.State)
        case deleteChildTapped(IndexSet)
        case alert(PresentationAction<Alert>)
        case addChild(PresentationAction<AddChildFeature.Action>)
        case onAppear
        case childrenLoaded(IdentifiedArrayOf<ChildFeature.State>)
        case saveChildren
        
        enum Alert: Equatable {
            case confirmDeletion
        }
    }
    
    @Reducer
    enum Path {
        case childDetail(ChildFeature)
    }
    
    @Dependency(\.dataPersistence) var dataPersistence
        
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        let children = try await dataPersistence.loadChildren()
                        await send(.childrenLoaded(children))
                    } catch {
                        print("Failed to load children: \(error)")
                    }
                }
                
            case let .childrenLoaded(children):
                state.children = children
                return .none
                
            case .saveChildren:
                let children = state.children
                return .run { _ in
                    do {
                        try await dataPersistence.saveChildren(children)
                    } catch {
                        print("Failed to save children: \(error)")
                    }
                }
                
            case .addChildTapped:
                state.addChild = AddChildFeature.State()
                return .none
                
            case let .addChild(.presented(.delegate(.saveChild(name, themeColor, avatar, avatarData)))):
                let newChild = ChildFeature.State(
                    id: UUID(),
                    name: name,
                    themeColor: themeColor,
                    avatar: avatar,
                    avatarData: avatarData
                )
                state.children.append(newChild)
                return .send(.saveChildren)
                
            case .addChild:
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
                return .send(.saveChildren)
                
            case .alert:
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$addChild, action: \.addChild) {
            AddChildFeature()
        }
        RoutingFeature()
    }
}


extension AppFeature.Path.State: Equatable {}
