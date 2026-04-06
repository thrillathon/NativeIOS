import Foundation
import Combine

struct LoginRequest: Codable {
    let phone: String
}

// VerifyOtpRequest, VerifyOtpResponse defined in APIService.swift

struct UserProfile: Codable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let state: String
    let isFaceVerified: Bool
}
