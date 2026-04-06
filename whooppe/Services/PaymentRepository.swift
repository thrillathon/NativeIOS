import Foundation

// MARK: - Repository Protocol
protocol PaymentRepositoryProtocol {
    func getConvenienceFee(amount: Double) async throws -> ConvenienceFeeData
    func createPaymentOrder(amount: Double, eventId: String, seatingId: String) async throws -> PaymentOrderData
    func initiateBooking(eventId: String, seatingId: String, numberOfTickets: Int) async throws -> InitiateBookingResponse
    func verifyPayment(paymentId: String, signature: String, orderId: String) async throws -> VerifyPaymentResponse
    func confirmBooking(bookingId: String, paymentId: String, isSmartEntry: Bool) async throws -> ConfirmBookingResponse
    func verifyFaceStatus(faceId: String, userId: String) async throws -> VerifyFaceStatusResponse
}

// MARK: - Repository Implementation
class PaymentRepository: PaymentRepositoryProtocol {
    private let apiService: APIService
    
    init(apiService: APIService = APIService.shared) {
        self.apiService = apiService
    }
    
    func getConvenienceFee(amount: Double) async throws -> ConvenienceFeeData {
        return try await apiService.getConvenienceFee(amount: amount)
    }
    
    func createPaymentOrder(amount: Double, eventId: String, seatingId: String) async throws -> PaymentOrderData {
        return try await apiService.createPaymentOrder(amount: amount, eventId: eventId, seatingId: seatingId)
    }
    
    func initiateBooking(eventId: String, seatingId: String, numberOfTickets: Int) async throws -> InitiateBookingResponse {
        return try await apiService.initiateBooking(eventId: eventId, seatingId: seatingId, numberOfTickets: numberOfTickets)
    }
    
    func verifyPayment(paymentId: String, signature: String, orderId: String) async throws -> VerifyPaymentResponse {
        return try await apiService.verifyPayment(paymentId: paymentId, signature: signature, orderId: orderId)
    }
    
    func confirmBooking(bookingId: String, paymentId: String, isSmartEntry: Bool) async throws -> ConfirmBookingResponse {
        return try await apiService.confirmBooking(bookingId: bookingId, paymentId: paymentId, isSmartEntry: isSmartEntry)
    }
    
    func verifyFaceStatus(faceId: String, userId: String) async throws -> VerifyFaceStatusResponse {
        return try await apiService.verifyFaceStatus(faceId: faceId, userId: userId)
    }
}

// MARK: - Models
struct BookingDetails: Codable {
    let eventId: String
    let status: String
}
