import SwiftUI

struct TermsScreen: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            
           
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. Acceptance of Terms")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("By accessing and using Whooppe, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by any of the foregoing, please do not continue to access or use this service.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("2. Use License")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("We grant you a limited license to use our service for personal, non-commercial purposes. This license does not include:")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                TermsBulletPoint(text: "Modification or derivation of any content")
                                TermsBulletPoint(text: "Commercial use or purpose")
                                TermsBulletPoint(text: "Automated access")
                                TermsBulletPoint(text: "Circumventing any access controls")
                            }
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("3. Booking and Cancellation")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("When you book tickets through Whooppe:")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    TermsBulletPoint(text: "You agree to pay the full ticket price plus applicable fees")
                                    TermsBulletPoint(text: "Cancellations must be done within specified time limits")
                                    TermsBulletPoint(text: "Refunds will be processed according to our policy")
                                    TermsBulletPoint(text: "You are responsible for ticket accuracy at purchase")
                                }
                            }
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("4. User Responsibilities")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                TermsBulletPoint(text: "Maintain accurate personal information")
                                TermsBulletPoint(text: "Protect your account credentials")
                                TermsBulletPoint(text: "Comply with all applicable laws")
                                TermsBulletPoint(text: "Not engage in prohibited activities")
                            }
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("5. Limitation of Liability")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("Whooppe shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the service. This includes but is not limited to damages related to lost profits, data, or business opportunities.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("6. Dispute Resolution")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("Any disputes arising from your use of Whooppe shall be governed by and construed in accordance with the laws applicable in your jurisdiction.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("7. Changes to Terms")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("We reserve the right to modify these terms at any time. Your continued use of Whooppe following any changes constitutes your acceptance of the new terms.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                            
                            Text("Last Updated: April 2026")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }
        }
        .background(Color.white)
        .navigationTitle("Terms & Conditions")
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
            
    }
}

struct TermsBulletPoint: View {
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
    TermsScreen()
}
