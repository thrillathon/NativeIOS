import Foundation

// MARK: - Generic Response Wrapper
struct GenericResponse<T: Codable>: Codable {
    let status: String
    let message: String?
    let data: T?
}

// MARK: - Models
struct VerifyPhoneRequest: Codable {
    let phone: String
}

struct VerifyPhoneData: Codable {
    let phone: String
    let phoneStatus: String
    let timestamp: String
    let expiresIn: String
}

struct VerifyPhoneResponse: Codable {
    let status: String
    let message: String?
    let data: VerifyPhoneData?
    
    var success: Bool {
        return status == "success"
    }
}

struct VerifyOtpRequest: Codable {
    let phone: String
    let otp: String
}

struct UserInfo: Codable {
    let userId: String
    let name: String?
    let email: String?
    let phone: String?
    let firstname: String?
    let uploadedPhoto: String?
    let hasFaceRecord: Bool?
}

struct VerifyOtpDataPayload: Codable {
    let user: UserInfo
}

struct VerifyOtpResponse: Codable {
    let status: String
    let message: String?
    let token: String?
    let data: VerifyOtpDataPayload?
    
    var success: Bool {
        return status == "success"
    }
    
    var accessToken: String? {
        return token
    }
    
    var refreshToken: String? {
        return nil  // Backend doesn't return refreshToken
    }
    
    var tempUserId: String? {
        return data?.user.userId
    }
    
    var isNewUser: Bool {
        return false  // You can adjust this based on backend logic
    }
}

struct CompleteProfileRequest: Codable {
    let name: String
    let email: String
    let state: String
    
}

struct CompleteProfileResponse: Codable {
    let success: Bool
    let message: String?
    let userId: String?
}

struct UserProfileResponseWrapper: Codable {
    let status: String
    let message: String?
    let data: UserProfileData
}

struct UserProfileResponse: Codable {
    let success: Bool
    let data: UserData?
}

struct UserProfileData: Codable {
    let user: UserData?
    let aadhaarStatus: AadhaarStatus?
    let faceVerification: FaceVerification?
}

struct UserData: Codable {
    let userId: String?
    let name: String?
    let email: String?
    let phone: String?
    let state: String?
    let uploadedPhoto: String?
    let verificationStatus: String?
}

struct AadhaarStatus: Codable {
    let uploaded: Bool?
    let imageId: String?
    let status: String?
    let fullName: String?
    let uploadedAt: String?
}

struct FaceVerification: Codable {
    let verified: Bool?
    let faceId: String?
}

// MARK: - Network Result
enum NetworkResult<T> {
    case success(T)
    case failure(Error)
    case error(String)
}

// MARK: - API Service
class APIService {
    static let shared = APIService()
    private let baseURL = "https://backendmongo-tau.vercel.app/api"
    
    private func makeRequest<T: Codable>(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        print("🔵 API Request: \(method) \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("📤 Request Body: \(bodyString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Response Status: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response Body: \(responseString)")
        } else {
            print("📥 Response Body: (empty or binary data)")
        }
        
        if httpResponse.statusCode == 401 {
            SessionManager.shared.handleUnauthorized()
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ HTTP Error: \(httpResponse.statusCode)")
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        if data.isEmpty {
            print("⚠️ Empty response body")
            throw APIError.emptyResponse
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ Decoding Error: \(error.localizedDescription)")
            print("   Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            throw error
        }
    }
    
    // MARK: - Auth APIs
    func verifyPhone(phone: String) async throws -> VerifyPhoneResponse {
        let body = try JSONEncoder().encode(VerifyPhoneRequest(phone: phone))
        return try await makeRequest(endpoint: "auth/send-otp-new", method: "POST", body: body)
    }
    	
    func verifyOtp(phone: String, otp: String) async throws -> VerifyOtpResponse {
        let body = try JSONEncoder().encode(VerifyOtpRequest(phone: phone, otp: otp))
        return try await makeRequest(endpoint: "auth/verify-otp-new", method: "POST", body: body)
    }
    
    @discardableResult
    func completeProfile(name: String, email: String, state: String) async throws -> CompleteProfileResponse {
        let body = try JSONEncoder().encode(CompleteProfileRequest(name: name, email: email, state: state))
        return try await makeRequest(endpoint: "auth/complete-profile", method: "POST", body: body)
    }
    
    func getUserProfile() async throws -> UserProfileResponseWrapper {
        return try await makeRequest(endpoint: "auth/complete-profile")
    }
    
    func getUserProfileData() async throws -> UserProfileData {
        let response: UserProfileResponseWrapper = try await makeRequest(endpoint: "auth/complete-profile")
        return response.data
    }
    
    // MARK: - Event APIs
    func getEvents() async throws -> [Event] {
        let response: ApiEventResponse = try await makeRequest(endpoint: "events")
        return response.data.events
    }
    
    func getEventDetail(eventId: String) async throws -> Event {
        let response: ApiEventDetailResponse = try await makeRequest(endpoint: "events/\(eventId)")
        return response.data.event
    }
    
    func getTickets(eventId: String) async throws -> [TicketType] {
        let response: TicketListResponse = try await makeRequest(endpoint: "booking/\(eventId)/seats")
        return response.tickets
    }
    
    // MARK: - Booking APIs
    func getBookings() async throws -> [Booking] {
        guard let userId = TokenManager.shared.getUserId(), !userId.isEmpty else {
            print("❌ UserId not found or empty in TokenManager")
            throw APIError.userNotFound
        }
        let response: BookingListResponse = try await makeRequest(endpoint: "booking/user/\(userId)")
        return response.data.bookings
    }
    
    // MARK: - Community APIs
    func getCommunities() async throws -> [Community] {
        // Decode using the wrapper structure from backend
        struct CommunitiesResponse: Codable {
            let status: String
            let data: [Community]
        }
        
        let response: CommunitiesResponse = try await makeRequest(endpoint: "communities")
        return response.data
    }
    
    // MARK: - Payment APIs
    func createPaymentOrder(amount: Double, eventId: String, seatingId: String) async throws -> PaymentOrderData {
        let body = try JSONEncoder().encode(CreatePaymentOrderRequest(amount: amount, eventId: eventId, seatingId: seatingId))
        let response: PaymentOrderResponseWrapper = try await makeRequest(endpoint: "payments/create-order", method: "POST", body: body)
        return response.data
    }
    
    func getConvenienceFee(amount: Double) async throws -> ConvenienceFeeData {
        let response: ConvenienceFeeResponse = try await makeRequest(endpoint: "payments/convenience-fee?amount=\(amount)")
        return response.data
    }
    func verifyPayment(paymentId: String, signature: String, orderId: String) async throws -> VerifyPaymentResponse {
        let body = try JSONEncoder().encode(VerifyPaymentRequest(paymentId: paymentId, signature: signature, razorpayOrderId: orderId))
        return try await makeRequest(endpoint: "payments/fetch-razorpay-payment", method: "POST", body: body)
    }
    
    func initiateBooking(eventId: String, seatingId: String, numberOfTickets: Int) async throws -> InitiateBookingResponse {
        let body = try JSONEncoder().encode(InitiateBookingRequest(eventId: eventId, seatingId: seatingId, numberOfTickets: numberOfTickets))
        return try await makeRequest(endpoint: "booking-payment/initiate-with-verification", method: "POST", body: body)
    }
    
    func confirmBooking(bookingId: String, paymentId: String, isSmartEntry: Bool) async throws -> ConfirmBookingResponse {
        let body = try JSONEncoder().encode(ConfirmBookingRequest(bookingId: bookingId, paymentId: paymentId, isSmartEntry: isSmartEntry))
        return try await makeRequest(endpoint: "booking-payment/confirm-booking", method: "POST", body: body)
    }
    
    func verifyFaceStatus(faceId: String, userId: String) async throws -> VerifyFaceStatusResponse {
        let body = try JSONEncoder().encode(VerifyFaceStatusRequest(faceId: faceId, userId: userId))
        return try await makeRequest(endpoint: "booking-payment/verify-face-status", method: "POST", body: body)
    }

// Add these methods to your existing APIService class

// MARK: - Aadhaar Verification APIs
func uploadAadhaarImage(imageData: Data, fullName: String) async throws -> AadhaarUploadResponse {
    let boundary = UUID().uuidString
    var request = URLRequest(url: URL(string: "\(baseURL)/api/aadhaar/upload-image/")!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var body = Data()
    
    // Add image file
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"aadhaar.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n".data(using: .utf8)!)
    
    // Add fullName field
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"fullName\"\r\n\r\n".data(using: .utf8)!)
    body.append("\(fullName)\r\n".data(using: .utf8)!)
    
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    // Add auth token
    if let token = TokenManager.shared.getAccessToken() {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    let (data, response) = try await URLSession.shared.upload(for: request, from: body)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw APIError.uploadFailed
    }
    
    return try JSONDecoder().decode(AadhaarUploadResponse.self, from: data)
}

func uploadSelfieImage(imageData: Data, fullName: String) async throws -> SelfieUploadResponse {
    let boundary = UUID().uuidString
    var request = URLRequest(url: URL(string: "\(baseURL)/api/upload/")!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var body = Data()
    
    // Add image file
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"image\"; filename=\"selfie.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n".data(using: .utf8)!)
    
    // Add fullname field
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"fullname\"\r\n\r\n".data(using: .utf8)!)
    body.append("\(fullName)\r\n".data(using: .utf8)!)
    
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    // Add auth token
    if let token = TokenManager.shared.getAccessToken() {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    let (data, response) = try await URLSession.shared.upload(for: request, from: body)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw APIError.uploadFailed
    }
    
    return try JSONDecoder().decode(SelfieUploadResponse.self, from: data)
}

func verifyAadhaar(aadhaarNumber: String, consentGiven: Bool) async throws -> AadhaarVerifyResponse {
    struct VerifyAadhaarRequest: Codable {
        let aadhaarNumber: String
        let consentGiven: Bool
    }
    
    let body = try JSONEncoder().encode(VerifyAadhaarRequest(aadhaarNumber: aadhaarNumber, consentGiven: consentGiven))
    return try await makeRequest(endpoint: "api/aadhaar/verify", method: "POST", body: body)
}
}

// MARK: - APIError Enum
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case uploadFailed
    case invalidImageData
    case httpError(Int)
    case emptyResponse
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:        return "Invalid request URL."
        case .invalidResponse:   return "Invalid server response."
        case .unauthorized:      return "Session expired. Please log in again."
        case .uploadFailed:      return "File upload failed. Please try again."
        case .invalidImageData:  return "Could not process the selected image."
        case .httpError(let code): return "Server error (\(code)). Please try again."
        case .emptyResponse:     return "No data received from server."
        case .userNotFound:      return "User not found. Please log in again."
        }
    }
}

// MARK: - Response Models for Aadhaar
struct AadhaarUploadResponse: Codable {
    let success: Bool
    let message: String?
    let data: AadhaarUploadData?
}

struct AadhaarUploadData: Codable {
    let documentId: String?
    let status: String?
}

struct SelfieUploadResponse: Codable {
    let success: Bool
    let message: String?
    let faceVerified: Bool?
    let faceId: String?
}

struct AadhaarVerifyResponse: Codable {
    let success: Bool
    let message: String?
    let verificationId: String?
}

// MARK: - Response Models
struct EventListResponse: Codable {
    let events: [Event]
}

struct ApiEventResponse: Codable {
    let status: String
    let results: Int
    let data: EventListResponse
}

struct EventDetailData: Codable {
    let event: Event
}

struct ApiEventDetailResponse: Codable {
    let status: String
    let data: EventDetailData
}

struct TicketListResponse: Codable {
    let status: String
    let data: TicketListData
    
    var tickets: [TicketType] {
        return data.seatings
    }
}

struct TicketListData: Codable {
    let eventId: String
    let eventName: String
    let seatings: [TicketType]
}

struct BookingListResponseData: Codable {
    let bookings: [Booking]
}

struct BookingListResponse: Codable {
    let status: String
    let data: BookingListResponseData
}

struct PaymentOrderResponseWrapper: Codable {
    let status: String
    let message: String?
    let data: PaymentOrderData
}

struct PaymentOrderData: Codable {
    let success: Bool
    let orderId: String
    let razorpayOrderId: String
    let amount: Int
    let amountInRupees: Double
    let currency: String
    let key: String
    let payment: PaymentInfo?
}

struct PaymentInfo: Codable {
    let userId: String?
    let orderId: String?
    let razorpayOrderId: String?
    let amount: Double?
    let currency: String?
    let status: String?
    let receipt: String?
    let customer: CustomerInfo?
    let metadata: MetadataInfo?
}

struct CustomerInfo: Codable {
    let email: String?
    let phone: String?
    let name: String?
}

struct MetadataInfo: Codable {
    let razorpayOrder: RazorpayOrderInfo?
}

struct RazorpayOrderInfo: Codable {
    let amount: Int?
    let currency: String?
    let status: String?
    let id: String?
    let receipt: String?
}

struct CreatePaymentOrderRequest: Codable {
    let amount: Double
    let eventId: String
    let seatingId: String
}

struct ConfirmBookingRequest: Codable {
    let bookingId: String
    let paymentId: String
    let isSmartEntry: Bool
}

struct ConfirmBookingResponse: Codable {
    let success: Bool
    let bookingId: String
    let message: String?
}

struct VerifyPaymentRequest: Codable {
    let paymentId: String
    let signature: String
    let razorpayOrderId: String
    
    enum CodingKeys: String, CodingKey {
        case paymentId
        case signature
        case razorpayOrderId
    }
}

struct VerifyPaymentResponse: Codable {
    let status: String
    let message: String?
    let razorpayOrderId: String?
    let razorpayPaymentId: String?
    let paymentId: String?
    let amount: Double?
    let currency: String?
    let createdAt: String?
    let razorpayStatus: String?
    
    var isSuccess: Bool {
        return razorpayStatus == "captured" || status == "paid"
    }
}

struct InitiateBookingRequest: Codable {
    let eventId: String
    let seatingId: String
    let numberOfTickets: Int
}

struct InitiateBookingResponse: Codable {
    let status: String
    let message: String?
    let data: InitiateBookingData?
}

struct InitiateBookingData: Codable {
    let bookingId: String
    let orderId: String
    let amount: Double
}

struct VerifyFaceStatusRequest: Codable {
    let faceId: String
    let userId: String
}

struct VerifyFaceStatusResponse: Codable {
    let status: String
    let message: String?
    let data: FaceStatusData?
}

struct FaceStatusData: Codable {
    let verified: Bool
    let faceId: String
    let message: String?
}
