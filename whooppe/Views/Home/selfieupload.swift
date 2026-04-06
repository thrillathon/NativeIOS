import SwiftUI

struct SelfieUploadContentScreen: View {
    @ObservedObject var viewModel: AadhaarVerificationViewModel
    @Binding var showCamera: Bool
    @Binding var cameraForSelfie: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            CommonTopBar(title: "Upload Selfie", onBack: { dismiss() })
            
            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal, 26)
            
            VStack(spacing: 20) {
                if let imageUrl = viewModel.selfieImageUri {
                    AsyncImage(url: imageUrl) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit().frame(height: 200).cornerRadius(12)
                        } else if phase.error != nil {
                            Image(systemName: "person.crop.circle.fill").font(.system(size: 60)).foregroundColor(.gray)
                        } else {
                            ProgressView()
                        }
                    }
                    .padding()
                    
                    Button("Remove Image") {
                        viewModel.onRemoveSelfieImage()
                    }
                    .foregroundColor(.red)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "person.crop.circle").font(.system(size: 40)).foregroundColor(.gray)
                                Text("Your Photo Preview").foregroundColor(.gray)
                            }
                        )
                        .padding()
                }
                
                TextField("Enter your full name", text: $viewModel.selfieFullName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onChange(of: viewModel.selfieFullName) { newValue in
                        viewModel.onSelfieNameChange(newValue)
                    }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Please upload a clear photo of your face. This will be matched with your Govt. ID photo for verification. Ensure good lighting and avoid wearing sunglasses or masks and caps.")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#666666"))
                        .lineSpacing(4)
                }
                .padding(12)
                .background(Color(hex: "#FFF8E1"))
                .cornerRadius(12)
                .padding(.horizontal)
                
                HStack(spacing: 16) {
                    Button("Gallery") { }
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#D4B547"), lineWidth: 1))
                    
                    Button("Camera") {
                        cameraForSelfie = true
                        showCamera = true
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                    .background(Color(hex: "#D4B547")).foregroundColor(.white).cornerRadius(10)
                }
                .padding(.horizontal)
                
                if viewModel.selfieImageUri != nil {
                    Button("Upload") {
                        Task { await viewModel.onSelfieUploadClick() }
                    }
                    .frame(width: 202, height: 32)
                    .background(Color(hex: "#FF6B35")).foregroundColor(.white).cornerRadius(10)
                    .disabled(viewModel.isLoading)
                    
                    if viewModel.isValidatingFace {
                        HStack {
                            ProgressView().scaleEffect(0.8)
                            Text("Validating face...").font(.system(size: 14)).foregroundColor(Color(hex: "#FF6B35"))
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
