import SwiftUI

struct UserInfoScreen: View {
    let phone: String

    @State private var name = ""
    @State private var email = ""
    @State private var selectedState = "Rajasthan"
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var navigateToHome = false

    private let apiService = APIService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer()
                Text("Complete Your Profile")
                    .font(.custom("Spectral", size: 18))
                Spacer()
            }
            .frame(height: 56)
            .padding(.horizontal, 24)
            .background(Color(hex: "#D4B547"))

            Divider()

            ScrollView {
                VStack(spacing: 24) {
                    // Subtitle
                    Text("Tell us a bit about yourself to get started.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Full Name")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter your name", text: $name)
                            .padding()
                            .background(Color(hex: "#F5F5F0"))
                            .cornerRadius(8)
                    }

                    // Email
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(hex: "#F5F5F0"))
                            .cornerRadius(8)
                    }

                    // State picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("State")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Menu {
                            ForEach(EditProfileScreen.indianStates, id: \.self) { state in
                                Button(state) { selectedState = state }
                            }
                        } label: {
                            HStack {
                                Text(selectedState)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(hex: "#F5F5F0"))
                            .cornerRadius(8)
                        }
                    }

                    // Phone (read-only)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Phone")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(phone)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "#F5F5F0"))
                            .cornerRadius(8)
                            .foregroundColor(.gray)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Get Started")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(Color(hex: "#D4B547"))
                    .cornerRadius(10)
                    .disabled(isSaving)
                }
                .padding(24)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToHome) {
            HomeScreen()
        }
    }

    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your name."
            return
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email."
            return
        }
        errorMessage = nil
        isSaving = true
        Task {
            do {
                try await apiService.completeProfile(name: name, email: email, state: selectedState)
                await MainActor.run {
                    isSaving = false
                    navigateToHome = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
