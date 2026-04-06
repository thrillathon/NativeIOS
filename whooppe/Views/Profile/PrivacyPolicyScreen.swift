import SwiftUI

struct PrivacyPolicyScreen: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
          
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. Introduction")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("Welcome to Whooppe. We are committed to protecting your privacy and ensuring you have a positive experience on our platform. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our website, mobile app, and related services.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("2. Information We Collect")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("We may collect information about you in a variety of ways. The information we may collect on our application depends on the context of your interactions with us and the application, the choices you make, and the products and features you use.")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                                    .lineSpacing(2)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    PrivacyBulletPoint(text: "Personal identification information (name, email, phone number)")
                                    PrivacyBulletPoint(text: "Payment information (credit card, bank account details)")
                                    PrivacyBulletPoint(text: "Device information (device type, OS, IP address)")
                                    PrivacyBulletPoint(text: "Usage data (pages visited, time spent)")
                                }
                            }
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("3. Use of Your Information")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via our application to:")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                PrivacyBulletPoint(text: "Process your transactions")
                                PrivacyBulletPoint(text: "Send promotional communications")
                                PrivacyBulletPoint(text: "Respond to your inquiries")
                                PrivacyBulletPoint(text: "Improve our services")
                            }
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("4. Security of Your Information")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("We use administrative, technical, and physical security measures to protect your personal information. However, no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your personal information, we cannot guarantee its absolute security.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("5. Contact Us")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("If you have questions or comments about this Privacy Policy, please contact us at:")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email: support.whooppe@thrillathon.co.in")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.blue)
                                
                                Text("Last Updated: April 2026")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }
        }
        .background(Color.white)
        .navigationTitle("Privacy Policy")
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
}

struct PrivacyBulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .lineSpacing(1)
        }
    }
}

#Preview {
    PrivacyPolicyScreen()
}
