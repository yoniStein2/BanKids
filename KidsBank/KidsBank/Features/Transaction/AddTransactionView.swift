import SwiftUI
import ComposableArchitecture

struct AddTransactionView: View {
    @Bindable var store: StoreOf<TransactionFormFeature>
    
    var body: some View {
        Form {
            Section("Transaction Details") {
                TextField("Description", text: $store.transaction.description)
                
                TextField("Amount", value: $store.transaction.amount, format: .number)
                    .keyboardType(.decimalPad)
                
                Picker("Type", selection: $store.transaction.type) {
                    Text("Income").tag(Transaction.TransactionType.income)
                    Text("Outcome").tag(Transaction.TransactionType.outcome)
                }
                .pickerStyle(.segmented)
                
                DatePicker("Date", selection: $store.transaction.date, displayedComponents: .date)
            }
        }
        .navigationTitle("Add Transaction")
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
