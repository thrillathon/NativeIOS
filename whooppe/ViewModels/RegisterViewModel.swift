import Foundation
import Combine

class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var state = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registrationSuccess = false
    @Published var isVerifying = false
    @Published var otpVerified = false
    
    private let apiService = APIService.shared
    
    func registerUser() async {
        await MainActor.run { isLoading = true }
        
        await MainActor.run {
            isLoading = false
            registrationSuccess = true
        }
    }
    func verifyOtp(phone: String, otp: String) {
    isVerifying = true
    errorMessage = nil
    
    Task {
        do {
            // FIXED: Added try since the function can throw
            let response = try await apiService.verifyOtp(phone: phone, otp: otp)
            await MainActor.run {
                isVerifying = false
                if response.success {
                    print("✅ OTP Verification Successful")
                    
                    // Store tokens if provided
                    if let accessToken = response.accessToken {
                        if let userId = response.tempUserId, !userId.isEmpty {
                            print("💾 Storing access token for user: \(userId)")
                            TokenManager.shared.saveAccessToken(accessToken, userId: userId)
                            TokenManager.shared.logStorageStatus()
                        } else {
                            print("⚠️ No valid userId received from server: \(response.tempUserId ?? "nil")")
                            TokenManager.shared.saveAccessToken(accessToken)
                            TokenManager.shared.logStorageStatus()
                        }
                    }
                    
                    otpVerified = true
                } else {
                    errorMessage = response.message ?? "Invalid OTP"
                }
            }
        } catch {
            await MainActor.run {
                isVerifying = false
                errorMessage = error.localizedDescription
                print("❌ OTP Verification Error: \(error.localizedDescription)")
            }
        }
    }
}
    func resendOtp(phone: String) {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                let response = try await apiService.verifyPhone(phone: phone)
                await MainActor.run {
                    isLoading = false
                    if response.success {
                        errorMessage = nil
                    } else {
                        errorMessage = response.message ?? "Failed to resend OTP"
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
