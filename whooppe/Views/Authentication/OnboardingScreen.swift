import SwiftUI

struct OnboardingScreen: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var tokenManager: TokenManager
    @State private var navigateToOtp = false
    @State private var tempPhone = ""
    
    var body: some View {
        ZStack {
            // Background Image
            Image("onboarding_back")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Bottom Card
                VStack(spacing: 20) {
                    Text("India's Smart \(Text("Facial Recognition").bold()) Event Ticketing Platform")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "#333333"))
                    
                    // Divider with text
                    HStack {
                        Rectangle()
                            .fill(Color(hex: "#E5E5E5"))
                            .frame(height: 1)
                        Text("Log in or sign up")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        Rectangle()
                            .fill(Color(hex: "#E5E5E5"))
                            .frame(height: 1)
                    }
                    .padding(.horizontal)
                    
                    // Phone Input
                    HStack(spacing: 14) {
                        // Indian Flag
                        IndianFlagView()
                            .frame(width: 71, height: 51)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Phone Number Field
                        HStack {
                            Text("+91")
                                .foregroundColor(.black)
                            Divider()
                                .frame(height: 30)
                            TextField("Enter Mobile Number", text: $viewModel.mobileNumber)
                                .keyboardType(.numberPad)
                        }
                        .frame(height: 51)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.errorMessage != nil ? Color.red : Color.black, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 100)
                    } else {
                        Spacer().frame(height: 39)
                    }
                    
                    // Let's Go Button
                    Button(action: {
                        viewModel.verifyPhone()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Let's Go...")
                                .font(.system(size: 20))
                        }
                    }
                    .frame(width: 349, height: 51)
                    .background(Color(hex: "#D4B547"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(viewModel.isLoading)
                    
                    // Terms
                    VStack(spacing: 4) {
                        Text("By clicking **Let's Go**, you accept our")
                            .font(.system(size: 10))
                        
                        HStack(spacing: 14) {
                            Button("Terms and Condition") {
                                // Navigate to Terms
                            }
                            .font(.system(size: 10, weight: .bold))
                            Button("Privacy Policy") {
                                // Navigate to Privacy
                            }
                            .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.black)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .background(Color(hex: "#F5F5F0"))
                .cornerRadius(40, corners: [.topLeft, .topRight])
            }
        }
        .navigationDestination(isPresented: $navigateToOtp) {
            RegisterScreen(phone: tempPhone)
        }
        .onReceive(viewModel.$navigationEvent) { event in
            if case .navigateToOtp(let phone, _) = event {
                tempPhone = phone
                navigateToOtp = true
            }
        }
    }
}

struct IndianFlagView: View {
    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let stripeHeight = height / 3
            
            // Saffron
            context.fill(
                Path(CGRect(x: 0, y: 0, width: width, height: stripeHeight)),
                with: .color(Color(hex: "#FF9933"))
            )
            // White
            context.fill(
                Path(CGRect(x: 0, y: stripeHeight, width: width, height: stripeHeight)),
                with: .color(.white)
            )
            // Green
            context.fill(
                Path(CGRect(x: 0, y: stripeHeight * 2, width: width, height: stripeHeight)),
                with: .color(Color(hex: "#138808"))
            )
            
            // Ashoka Chakra
            let center = CGPoint(x: width / 2, y: height / 2)
            let radius = stripeHeight * 0.4
            context.stroke(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(Color(hex: "#000080")),
                lineWidth: radius * 0.08
            )
        }
        .frame(width: 53, height: 35)
    }
}
