import Foundation
import SwiftUI

struct Booking: Identifiable, Codable {
    let id: String
    let userId: String
    let eventId: Event
    let ticketNumbers: String?
    let seatType: String?
    let status: String
    let bookedAt: String
    let qrCodes: String?
    let coverImage: String?
    let locationlink: String?
    let quantity: Int?
    let pricePerSeat: Double?
    let totalPrice: Double?
    let paymentId: String?
    let paymentStatus: String?
    let checkInCount: Int?
    let checkedIn: Bool?
    let tickettype: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case eventId
        case ticketNumbers
        case seatType
        case status
        case bookedAt
        case qrCodes
        case coverImage
        case locationlink
        case quantity
        case pricePerSeat
        case totalPrice
        case paymentId
        case paymentStatus
        case checkInCount
        case checkedIn
        case tickettype
    }
    
    var ticketStatus: TicketStatus {
        switch status {
        case "confirmed": return .confirmed
        case "cancelled": return .cancelled
        case "pending": return .verificationPending
        case "queued": return .queued
        case "fully_booked": return .fullyBooked
        case "used": return .confirmed
        default: return .verificationPending
        }
    }
}

enum TicketStatus {
    case verificationPending
    case queued
    case fullyBooked
    case confirmed
    case cancelled
    
    var displayText: String {
        switch self {
        case .verificationPending: return "Verification Pending"
        case .queued: return "Queued for a seat"
        case .fullyBooked: return "Fully Booked"
        case .confirmed: return "Ticket Confirmed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: Color {
        switch self {
        case .verificationPending, .queued, .confirmed: return Color(hex: "#2196F3")
        case .fullyBooked, .cancelled: return Color(hex: "#F44336")
        }
    }
}
