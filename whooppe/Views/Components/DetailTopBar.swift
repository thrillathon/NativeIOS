import SwiftUI

struct DetailTopBar: View {
    let title: String
    let showDivider: Bool
    
    init(title: String, onBackClick: @escaping () -> Void, showDivider: Bool = true) {
        self.title = title
        self.showDivider = showDivider
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                
                Text(title)
                    .font(.custom("Spectral", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#333333"))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            Spacer().frame(height: 13)
            
            if showDivider {
                Divider()
                    .background(Color(hex: "#D9D9D9"))
                    .padding(.horizontal, 22)
            }
        }
        .background(Color.white)
    }
}
