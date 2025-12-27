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

struct EditChildView: View {
    @Bindable var store: StoreOf<EditChildFeature>
    
    let columns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    let avatarColumns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $store.name)
                }
                
                Section {
                    HStack {
                        Spacer()
                        if let data = store.avatarData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .shadow(radius: 5)
                        } else {
                            Image(store.avatar.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .shadow(radius: 5)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section("Avatar") {
                    LazyVGrid(columns: avatarColumns, spacing: 15) {
                        ForEach(ChildFeature.State.Avatar.allCases, id: \.self) { avatar in
                            ZStack {
                                Image(avatar.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    
                                if store.avatar == avatar && store.avatarData == nil {
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 3)
                                        .frame(width: 66, height: 66)
                                }
                            }
                            .onTapGesture {
                                store.send(.selectAvatar(avatar))
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                Section("Theme Color") {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(ChildFeature.State.ThemeColor.allCases, id: \.self) { color in
                            ZStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 44, height: 44)
                                    
                                if store.themeColor == color {
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 2)
                                        .frame(width: 50, height: 50)
                                }
                            }
                            .onTapGesture {
                                store.themeColor = color
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Edit Child")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.cancelButtonTapped)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.saveButtonTapped)
                    }
                }
            }
        }
    }
}
