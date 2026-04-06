import SwiftUI
import Combine

struct ContactRangmunchScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ContactRangmunchViewModel()
    @State private var showToast = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                
                // Form Content
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 35)
                        
                        VStack(spacing: 20) {
                            InputField(
                                label: "Organisation name",
                                placeholder: "Enter the organisation name",
                                value: $viewModel.organisationName,
                                isError: viewModel.organisationNameError != nil,
                                errorText: viewModel.organisationNameError
                            )
                            
                            // Organisation email
                            InputField(
                                label: "Organisation email",
                                placeholder: "Enter the email",
                                value: $viewModel.organisationEmail,
                                keyboardType: .emailAddress,
                                isError: viewModel.organisationEmailError != nil,
                                errorText: viewModel.organisationEmailError
                            )
                            
                            // Contact name
                            InputField(
                                label: "Contact name",
                                placeholder: "Enter the name",
                                value: $viewModel.contactName,
                                isError: viewModel.contactNameError != nil,
                                errorText: viewModel.contactNameError
                            )
                            
                            // Contact number
                            InputField(
                                label: "Enter contact number",
                                placeholder: "Enter the contact person number",
                                value: $viewModel.contactNumber,
                                keyboardType: .phonePad,
                                isError: viewModel.contactNumberError != nil,
                                errorText: viewModel.contactNumberError
                            )
                            
                            // General error message
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.red)
                                    .padding(.leading, 10)
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                    }
                     .navigationTitle("Contact Whooppe  ")
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
                                    .foregroundColor(.black)                    }
                }
            }
            .navigationBarBackButtonHidden(true) // Add this to hide default back button
                }
                
                Spacer()
                
                // Send Button at bottom with yellow background
                VStack(spacing: 0) {
                    Button(action: {
                        if !viewModel.isLoading {
                            viewModel.sendContactForm()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Send")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 35)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .background(Color(hex: "#FFD700"))
                    .cornerRadius(10)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .disabled(viewModel.isLoading)
                    
                    // Yellow background fills to bottom (simulating nav bar)
                    VStack {
                        Spacer()
                    }
                    .frame(height: 20)
                    .background(Color(hex: "#F5F1E8"))
                }
                .background(Color(hex: "#F5F1E8"))
            }
            .background(Color.white)
            
            // Toast notification
            VStack {
                Spacer()
                
                if showToast {
                    VStack {
                        Text("Rangmunch team will reach out you within 24 hours.")
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(Color(hex: "#FFD700"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 35)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#FFFCF5"))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onChange(of: viewModel.successMessage) { newValue in
            if newValue != nil {
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showToast = false
                    viewModel.clearMessages()
                    viewModel.resetForm()
                    dismiss()
                }
            }
        }
    }
}

struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var value: String
    var keyboardType: UIKeyboardType = .default
    let isError: Bool
    let errorText: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
            
            // Input box
            HStack(spacing: 0) {
                TextField("", text: $value)
                    .placeholder(when: value.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                    .font(.system(size: 13, weight: .regular))
                    .keyboardType(keyboardType)
                    .padding(.horizontal, 11)
            }
            .frame(height: 35)
            .background(Color(hex: "#F5F1E8"))
            .border(
                isError ? Color.red : Color(hex: "#D4B547"),
                width: 1
            )
            .cornerRadius(10)
            
            // Error text
            if isError, let errorText = errorText {
                Text(errorText)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.red)
                    .padding(.leading, 4)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - ViewModel
class ContactRangmunchViewModel: ObservableObject {
    @Published var organisationName = ""
    @Published var organisationEmail = ""
    @Published var contactName = ""
    @Published var contactNumber = ""
    
    @Published var organisationNameError: String?
    @Published var organisationEmailError: String?
    @Published var contactNameError: String?
    @Published var contactNumberError: String?
    
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    
    init() {}
    
    func onOrganisationNameChange(_ value: String) {
        organisationName = value
        organisationNameError = nil
    }
    
    func onOrganisationEmailChange(_ value: String) {
        organisationEmail = value
        organisationEmailError = nil
    }
    
    func onContactNameChange(_ value: String) {
        contactName = value
        contactNameError = nil
    }
    
    func onContactNumberChange(_ value: String) {
        contactNumber = value
        contactNumberError = nil
    }
    
    func sendContactForm() {
        // Validate form
        var hasError = false
        
        if organisationName.trimmingCharacters(in: .whitespaces).isEmpty {
            organisationNameError = "Organisation name is required"
            hasError = true
        }
        
        if organisationEmail.trimmingCharacters(in: .whitespaces).isEmpty {
            organisationEmailError = "Organisation email is required"
            hasError = true
        } else if !isValidEmail(organisationEmail) {
            organisationEmailError = "Please enter a valid email"
            hasError = true
        }
        
        if contactName.trimmingCharacters(in: .whitespaces).isEmpty {
            contactNameError = "Contact name is required"
            hasError = true
        }
        
        if contactNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            contactNumberError = "Contact number is required"
            hasError = true
        } else if !isValidPhoneNumber(contactNumber) {
            contactNumberError = "Please enter a valid contact number"
            hasError = true
        }
        
        if hasError {
            return
        }
        
        // Submit form
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.successMessage = "Form submitted successfully"
        }
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    func resetForm() {
        organisationName = ""
        organisationEmail = ""
        contactName = ""
        contactNumber = ""
        organisationNameError = nil
        organisationEmailError = nil
        contactNameError = nil
        contactNumberError = nil
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10,}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))
    }
}

// Helper extensions
extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    ContactRangmunchScreen()
}
