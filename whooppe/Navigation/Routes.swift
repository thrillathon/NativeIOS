import Foundation
import SwiftUI

struct Routes {
    // Auth
    static let onboarding = "onboarding"
    static let register = "register"
    static let userInfo = "userInfo"
    
    // Main
    static let home = "home"
    static let events = "events"
    static let eventDetail = "eventDetail"
    static let ticketSelection = "ticketSelection"
    static let payment = "payment"
    
    // Profile
    static let profile = "profile"
    static let yourTickets = "yourTickets"
    static let aadhaarVerification = "aadhaarVerification"
    static let editProfile = "editProfile"
    
    // Other
    static let ipl = "ipl"
    static let contactRangmunch = "contactRangmunch"
    static let termsAndConditions = "termsAndConditions"
    static let privacyPolicy = "privacyPolicy"
    static let notifications = "notifications"
    
    // Helper functions
    static func createEventDetailRoute(eventId: String) -> String {
        return "\(eventDetail)/\(eventId)"
    }
    
    static func createTicketSelectionRoute(eventId: String, eventName: String, venue: String, date: String, time: String, language: String, locationLink: String) -> String {
        return "\(ticketSelection)/\(eventId)?eventName=\(eventName)&venue=\(venue)&date=\(date)&time=\(time)&language=\(language)&locationLink=\(locationLink)"
    }
    
    static func createPaymentRoute(eventId: String, eventName: String, venue: String, date: String, time: String, seatingId: String, ticketPrice: Int, ticketName: String, language: String, locationLink: String) -> String {
        return "\(payment)/\(eventId)?eventName=\(eventName)&venue=\(venue)&date=\(date)&time=\(time)&seatingId=\(seatingId)&ticketPrice=\(ticketPrice)&ticketName=\(ticketName)&language=\(language)&locationLink=\(locationLink)"
    }
}

// MARK: - View Extension for Navigation
extension View {
    func navigationDestination<D: Hashable, Content: View>(
        item: Binding<D?>,
        @ViewBuilder destination: @escaping (D) -> Content
    ) -> some View {
        self.navigationDestination(isPresented: Binding(
            get: { item.wrappedValue != nil },
            set: { if !$0 { item.wrappedValue = nil } }
        )) {
            if let value = item.wrappedValue {
                destination(value)
            }
        }
    }
}