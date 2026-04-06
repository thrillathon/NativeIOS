import SwiftUI

struct FloatingButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(Color(hex: "#D4B547"))
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .cornerRadius(15)
                
                
                Text("IPL")
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.white)


            }
        }
    }
}
