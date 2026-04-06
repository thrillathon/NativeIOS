import SwiftUI

struct ProceedBottomBar: View {
    let buttonText: String
    let onButtonClick: () -> Void
    let isLoading: Bool
    let enabled: Bool
    let buttonColor: Color
    
    init(buttonText: String = "Proceed to Payment",
         onButtonClick: @escaping () -> Void,
         isLoading: Bool = false,
         enabled: Bool = true,
         buttonColor: Color = Color(hex: "#D4B547")) {
        self.buttonText = buttonText
        self.onButtonClick = onButtonClick
        self.isLoading = isLoading
        self.enabled = enabled
        self.buttonColor = buttonColor
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 12)
            
            Button(action: onButtonClick) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(buttonText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 35)
            .background(buttonColor)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .disabled(!enabled || isLoading)
            
            Spacer().frame(height: 12)
            
            // Safe area spacer
            Color(hex: "#F5F5F0")
                .frame(height: UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first?.safeAreaInsets.bottom ?? 0)
        }
        .background(Color(hex: "#F5F5F0"))
    }
}
