import SwiftUI



struct OnboardingScreen: View {
        @StateObject private var viewModel = OnboardingViewModel()
        // Temporarily comment out environment object to avoid compile error if TokenManager isn't defined yet
        // @EnvironmentObject var tokenManager: TokenManager
        @State private var navigateToOtp = false
        @State private var navigateToTerms = false
        @State private var navigateToPrivacy = false
        @State private var tempPhone = ""
        @State private var tempIsNewUser = false
        
        var body: some View {
            GeometryReader { geo in
                let imageHeight: CGFloat = 550
                ScrollView(showsIndicators: false) {
                    VStack() {
                    ZStack {
                        Image("onboarding_back")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: imageHeight)
                            .clipped()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.3),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .center
                        )
                        .ignoresSafeArea()
                    }
                    .frame(height: imageHeight)
                   // .padding(.bottom,30)

                    VStack(spacing: 18) {
                            VStack() {
                                
                                Text("India's Smart \(Text("Facial Recognition").bold())")
                                    .font(.system(size: 18))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(hex: "#333333")) //Color(hex: "#333333")
                                    .lineLimit(2)
                                
                                Text("Event Ticketing Platform")
                                    .font(.system(size: 18))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(hex: "#333333")) //Color(hex: "#333333")
                                    .lineLimit(2)
                            }
                            
                            HStack {
                                Rectangle()
                                    .fill(Color(hex: "#E5E5E5"))    //Color(hex: "#E5E5E5")
                                    .frame(height: 1)
                                
                                Text("Log in or sign up")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .fixedSize()
                                
                                Rectangle()
                                    .fill(Color(hex: "#E5E5E5")) //Color(hex: "#E5E5E5")
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            
                            HStack(spacing: 10) {
                                IndianFlagView()
                                    .frame(width: 60, height: 45)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                HStack(spacing: 8) {
                                    Text("+91")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Divider()
                                        .frame(height: 24)
                                    
                                    TextField("Enter Mobile Number", text: $viewModel.mobileNumber)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 14))
                                }
                                .frame(height: 45)
                                .padding(.horizontal, 10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(viewModel.errorMessage != nil ? Color.red : Color.black, lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 16)
                            
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                            }
                            
                            Button(action: {
                                viewModel.verifyPhone()
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Let's Go...")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(hex: "#D4B547")) //Color(hex: "#D4B547")
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(viewModel.isLoading)
                            .padding(.horizontal, 16)
                        
                        Spacer()
                            
                            VStack(spacing: 6) {
                                Text("By clicking **Let's Go**, you accept our")
                                    .font(.system(size: 10))
                                
                                HStack(spacing: 12) {
                                    Button("Terms and Condition") {
                                        navigateToTerms = true
                                    }
                                    .font(.system(size: 10, weight: .bold))
                                    
                                    Text("|")
                                    
                                    Button("Privacy Policy") {
                                        navigateToPrivacy = true
                                    }
                                    .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, max(geo.safeAreaInsets.bottom, 16))
                    .background(Color(hex: "#F5F5F0"))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                    )
                        .offset(y: -(imageHeight * 0.15))
                        .padding(.bottom, 30)
                    }
                   // .padding(.top,20)
                }
                .background(Color(hex: "#F5F5F0").ignoresSafeArea())
                .ignoresSafeArea(edges: .top)
                .navigationDestination(isPresented: $navigateToOtp) {
                    RegisterScreen(phone: tempPhone, isNewUser: tempIsNewUser)
                }
                .onChange(of: viewModel.navigationEvent) { event in
                    guard let event else { return }
                    switch event {
                    case .navigateToOtp(let phone, let isNewUser):
                        if true {
                            tempPhone = phone
                            tempIsNewUser = isNewUser
                            navigateToOtp = true
                        }
                    }
                    viewModel.navigationEvent = nil
                }
                .onChange(of: viewModel.mobileNumber) { _ in
                    viewModel.errorMessage = nil
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
