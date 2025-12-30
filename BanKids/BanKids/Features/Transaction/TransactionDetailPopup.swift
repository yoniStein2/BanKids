import SwiftUI

struct TransactionDetailPopup: View {
    let transaction: Transaction
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon/Avatar area
            ZStack {
                Circle()
                    .fill(transaction.type == .income ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: transaction.type == .income ? "arrow.up.right" : "arrow.down.left")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(transaction.type == .income ? .green : .red)
            }
            .padding(.top, 20)
            
            // Amount
            Text(transaction.amount, format: .currency(code: "ILS"))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(transaction.type == .income ? .green : .red)
            
            // Description
            if !transaction.description.isEmpty {
                Text(transaction.description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            } else {
                Text(transaction.type == .income ? "Income" : "Expense")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            // Date
            Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.vertical, 10)
            
            // Close Button
            Button(action: onClose) {
                Text("Close")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .frame(maxWidth: 300)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        TransactionDetailPopup(
            transaction: Transaction(
                id: UUID(),
                amount: 50,
                description: "Weekly Allowance",
                date: Date(),
                type: .income
            ),
            onClose: {}
        )
    }
}
