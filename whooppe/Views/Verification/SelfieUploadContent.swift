import SwiftUI

struct SelfieUploadContent: View {
    @ObservedObject var viewModel: AadhaarVerificationViewModel
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
                Text("Upload Selfie")
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
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("Take Selfie")
                            .font(.headline)
                        
                        Text("Please take a clear selfie for face verification")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
            
                    Button(action: {
                        // Trigger camera
                        print("\n📌 [WHOOPPE AUTH] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        print("📱 [WHOOPPE AUTH] Opening Camera for Selfie Capture")
                        print("[WHOOPPE AUTH] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
                        // Simulate capturing a selfie with a sample image
                        let sampleImage = UIImage(systemName: "person.crop.circle") ?? UIImage()
                        viewModel.onSelfieImageCaptured(sampleImage)
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Selfie")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 16)
                    
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
    SelfieUploadContent(viewModel: AadhaarVerificationViewModel())
}
