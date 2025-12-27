import SwiftUI
import ComposableArchitecture
import PhotosUI

struct AddChildView: View {
    @Bindable var store: StoreOf<AddChildFeature>
    @State private var avatarItem: PhotosPickerItem?
    @FocusState private var isNameFocused: Bool
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    let avatarColumns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        store.themeColor.color.opacity(0.3),
                        store.themeColor.color.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Avatar with edit overlay
                        avatarSection
                        
                        // Name text field
                        nameSection
                        
                        // Avatar picker
                        avatarPickerSection
                        
                        // Color picker
                        colorPickerSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("New Child")
            .navigationBarTitleDisplayMode(.inline)
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
                    .fontWeight(.semibold)
                }
            }
            .onChange(of: avatarItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        store.send(.setAvatarData(data))
                    }
                }
            }
        }
    }
    
    // MARK: - Avatar Section
    private var avatarSection: some View {
        ZStack(alignment: .bottomTrailing) {
            if let data = store.avatarData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            } else {
                Image(store.avatar.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            
            // Edit button overlay
            PhotosPicker(selection: $avatarItem, matching: .images) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .offset(x: 4, y: 4)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Name Section
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TextField("Enter name", text: $store.name)
                .font(.title2)
                .fontWeight(.medium)
                .padding(.vertical, 12)
                .focused($isNameFocused)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isNameFocused ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: isNameFocused ? 2 : 1)
                }
        }
    }
    
    // MARK: - Avatar Picker Section
    private var avatarPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Avatar")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
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
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - Color Picker Section
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme Color")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: colorColumns, spacing: 12) {
                ForEach(ChildFeature.State.ThemeColor.allCases, id: \.self) { color in
                    ZStack {
                        Circle()
                            .fill(color.color)
                            .frame(width: 44, height: 44)
                            .shadow(color: color.color.opacity(0.4), radius: 4, x: 0, y: 2)
                        
                        if store.themeColor == color {
                            Circle()
                                .stroke(Color.primary, lineWidth: 2)
                                .frame(width: 52, height: 52)
                        }
                    }
                    .onTapGesture {
                        store.themeColor = color
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
        .padding(.bottom, 30)
    }
}
