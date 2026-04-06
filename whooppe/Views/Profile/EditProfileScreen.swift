import SwiftUI

struct EditProfileScreen: View {
    @Environment(\.dismiss) var dismiss

    static let indianStates = [
        "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar",
        "Chhattisgarh", "Goa", "Gujarat", "Haryana", "Himachal Pradesh",
        "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra",
        "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab",
        "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura",
        "Uttar Pradesh", "Uttarakhand", "West Bengal",
        "Andaman and Nicobar Islands", "Chandigarh",
        "Dadra and Nagar Haveli and Daman and Diu", "Delhi",
        "Jammu and Kashmir", "Ladakh", "Lakshadweep", "Puducherry"
    ]

    @State private var name: String
    @State private var email: String
    let phone: String
    @State private var selectedState: String

    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var saveSuccess = false

    private let apiService = APIService()

    init(name: String, email: String, phone: String, state: String) {
        _name  = State(initialValue: name)
        _email = State(initialValue: email)
        self.phone = phone
        _selectedState = State(initialValue: state.isEmpty ? "Rajasthan" : state)
    }

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
                Text("Edit Profile")
                    .font(.custom("Spectral", size: 18))
                Spacer()
                Color.clear.frame(width: 24)
            }
            .frame(height: 56)
            .padding(.horizontal, 24)
            .background(Color.white)

            Divider()

            ScrollView {
                VStack(spacing: 20) {
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
                        Text(phone.isEmpty ? "—" : phone)
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
                    }

                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Save Changes")
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
        .alert("Success", isPresented: $saveSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your profile has been updated.")
        }
    }

    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Name cannot be empty."
            return
        }
        errorMessage = nil
        isSaving = true
        Task {
            do {
                _ = try await apiService.completeProfile(name: name, email: email, state: selectedState)
                await MainActor.run {
                    isSaving = false
                    saveSuccess = true
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
