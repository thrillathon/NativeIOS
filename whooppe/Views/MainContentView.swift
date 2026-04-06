import SwiftUI

struct MainContentView: View {
    @EnvironmentObject var tokenManager: TokenManager
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var isLoading = true
    @State private var startDestination: String = "OnBoarding"
    
    var body: some View {
        ZStack {
            if isLoading {
                SplashLoadingView()
            } else {
                NavigationStack {
                    Group {
                        if startDestination == "Home" {
                            HomeScreen()
                        } else {
                            OnboardingScreen()
                        }
                    }
                }
                .onAppear {
                    sessionManager.onSessionExpired = {
                        tokenManager.clearAll()
                        startDestination = "OnBoarding"
                    }
                }
            }
            
            // No internet banner
            if !networkMonitor.isConnected {
                VStack {
                    Spacer()
                    Text("No internet connection")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#E53935"))
                        .clipShape(Capsule())
                        .padding(.bottom, 80)
                        .transition(.move(edge: .bottom))
                }
                .animation(.easeInOut, value: networkMonitor.isConnected)
            }
        }
        .task {
            let hasToken = await tokenManager.isLoggedIn()
            startDestination = hasToken ? "Home" : "OnBoarding"
            isLoading = false
        }
    }
}

struct SplashLoadingView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#D4B547")))
                .scaleEffect(1.5)
        }
    }
}
