import ComposableArchitecture
import SwiftUI

@Reducer
struct ChildFeature {
    @ObservableState
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        var name: String
        var themeColor: ThemeColor = .pastelBlue
        var avatar: Avatar = .boy
        var avatarData: Data? = nil
        var transactions: IdentifiedArrayOf<Transaction> = []
        @Presents var addTransaction: TransactionFeature.State?
        @Presents var editChild: EditChildFeature.State?
        
        enum Avatar: String, Codable, Equatable, Hashable, CaseIterable {
            case boy
            case girl
            
            var id: String { rawValue }
            
            var imageName: String {
                switch self {
                case .boy: return "avatar_boy"
                case .girl: return "avatar_girl"
                }
            }
        }
        
        enum ThemeColor: String, Codable, Equatable, Hashable, CaseIterable {
            case pastelPink
            case pastelBlue
            case pastelGreen
            case pastelYellow
            case pastelOrange
            case pastelPurple
            case pastelMint
            case pastelCoral
            case pastelLavender
            case pastelSky
            
            var id: String { rawValue }
            
            var color: Color {
                switch self {
                case .pastelPink: return Color(red: 1.0, green: 0.6, blue: 0.8) // Hot Pink Pastel
                case .pastelBlue: return Color(red: 0.4, green: 0.8, blue: 1.0) // Electric Blue Pastel
                case .pastelGreen: return Color(red: 0.6, green: 0.95, blue: 0.6) // Neon Mint
                case .pastelYellow: return Color(red: 1.0, green: 0.95, blue: 0.5) // Lemon Sherbet
                case .pastelOrange: return Color(red: 1.0, green: 0.7, blue: 0.5) // Peach Puff
                case .pastelPurple: return Color(red: 0.8, green: 0.6, blue: 1.0) // Soft Neon Violet
                case .pastelMint: return Color(red: 0.5, green: 1.0, blue: 0.8) // Aqua Mint
                case .pastelCoral: return Color(red: 1.0, green: 0.6, blue: 0.6) // Soft Coral
                case .pastelLavender: return Color(red: 0.7, green: 0.7, blue: 1.0) // Periwinkle
                case .pastelSky: return Color(red: 0.5, green: 0.9, blue: 1.0) // Cyan Sky
                }
            }
        }
        
        var balance: Double {
            transactions.reduce(0) { total, transaction in
                switch transaction.type {
                case .income:
                    return total + transaction.amount
                case .outcome:
                    return total - transaction.amount
                }
            }
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addTransactionButtonTapped
        case editNameButtonTapped
        case deleteTransaction(IndexSet)
        case deleteTransactionWithId(UUID)
        case addTransaction(PresentationAction<TransactionFeature.Action>)
        case editChild(PresentationAction<EditChildFeature.Action>)
        case setAvatarData(Data?)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case deleteChild
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .editNameButtonTapped:
                state.editChild = EditChildFeature.State(id: UUID(), name: state.name, themeColor: state.themeColor, avatar: state.avatar, avatarData: state.avatarData)
                return .none
                
            case let .setAvatarData(data):
                state.avatarData = data
                return .none
                
            case .delegate:
                return .none

            case .addTransactionButtonTapped:
                state.addTransaction = TransactionFeature.State(transaction: Transaction(id: UUID(), amount: 0, description: "", date: Date(), type: .income))
                return .none
                
            case let .editChild(.presented(.delegate(.saveChild(name, themeColor, avatar, avatarData)))):
                state.name = name
                state.themeColor = themeColor
                state.avatar = avatar
                state.avatarData = avatarData
                return .none
                
            case .editChild:
                return .none
                
            case let .deleteTransaction(indexSet):
                state.transactions.remove(atOffsets: indexSet)
                return .none

            case let .deleteTransactionWithId(id):
                state.transactions.remove(id: id)
                return .none
                
            case let .addTransaction(.presented(.delegate(.saveTransaction(transaction)))):
                state.transactions.insert(transaction, at: 0)
                return .none
                
            case .addTransaction:
                return .none
            }
        }
        .ifLet(\.$addTransaction, action: \.addTransaction) {
            TransactionFeature()
        }
        .ifLet(\.$editChild, action: \.editChild) {
            EditChildFeature()
        }
    }
}
