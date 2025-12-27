import SwiftUI
import ComposableArchitecture

struct ChildCardView: View {
    let child: ChildFeature.State
    
    var body: some View {
        VStack {
            Spacer()
            
            // Avatar
            Group {
                Circle().fill(.white)
                    .frame(width: 140, height: 140)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
                    .overlay {
                        Group {
                            if let data = child.avatarData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(child.avatar.imageName)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())
                        
                    }
                    
            }
            Spacer().frame(height: 30)
            
            // Name
            Text(child.name)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Balance
            Text(formatBalance(child.balance))
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                .padding(.top, 8)
                
            Spacer()
        }
        .frame(width: 250, height: 400)
        .background(child.themeColor.color)
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .shadow(color: child.themeColor.color.opacity(0.4), radius: 15, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }
    
    func formatBalance(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}
