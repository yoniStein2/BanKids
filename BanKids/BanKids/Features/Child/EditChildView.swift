//
//  EditChildView.swift
//  KidsBank
//
//  Created by Yoni Stein on 28/12/2025.
//

import SwiftUI
import ComposableArchitecture

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

