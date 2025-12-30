import SwiftUI
import ComposableArchitecture

struct TransactionView: View {
    @Bindable var store: StoreOf<TransactionFeature>
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // Type Toggle
            HStack(spacing: 40) {
                // Income Button
                Button {
                    store.transaction.type = .income
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(store.transaction.type == .income ? Color.green : Color.gray.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .shadow(color: store.transaction.type == .income ? .green.opacity(0.4) : .clear, radius: 8, y: 4)
                            
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(store.transaction.type == .income ? .white : .gray)
                        }
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(store.transaction.type == .income ? .primary : .secondary)
                            .fontWeight(store.transaction.type == .income ? .bold : .regular)
                    }
                }
                .buttonStyle(.plain)
                
                // Outcome Button
                Button {
                    store.transaction.type = .outcome
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(store.transaction.type == .outcome ? Color.red : Color.gray.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .shadow(color: store.transaction.type == .outcome ? .red.opacity(0.4) : .clear, radius: 8, y: 4)
                            
                            Image(systemName: "arrow.down.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(store.transaction.type == .outcome ? .white : .gray)
                        }
                        Text("Expense")
                            .font(.caption)
                            .foregroundStyle(store.transaction.type == .outcome ? .primary : .secondary)
                            .fontWeight(store.transaction.type == .outcome ? .bold : .regular)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 20)
            
            // Amount Input
            VStack(spacing: 10) {
                TextField("0", value: Binding<Double?>(
                    get: { store.transaction.amount == 0 ? nil : store.transaction.amount },
                    set: { store.transaction.amount = $0 ?? 0 }
                ), format: .number)
                    .font(.system(size: 70, weight: .bold, design: .rounded))
                    .foregroundStyle(store.transaction.type == .income ? Color.green : Color.red)
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
            }
            .padding(.vertical, 20)
            
            // Description Input
            VStack {
                TextField("What is this for?", text: $store.transaction.description)
                    .font(.title3)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .navigationTitle("Create Transaction")
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
                .disabled(store.transaction.amount == 0)
                .bold()
            }
        }
        .onAppear {
            isAmountFocused = true
        }
    }
}
