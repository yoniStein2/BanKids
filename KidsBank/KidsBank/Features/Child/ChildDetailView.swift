import SwiftUI
import ComposableArchitecture
import PhotosUI

struct ChildDetailView: View {
    @Bindable var store: StoreOf<ChildFeature>
    @State private var avatarItem: PhotosPickerItem?
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    if let data = store.avatarData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    } else {
                        Image(store.avatar.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            
            Section("Overview") {
                HStack {
                    Text("Current Balance")
                    Spacer()
                    Text(store.balance, format: .currency(code: "USD"))
                        .bold()
                        .foregroundStyle(store.balance >= 0 ? .green : .red)
                        .font(.title2)
                }
            }
            
            Section("Transactions") {
                if store.transactions.isEmpty {
                    Text("No transactions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                    .onDelete { indexSet in
                        store.send(.deleteTransaction(indexSet))
                    }
                }
            }
            
            Section {
                Button("Delete Child", role: .destructive) {
                    showDeleteAlert = true
                }
            }
        }
        .navigationTitle(store.name)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                PhotosPicker(selection: $avatarItem, matching: .images) {
                    Image(systemName: "photo")
                }
                
                Button {
                    store.send(.editNameButtonTapped)
                } label: {
                    Image(systemName: "pencil")
                }
                
                Button {
                    store.send(.addTransactionButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onChange(of: avatarItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    store.send(.setAvatarData(data))
                }
            }
        }
        .alert("Delete Child?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                store.send(.delegate(.deleteChild))
            }
        } message: {
            Text("Are you sure you want to delete this account?")
        }
        .sheet(item: $store.scope(state: \.editChild, action: \.editChild)) { store in
            EditChildView(store: store)
        }
        .sheet(item: $store.scope(state: \.addTransaction, action: \.addTransaction)) { store in
            NavigationStack {
                AddTransactionView(store: store)
            }
        }
    }
}
