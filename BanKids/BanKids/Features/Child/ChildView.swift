import SwiftUI
import ComposableArchitecture
import PhotosUI

struct ChildView: View {
    @Bindable var store: StoreOf<ChildFeature>
    @State private var selectedTransaction: Transaction?
    @State private var avatarItem: PhotosPickerItem?
    @State private var showDeleteAlert = false
    
    var groupedTransactions: [(key: Date, value: [Transaction])] {
        let grouped = Dictionary(grouping: store.transactions) { transaction in
            transaction.date.startOfMonth
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        ZStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        ZStack(alignment: .bottomTrailing) {
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
                            
                            PhotosPicker(selection: $avatarItem, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(.blue)
                                    .padding(8)
                                    .background(Circle().fill(.white))
                                    .shadow(radius: 2)
                            }
                            .offset(x: 5, y: 5)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section {
                    HStack {
                        Text("Current Balance")
                        Spacer()
                        Text(store.balance, format: .currency(code: "ILS"))
                            .bold()
                            .foregroundStyle(store.balance >= 0 ? .green : .red)
                            .font(.title2)
                    }
                }
                
                if store.transactions.isEmpty {
                    Section("Transactions") {
                        Text("No transactions yet")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(groupedTransactions, id: \.key) { section in
                        Section(header: Text(section.key.formatted(.dateTime.year().month(.wide)))) {
                            ForEach(section.value) { transaction in
                                Button {
                                    withAnimation {
                                        selectedTransaction = transaction
                                    }
                                } label: {
                                    TransactionRowView(transaction: transaction)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let transaction = section.value[index]
                                    store.send(.deleteTransactionWithId(transaction.id))
                                }
                            }
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
                    Button {
                        store.send(.editNameButtonTapped)
                    } label: {
                        Image(systemName: "pencil")
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
                    TransactionView(store: store)
                }
            }
            
            // Popup Overlay
            if let transaction = selectedTransaction {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            selectedTransaction = nil
                        }
                    }
                    .transition(.opacity)
                
                TransactionDetailPopup(transaction: transaction) {
                    withAnimation {
                        selectedTransaction = nil
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
            
            VStack {
                Spacer()
                Button {
                    store.send(.addTransactionButtonTapped)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Circle().fill(.blue.opacity(0.8)))
                        .shadow(radius: 4)
                }
                .padding(.bottom, 20)
            }
        }
    }
}
