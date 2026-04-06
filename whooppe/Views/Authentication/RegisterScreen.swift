import SwiftUI
import Combine

struct RegisterScreen: View {
    let phone: String
    let isNewUser: Bool
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\..dismiss) var dismiss
    @FocusState private var focusedField: Int?
    @State private var otpDigits = ["", "", "", ""]
    @State private var resendTimer = 25
    @State private var canResend = false
    @State private var navigateToHome = false
    @State private var navigateToUserInfo = false

    init(phone: String, isNewUser: Bool = false) {
        self.phone = phone
        self.isNewUser = isNewUser
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
                
                
            }
            .padding(.horizontal, 16)
            .padding(.top, 22)
            
            
            
            VStack(spacing: 50) {
                // OTP Message
                VStack(spacing: 6) {
                    Text("Your OTP is almost at the speed of light as it travels to")
                        .font(.system(size: 14))
                    Text("+91-\(phone)")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // OTP Boxes
                HStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { index in
                        OTPTextField(text: $otpDigits[index], index: index, focusedField: $focusedField)
                            .disabled(viewModel.isVerifying)
                    }
                }
                .padding(.horizontal, 16)
                .opacity(viewModel.isVerifying ? 0.6 : 1.0)
                
                // Error Message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                } else if viewModel.isVerifying {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Verifying OTP...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                // WhatsApp Message
                HStack(spacing: 4) {
                    Text("It looks like the OTP hasn't come\nto your ")
                        .font(.system(size: 12))
                    Image(systemName: "message.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#25D366"))
                    Text("WhatsApp")
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                }
                .multilineTextAlignment(.center)
                
                // Resend
                if viewModel.isVerifying {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if canResend {
                    Button("Resend SMS") {
                        resendTimer = 25
                        canResend = false
                        viewModel.resendOtp(phone: phone)
                    }
                    .font(.system(size: 12, weight: .bold))
                } else {
                    Text("Resend SMS in \(resendTimer) sec")
                        .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color.white)
        .navigationTitle("OTP Authentication")
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
           .navigationBarBackButtonHidden(true) // Add this to hide default back button
        .navigationDestination(isPresented: $navigateToHome) {
            HomeScreen()
        }
        .navigationDestination(isPresented: $navigateToUserInfo) {
            UserInfoScreen(phone: phone)
        }
        .onChange(of: viewModel.otpVerified) { newValue in
            if newValue {
                print("🎯 OTP verified, isNewUser=\(isNewUser)")
                if isNewUser {
                    navigateToUserInfo = true
                } else {
                    navigateToHome = true
                }
            }
        }
        .onChange(of: otpDigits) { newValue in
            let otp = newValue.joined()
            print("📱 RegisterScreen - OTP changed: \(otpDigits) → \(otp)")
            if otp.count == 4 && otp.count == otp.filter({ !$0.isWhitespace }).count {
                print("✅ RegisterScreen - 4 digits entered, calling verifyOtp()")
                viewModel.verifyOtp(phone: phone, otp: otp)
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if resendTimer > 0 {
                resendTimer -= 1
            } else {
                canResend = true
            }
        }
        .onAppear {
            focusedField = 0
        }
    }
}

struct OTPTextField: View {
    @Binding var text: String
    let index: Int
    var focusedField: FocusState<Int?>.Binding
    
    var body: some View {
        TextField("", text: $text)
            .frame(height: 50)
            .background(Color(hex: "#F5F5F0"))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .focused(focusedField, equals: index)
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
                if newValue.count == 1 && index < 3 {
                    focusedField.wrappedValue = index + 1
                } else if newValue.isEmpty && index > 0 {
                    focusedField.wrappedValue = index - 1
                }
            }
    }
}
