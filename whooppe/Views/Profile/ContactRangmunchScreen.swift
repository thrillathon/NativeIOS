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
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20)

                        Group {
                            InputField(
                                label: "Full Name",
                                placeholder: "Enter your full name",
                                value: $viewModel.fullName,
                                isError: viewModel.fullNameError != nil,
                                errorText: viewModel.fullNameError
                            )

                            InputField(
                                label: "Email",
                                placeholder: "Enter your email",
                                value: $viewModel.email,
                                keyboardType: .emailAddress,
                                isError: viewModel.emailError != nil,
                                errorText: viewModel.emailError
                            )

                            InputField(
                                label: "Phone Number",
                                placeholder: "Enter 10-digit mobile number",
                                value: $viewModel.phone,
                                keyboardType: .phonePad,
                                isError: viewModel.phoneError != nil,
                                errorText: viewModel.phoneError
                            )

                            InputField(
                                label: "Organisation Name",
                                placeholder: "Enter your organisation name",
                                value: $viewModel.organizationName,
                                isError: viewModel.organizationNameError != nil,
                                errorText: viewModel.organizationNameError
                            )

                            InputField(
                                label: "City",
                                placeholder: "Enter your city",
                                value: $viewModel.city,
                                isError: viewModel.cityError != nil,
                                errorText: viewModel.cityError
                            )
                        }

                        Group {
                            DropdownField(
                                label: "State",
                                placeholder: "Select state",
                                options: ContactRangmunchViewModel.indianStates,
                                selection: $viewModel.state,
                                isError: viewModel.stateError != nil,
                                errorText: viewModel.stateError
                            )

                            DropdownField(
                                label: "Partnership Type",
                                placeholder: "Select type",
                                options: ContactRangmunchViewModel.partnershipTypes.map(\.display),
                                selection: Binding(
                                    get: { viewModel.partnershipTypeDisplay },
                                    set: { viewModel.partnershipTypeDisplay = $0 }
                                ),
                                isError: viewModel.partnershipTypeError != nil,
                                errorText: viewModel.partnershipTypeError
                            )

                            DropdownField(
                                label: "Event Type",
                                placeholder: "Select event type",
                                options: ContactRangmunchViewModel.eventTypes.map(\.display),
                                selection: Binding(
                                    get: { viewModel.eventTypeDisplay },
                                    set: { viewModel.eventTypeDisplay = $0 }
                                ),
                                isError: viewModel.eventTypeError != nil,
                                errorText: viewModel.eventTypeError
                            )

                            DropdownField(
                                label: "Experience Level",
                                placeholder: "Select experience level",
                                options: ContactRangmunchViewModel.experienceLevels.map(\.display),
                                selection: Binding(
                                    get: { viewModel.experienceLevelDisplay },
                                    set: { viewModel.experienceLevelDisplay = $0 }
                                ),
                                isError: viewModel.experienceLevelError != nil,
                                errorText: viewModel.experienceLevelError
                            )
                        }

                        // Message text area
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Message")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.black)
                                Spacer()
                                Text("\(viewModel.message.count)/2000")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }

                            ZStack(alignment: .topLeading) {
                                if viewModel.message.isEmpty {
                                    Text("Describe your proposal (min. 20 characters)...")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.gray.opacity(0.5))
                                        .padding(.horizontal, 11)
                                        .padding(.top, 10)
                                }
                                TextEditor(text: $viewModel.message)
                                    .font(.system(size: 13))
                                    .scrollContentBackground(.hidden)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 6)
                                    .onChange(of: viewModel.message) { newVal in
                                        if newVal.count > 2000 {
                                            viewModel.message = String(newVal.prefix(2000))
                                        }
                                    }
                            }
                            .frame(minHeight: 110)
                            .background(Color(hex: "#F5F1E8"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(viewModel.messageError != nil ? Color.red : Color(hex: "#D4B547"), lineWidth: 1)
                            )

                            if let err = viewModel.messageError {
                                Text(err)
                                    .font(.system(size: 11))
                                    .foregroundColor(.red)
                                    .padding(.leading, 4)
                            }
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .padding(.leading, 10)
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                }

                // Send Button
                VStack(spacing: 0) {
                    Button(action: {
                        if !viewModel.isLoading {
                            Task { await viewModel.submitInquiry() }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Send Inquiry")
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

                    Spacer().frame(height: 20)
                }
                .background(Color(hex: "#F5F1E8"))
            }
            .background(Color.white)
            .navigationTitle("Contact Whooppe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#D4B547"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }

            // Toast
            VStack {
                Spacer()
                if showToast {
                    Text("Your inquiry has been submitted. We'll reach out within 24 hours.")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(Color(hex: "#FFD700"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
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
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { showToast = false }
                    viewModel.clearMessages()
                    viewModel.resetForm()
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Dropdown Field
struct DropdownField: View {
    let label: String
    let placeholder: String
    let options: [String]
    @Binding var selection: String
    let isError: Bool
    let errorText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? placeholder : selection)
                        .font(.system(size: 13))
                        .foregroundColor(selection.isEmpty ? Color.gray.opacity(0.5) : .black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 11)
                .frame(height: 35)
                .background(Color(hex: "#F5F1E8"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isError ? Color.red : Color(hex: "#D4B547"), lineWidth: 1)
                )
            }

            if isError, let errorText = errorText {
                Text(errorText)
                    .font(.system(size: 11))
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
}

// MARK: - Input Field
struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var value: String
    var keyboardType: UIKeyboardType = .default
    let isError: Bool
    let errorText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)

            HStack(spacing: 0) {
                TextField("", text: $value)
                    .placeholder(when: value.isEmpty) {
                        Text(placeholder).foregroundColor(Color.gray.opacity(0.5))
                    }
                    .font(.system(size: 13))
                    .keyboardType(keyboardType)
                    .padding(.horizontal, 11)
            }
            .frame(height: 35)
            .background(Color(hex: "#F5F1E8"))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isError ? Color.red : Color(hex: "#D4B547"), lineWidth: 1)
            )

            if isError, let errorText = errorText {
                Text(errorText)
                    .font(.system(size: 11))
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
}


// MARK: - Placeholder helper

#Preview {
    NavigationStack {
        ContactRangmunchScreen()
    }
}

