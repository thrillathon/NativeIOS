import SwiftUI

struct AadhaarUploadContent: View {
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
                Text("Upload Government ID")
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
                        Image(systemName: "doc.badge.ellipsis")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("Upload Aadhaar")
                            .font(.headline)
                        
                        Text("Please upload a clear image of your Aadhaar card")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
            
                    Button(action: {
                        // Trigger camera or image picker
                        print("\n📌 [WHOOPPE AUTH] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        print("📱 [WHOOPPE AUTH] Opening Camera for Document Capture")
                        print("[WHOOPPE AUTH] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
                        // Simulate capturing a document with a sample image
                        let sampleImage = UIImage(systemName: "doc.viewfinder") ?? UIImage()
                        viewModel.onAadhaarImageCaptured(sampleImage)
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Capture / Upload")
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
    AadhaarUploadContent(viewModel: AadhaarVerificationViewModel())
}
