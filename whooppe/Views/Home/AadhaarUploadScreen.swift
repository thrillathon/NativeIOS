import SwiftUI

// MARK: - Upload Content Screens
struct AadhaarUploadContentScreen: View {
    @ObservedObject var viewModel: AadhaarVerificationViewModel
    @Binding var showCamera: Bool
    @Binding var cameraForSelfie: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            CommonTopBar(title: "Government ID Verification", onBack: { dismiss() })
            
            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal, 26)
            
            VStack(spacing: 20) {
                
                if let imageUrl = viewModel.aadhaarImageUri {
                    AsyncImage(url: imageUrl) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit().frame(height: 200).cornerRadius(12)
                        } else if phase.error != nil {
                            Image(systemName: "photo.fill").font(.system(size: 60)).foregroundColor(.gray)
                        } else {
                            ProgressView()
                        }
                    }
                    .padding()
                    Button("Remove Image") {
                        viewModel.onRemoveAadhaarImage()
                    }
                    .foregroundColor(.red)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "doc.viewfinder").font(.system(size: 40)).foregroundColor(.gray)
                                Text("Preview").foregroundColor(.gray)
                            }
                        )
                        .padding()
                }
                
                TextField("Enter the full name as per Govt. ID", text: $viewModel.fullNameAsPerAadhaar)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onChange(of: viewModel.fullNameAsPerAadhaar) { newValue in
                        viewModel.onNameChange(newValue)
                    }
                
                HStack(spacing: 16) {
                    Button("Gallery") { }
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#D4B547"), lineWidth: 1))
                    
                    Button("Camera") {
                        cameraForSelfie = false
                        showCamera = true
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                    .background(Color(hex: "#D4B547")).foregroundColor(.white).cornerRadius(10)
                }
                .padding(.horizontal)
                
                if viewModel.aadhaarImageUri != nil {
                    Button("Upload") {
                        Task { await viewModel.onAadhaarUploadClick() }
                    }
                    .frame(width: 202, height: 32)
                    .background(Color(hex: "#FF6B35")).foregroundColor(.white).cornerRadius(10)
                    .disabled(viewModel.isLoading)
                    
                    if viewModel.isLoading {
                        HStack {
                            ProgressView().scaleEffect(0.8)
                            Text("Uploading Govt. ID...").font(.system(size: 14)).foregroundColor(Color(hex: "#FF6B35"))
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 14) {
                    Button("Terms and Condition") { }.font(.system(size: 10, weight: .bold))
                    Button("Privacy Policy") { }.font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.bottom, 50)
            }
            .padding(.top, 20)
            .background(Color.white)
            .navigationTitle("Your Tickets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#D4B547"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                // Remove the default back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

// MARK: - Camera Capture Screen
struct CameraCaptureScreen: View {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            Text("Camera View").font(.title).padding()
            Button("Capture Photo") {
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 300))
                let image = renderer.image { ctx in
                    UIColor.blue.setFill()
                    ctx.fill(CGRect(x: 0, y: 0, width: 300, height: 300))
                }
                onImageCaptured(image)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            Button("Cancel") { dismiss() }.padding()
            Spacer()
        }
        .background(Color.black.opacity(0.9))
    }
}
