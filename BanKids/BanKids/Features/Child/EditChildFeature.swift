import ComposableArchitecture
import SwiftUI

@Reducer
struct EditChildFeature {
    @ObservableState
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        var name: String
        var themeColor: ChildFeature.State.ThemeColor
        var avatar: ChildFeature.State.Avatar
        var avatarData: Data?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case saveButtonTapped
        case cancelButtonTapped
        case selectAvatar(ChildFeature.State.Avatar)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case saveChild(name: String, themeColor: ChildFeature.State.ThemeColor, avatar: ChildFeature.State.Avatar, avatarData: Data?)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            
            case let .selectAvatar(avatar):
                state.avatar = avatar
                state.avatarData = nil
                return .none
                
            case .saveButtonTapped:
                return .run { [name = state.name, themeColor = state.themeColor, avatar = state.avatar, avatarData = state.avatarData] send in
                    await send(.delegate(.saveChild(name: name, themeColor: themeColor, avatar: avatar, avatarData: avatarData)))
                    await self.dismiss()
                }
                
            case .cancelButtonTapped:
                return .run { _ in
                    await self.dismiss()
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
