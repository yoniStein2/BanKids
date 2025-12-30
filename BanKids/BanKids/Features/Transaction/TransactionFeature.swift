import ComposableArchitecture
import SwiftUI

@Reducer
struct TransactionFeature {
    @ObservableState
    struct State: Equatable, Hashable {
        var transaction: Transaction
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case saveButtonTapped
        case cancelButtonTapped
        
        enum Delegate: Equatable {
            case saveTransaction(Transaction)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .saveButtonTapped:
                return .run { [transaction = state.transaction] send in
                    await send(.delegate(.saveTransaction(transaction)))
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
