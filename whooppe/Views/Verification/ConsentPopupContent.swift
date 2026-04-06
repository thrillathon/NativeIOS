import SwiftUI

struct ConsentPopupContent: View {
    let title: String
    let message: String
    let onAgree: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Important Information")
                    .font(.custom("Spectral", size: 18))
                    .foregroundColor(.black)
                Spacer()
                Color.clear.frame(width: 24)
            }
            .frame(height: 56)
            .padding(.horizontal, 24)
            .background(Color.white)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(message)
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineLimit(nil)
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            print("\n❌ [WHOOPPE AUTH] USER DECLINED CONSENT")
                            print("[WHOOPPE AUTH] Button: Cancel Tapped\n")
                            onCancel()
                        }) {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            print("\n✅ [WHOOPPE AUTH] USER AGREED TO CONSENT")
                            print("[WHOOPPE AUTH] Button: I Agree Tapped\n")
                            onAgree()
                        }) {
                            Text("I Agree & Continue →")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ConsentPopupContent(
        title: "Why we ask for Government ID",
        message: "To enable Face Entry",
        onAgree: {},
        onCancel: {}
    )
}
