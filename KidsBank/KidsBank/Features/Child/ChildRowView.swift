import SwiftUI
import ComposableArchitecture

struct ChildRowView: View {
    let child: ChildFeature.State
    
    var body: some View {
        HStack {
            Text(child.name)
                .font(.headline)
            Spacer()
            Text(child.balance, format: .currency(code: "USD"))
                .bold()
                .foregroundStyle(child.balance >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}
