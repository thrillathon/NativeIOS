import SwiftUI

struct AadhaarVerificationScreen: View {
    @StateObject private var viewModel = AadhaarVerificationViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showInfoDialog = true
    @State private var showCamera = false
    @State private var cameraForSelfie = false
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
    
    // MAIN CONTENT ALWAYS RENDERED
    switch viewModel.currentStep {
    case .buttonScreen:
        ButtonScreenContent(viewModel: viewModel, dismiss: dismiss)
    case .initialPopup:
        InitialPopupContent(
            onAgree: {
                Task { await viewModel.onContinueFromPopup() }
            },
            onCancel: { viewModel.navigateToButtonScreen() }
        )
    case .uploadAadhaar:
        AadhaarUploadContentScreen(viewModel: viewModel, showCamera: $showCamera, cameraForSelfie: $cameraForSelfie)
    case .uploadSelfie:
        SelfieUploadContentScreen(viewModel: viewModel, showCamera: $showCamera, cameraForSelfie: $cameraForSelfie)
    }

    // ✅ FULL SCREEN LOADER OVERLAY
    if isLoading {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
        
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: Color(hex: "#D4B547"))
                )
                .scaleEffect(1.5)
            
            Text("Loading your pass...")
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
    }
}
        .overlay {
            if showInfoDialog {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showInfoDialog = false }
                    .overlay {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Why we ask for Government ID")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("To enable Face Entry at events, we need to verify that the face you upload belongs to a real person. Your government ID helps us confirm your identity once, so your face can be used for fast and secure entry at events.")

                                Text("• Your ID is used only for verification.")
                                Text("• It is securely encrypted and never shared with event organizers or third parties.")
                                Text("• This step is only required for Smart Face Entry events.")
                                Text("• Prefer not to upload an ID? No problem. You can skip this step and continue using WHOOPPE as a regular ticketing app. You'll simply receive a QR ticket for entry instead of facial entry.")
                            }
                            .font(.body)

                            HStack {
                                Button("OK, Got it") {
                                    showInfoDialog = false
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .padding(.bottom, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 10)
                        )
                        .padding(24)
                    }
            }
        }
        .task {
            await viewModel.loadUserProfile()
            isLoading = false
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureScreen { image in
                if cameraForSelfie {
                    viewModel.onSelfieImageCaptured(image)
                } else {
                    viewModel.onAadhaarImageCaptured(image)
                }
                showCamera = false
            }
        }
        .onChange(of: viewModel.verificationSuccess) { success in
            if success {
                Task {
                    await viewModel.refreshUserProfile()
                }
            }
        }
    }
}

// MARK: - Button Screen Content
struct ButtonScreenContent: View {
    @ObservedObject var viewModel: AadhaarVerificationViewModel
    let dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: 0) {
        
            ScrollView {
                VStack(spacing: 24) {
                    PassCardView(viewModel: viewModel)
                    
                    AadhaarUploadButtonView {
                        viewModel.onInitialButtonClick()
                    }
                    
                    SelfieUploadButtonView {
                        if viewModel.aadhaarUploaded {
                            viewModel.onSelfieButtonClick()
                        } else {
                            print("Please upload your Government ID first")
                        }
                    }
                    
                    Spacer().frame(height: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Whooppe Authentication")
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

// MARK: - Pass Card
struct PassCardView: View {
    @ObservedObject var viewModel: AadhaarVerificationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Whooppe Authentication Pass")
                .font(.custom("Spectral", size: 17))
                .fontWeight(.bold)
            
            Divider()
            
            PassInfoRowView(label: "Your Name", value: viewModel.userName.isEmpty ? "Loading..." : viewModel.userName)
            PassInfoRowView(label: "Registered Mobile Number", value: viewModel.userPhone.isEmpty ? "Loading..." : viewModel.userPhone)
            PassInfoRowView(
                label: "Government ID",
                value: viewModel.aadhaarUploaded ? "Uploaded" : "Pending Upload",
                valueColor: viewModel.aadhaarUploaded ? .black : .gray
            )
            PassInfoRowView(
                label: "Name as per Govt. ID",
                value: viewModel.aadhaarFullName.isEmpty ? "Not Available" : viewModel.aadhaarFullName
            )
            PassInfoRowView(
                label: "Face/ Selfie Upload",
                value: viewModel.selfieUploaded ? "Uploaded" : "Pending Upload",
                valueColor: viewModel.selfieUploaded ? .black : .gray
            )
            PassInfoRowView(
                label: "Face Verification ID",
                value: viewModel.faceVerified ? "Generated" : "Pending",
                valueColor: viewModel.faceVerified ? .black : .gray
            )
            
            Divider()
            
            PassInfoRowView(
                label: "Status",
                value: viewModel.verificationStatus == "verified" ? "Verified" : "Pending Verification",
                valueColor: viewModel.verificationStatus == "verified" ? .black : .gray,
                isBold: true
            )
        }
        .padding(20)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PassInfoRowView: View {
    let label: String
    let value: String
    var valueColor: Color = .black
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#2196F3"))
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .fontWeight(isBold ? .bold : .regular)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Button Views
struct AadhaarUploadButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: "creditcard")
                    .font(.system(size: 20))
                Text("Upload Your Masked Government ID")
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .frame(height: 55)
            .background(Color(hex: "#F5F5F0"))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#D4B547"), lineWidth: 1)
            )
        }
        .foregroundColor(.black)
    }
}

struct SelfieUploadButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 20))
                Text("Upload Your Selfie")
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .frame(height: 55)
            .background(Color(hex: "#F5F5F0"))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#D4B547"), lineWidth: 1)
            )
        }
        .foregroundColor(.black)
    }
}




// MARK: - Initial Popup Content
struct InitialPopupContent: View {
    let onAgree: () -> Void
    let onCancel: () -> Void
    @State private var isChecked = false
    
    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 0) {
                    Spacer()
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Why we ask for Government ID")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("To enable Face Entry at events, we need to verify that the face you upload belongs to a real person.\n\nYour government ID helps us confirm your identity once, so your face can be used for fast and secure entry at events.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                                .onTapGesture { isChecked.toggle() }
                            Text("I agree to the privacy policy")
                                .font(.caption)
                        }
                        
                        HStack(spacing: 12) {
                            Button("Cancel", action: onCancel)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            
                            Button("Agree", action: onAgree)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isChecked ? Color(hex: "#D4B547") : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .disabled(!isChecked)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(24)
                    Spacer()
                }
            )
    }
}


