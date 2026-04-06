import SwiftUI

struct ProfileScreen: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var tokenManager: TokenManager
    @State private var showLogoutDialog = false
    @State private var isHelpExpanded = false
    @State private var isVersionExpanded = false
    @State private var navigateToEditProfile = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Bar
                ProfileTopBar(
                    userName: viewModel.userName,
                    onEdit: { navigateToEditProfile = true }
                )
                
                ScrollView {
                    VStack(spacing: 0) {
                        NavigationLink(value: Routes.yourTickets) {
                            ProfileMenuItem(icon: "ticket", title: "Your Tickets")
                        }
                        
                        NavigationLink(value: Routes.aadhaarVerification) {
                            ProfileMenuItem(icon: "faceid", title: "Face Verification")
                        }
                        
                        NavigationLink(value: Routes.contactRangmunch) {
                            ProfileMenuItem(icon: "list.bullet", title: "List Your Show", subtitle: "Partner with Us")
                        }
                        
                        NavigationLink(value: Routes.privacyPolicy) {
                            ProfileMenuItem(icon: "lock.shield", title: "Privacy Policy")
                        }
                        
                        NavigationLink(value: Routes.termsAndConditions) {
                            ProfileMenuItem(icon: "doc.text", title: "Terms & Conditions")
                        }
                        
                        ProfileMenuItemExpandable(
                            icon: "questionmark.circle",
                            title: "Help Center",
                            isExpanded: $isHelpExpanded,
                            expandedContent: AnyView(
                                VStack(alignment: .leading, spacing: 4) {
                                    Button("Customer Support via Whatsapp") {
                                        if let url = URL(string: "https://wa.me/15557227832?text=Hello") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    Text("support.whooppe@thrillathon.co.in")
                                        .underline()
                                        .foregroundColor(.black)
                                }
                            )
                        )
                        
                        ProfileMenuItemExpandable(
                            icon: "number",
                            title: "Version",
                            isExpanded: $isVersionExpanded,
                            expandedContent: AnyView(Text("Version 1.0.0"))
                        )
                        
                        Button(action: { showLogoutDialog = true }) {
                            ProfileMenuItem(icon: "rectangle.portrait.and.arrow.right", title: "Logout")
                        }
                    }
                }
            }
            .background(Color.white)
            .alert("Logout", isPresented: $showLogoutDialog) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .onChange(of: viewModel.logoutSuccess) { success in
                if success {
                    tokenManager.clearAll()
                    // Navigate to onboarding
                }
            }
            .task {
                viewModel.refreshUserData()
            }
            .navigationDestination(for: String.self) { destination in
                if destination == Routes.yourTickets {
                    YourTicketsScreen()
                } else if destination == Routes.aadhaarVerification {
                    AadhaarVerificationScreen()
                } else if destination == Routes.contactRangmunch {
                    ContactRangmunchScreen()
                } else if destination == Routes.privacyPolicy {
                    PrivacyPolicyScreen()
                } else if destination == Routes.termsAndConditions {
                    TermsScreen()
                } else {
                    EmptyView()
                }
            }
            .navigationDestination(isPresented: $navigateToEditProfile) {
                EditProfileScreen(
                    name: viewModel.userName,
                    email: viewModel.userEmail,
                    phone: viewModel.userPhone,
                    state: viewModel.userState
                )
            }
        }
    }
    
    struct ProfileTopBar: View {
        let userName: String
        let onEdit: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                
                    Text(userName)
                        .font(.custom("Spectral", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                Button(action: onEdit) {
                    HStack(spacing: 0) {
                        Text("Edit profile")
                            .font(.custom("Spectral", size: 14))
                        Text(">")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color(hex: "#D4B547"))
        }
    }
    
    struct ProfileMenuItem: View {
        let icon: String
        let title: String
        var subtitle: String? = nil
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                        .frame(width: 22)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 24)
                .frame(height: 60)
                
                Divider()
                    .padding(.horizontal, 24)
                    .background(Color.gray.opacity(0.3))
            }
        }
    }
    
    struct ProfileMenuItemExpandable: View {
        let icon: String
        let title: String
        @Binding var isExpanded: Bool
        let expandedContent: AnyView
        
        var body: some View {
            VStack(spacing: 0) {
                Button(action: { isExpanded.toggle() }) {
                    HStack(spacing: 16) {
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                            .frame(width: 22)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                    .padding(.horizontal, 24)
                    .frame(height: 60)
                }
                
                if isExpanded {
                    expandedContent
                        .padding(.leading, 62)
                        .padding(.trailing, 24)
                        .padding(.bottom, 16)
                }
                
                Divider()
                    .padding(.horizontal, 24)
                    .background(Color.gray.opacity(0.3))
            }
        }
    }
    
}
