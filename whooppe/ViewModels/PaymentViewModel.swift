import Foundation
import Combine

class PaymentViewModel: ObservableObject {
    @Published var eventName = ""
    @Published var eventId = ""
    @Published var venue = ""
    @Published var date = ""
    @Published var time = ""
    @Published var language = ""
    @Published var locationLink = ""
    @Published var ticketPrice: Double = 0
    @Published var ticketName = ""
    @Published var seatingId = ""
    @Published var userId = ""
    @Published var faceId = ""
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var userPhone = ""
    @Published var state = ""
    @Published var isFaceVerified = false
    @Published var isSmartEntryChecked = false
    @Published var isLoading = false
    @Published var isVerifyingPayment = false
    @Published var shouldOpenRazorpay = false
    @Published var razorpayOrderId = ""
    @Published var key = ""
    @Published var convenienceFeeData: ConvenienceFeeData?
    @Published var isConvenienceFeeExpanded = false
    @Published var showPaymentSuccessDialog = false
    @Published var showPaymentFailedDialog = false
    @Published var paymentResult: PaymentResult?
    @Published var errorMessage: String?
    @Published var canDismissVerification = false
    
    private let paymentRepository: PaymentRepositoryProtocol
    private let apiService = APIService.shared
    
    init(paymentRepository: PaymentRepositoryProtocol? = nil) {
        self.paymentRepository = paymentRepository ?? PaymentRepository()
    }
    
    func loadPaymentDetails(eventId: String, seatingId: String, ticketPrice: Double) async {
        await MainActor.run { isLoading = true }
        
        do {
            // Fetch convenience fee data from repository
            let feeData = try await paymentRepository.getConvenienceFee(amount: ticketPrice)
            
            // Fetch user profile data
            do {
                let profileData = try await apiService.getUserProfileData()
                await MainActor.run {
                    self.userId = profileData.user?.userId ?? ""
                    self.userName = profileData.user?.name ?? ""
                    self.userEmail = profileData.user?.email ?? ""
                    self.userPhone = profileData.user?.phone ?? ""
                    self.state = profileData.user?.state ?? ""
                    self.faceId = profileData.faceVerification?.faceId ?? ""
                    self.isFaceVerified = profileData.faceVerification?.verified ?? false
                }
            } catch {
                // Continue even if profile fetch fails
                print("Failed to fetch user profile: \(error)")
            }
            
            await MainActor.run {
                self.convenienceFeeData = feeData
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func createPaymentOrder(eventId: String, seatingId: String, amount: Double) async {
        await MainActor.run { isLoading = true }
        
        do {
            let orderResponse = try await paymentRepository.createPaymentOrder(
                amount: amount,
                eventId: eventId,
                seatingId: seatingId
            )
            
            await MainActor.run {
                self.razorpayOrderId = orderResponse.razorpayOrderId
                self.key = orderResponse.key
                self.isLoading = false
                self.shouldOpenRazorpay = true
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func verifyPayment(orderId: String, paymentId: String, signature: String) async {
        await MainActor.run { isVerifyingPayment = true }
        
        do {
            let response = try await paymentRepository.verifyPayment(
                paymentId: paymentId,
                signature: signature,
                orderId: orderId
            )
            
            await MainActor.run {
                if response.isSuccess {
                    self.paymentResult = .success
                    self.showPaymentSuccessDialog = true
                } else {
                    self.paymentResult = .failed(errorMessage: response.message ?? "Payment verification failed")
                    self.showPaymentFailedDialog = true
                }
                self.isVerifyingPayment = false
            }
        } catch {
            await MainActor.run {
                self.paymentResult = .failed(errorMessage: error.localizedDescription)
                self.showPaymentFailedDialog = true
                self.isVerifyingPayment = false
            }
        }
    }
    
    func toggleConvenienceFee() {
        isConvenienceFeeExpanded.toggle()
    }
    
    func setSmartEntryChecked(_ checked: Bool) {
        isSmartEntryChecked = checked
    }
    
    func openRazorpayCheckout() {
        // Prepare to open Razorpay checkout
        Task {
            await createPaymentOrder(
                eventId: eventId,
                seatingId: seatingId,
                amount: convenienceFeeData?.totalAmount ?? ticketPrice
            )
        }
    }
    
    func razorpayOpened() {
        shouldOpenRazorpay = false
        isVerifyingPayment = true
    }
    
    func dismissPaymentSuccessDialog() {
        showPaymentSuccessDialog = false
    }
    
    func dismissPaymentFailedDialog() {
        showPaymentFailedDialog = false
    }
    
    func dismissVerificationOverlay() {
        isVerifyingPayment = false
    }
    
    func refreshUserData() {
        // Refresh user data from API
        Task {
            do {
                let profileData = try await apiService.getUserProfileData()
                
                await MainActor.run {
                    self.userId = profileData.user?.userId ?? ""
                    self.userName = profileData.user?.name ?? ""
                    self.userEmail = profileData.user?.email ?? ""
                    self.userPhone = profileData.user?.phone ?? ""
                    self.state = profileData.user?.state ?? ""
                    self.faceId = profileData.faceVerification?.faceId ?? ""
                    self.isFaceVerified = profileData.faceVerification?.verified ?? false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load user profile: \(error.localizedDescription)"
                }
            }
        }
    }

    func verifyFaceStatus(faceId: String) async {
        await MainActor.run { isLoading = true }
        
        do {
            let response = try await paymentRepository.verifyFaceStatus(faceId: faceId, userId: userId)
            
            await MainActor.run {
                self.isFaceVerified = response.data?.verified ?? false
                self.isLoading = false
                
                if !self.isFaceVerified {
                    self.errorMessage = response.message ?? "Face verification failed"
                }
            }
        } catch {
            await MainActor.run {
                self.isFaceVerified = false
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func onAppResumedFromCheckout() {
        // Handle resume from Razorpay checkout
        isVerifyingPayment = true
    }
}

enum PaymentResult {
    case success
    case failed(errorMessage: String)
}
