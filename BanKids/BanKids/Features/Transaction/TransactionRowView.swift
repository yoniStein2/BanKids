import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.headline)
            }
            
            Spacer()
            
            Text(transaction.amount, format: .currency(code: "ILS"))
                .foregroundStyle(transaction.type == .income ? .green : .red)
                .bold()
        }
        .padding(.vertical, 4)
    }
}
