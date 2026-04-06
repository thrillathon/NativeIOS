import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var mobileNumber = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var navigationEvent: OnboardingNavigationEvent?
    
    private let apiService = APIService.shared
    private let tokenManager = TokenManager.shared
    
    func verifyPhone() {
        guard mobileNumber.count == 10 else {
            errorMessage = "Enter valid 10-digit mobile number"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await apiService.verifyPhone(phone: mobileNumber)
                await MainActor.run {
                    isLoading = false
                    navigationEvent = .navigateToOtp(phone: mobileNumber, phoneStatus: response.success)
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

enum OnboardingNavigationEvent {
    case navigateToOtp(phone: String, phoneStatus: Bool)
}
