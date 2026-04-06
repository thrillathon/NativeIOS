import SwiftUI

struct SetupNavGraph: View {
    let startDestination: String
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if startDestination == Routes.home {
                    HomeScreen()
                        .navigationDestination(for: String.self) { destination in
                            handleDestination(destination)
                        }
                } else {
                    OnboardingScreen()
                        .navigationDestination(for: String.self) { destination in
                            handleDestination(destination)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    func handleDestination(_ destination: String) -> some View {
        if destination == Routes.home {
            HomeScreen()
        } else if destination == Routes.events {
            EventsScreen()
        } else if destination == Routes.profile {
            ProfileScreen()
        } else if destination == Routes.ipl {
            IPLScreen()
        } else if destination == Routes.aadhaarVerification {
            AadhaarVerificationScreen()
        } else if destination == Routes.yourTickets {
            YourTicketsScreen()
        } else if destination == Routes.termsAndConditions {
            TermsScreen()
        } else if destination == Routes.privacyPolicy {
            PrivacyPolicyScreen()
        } else if destination == Routes.contactRangmunch {
            ContactRangmunchScreen()
        } else if destination == Routes.notifications {
            NotificationsScreen()
        } else if destination.hasPrefix(Routes.eventDetail) {
            let eventId = destination.replacingOccurrences(of: "\(Routes.eventDetail)/", with: "")
            EventDetailScreen(eventId: eventId)
        } else if destination.hasPrefix(Routes.ticketSelection) {
            let params = parseTicketSelectionParams(from: destination)
            TicketSelectionScreen(
                eventId: params.eventId,
                eventName: params.eventName,
                venue: params.venue,
                date: params.date,
                time: params.time,
                language: params.language,
                locationLink: params.locationLink
            )
        } else if destination.hasPrefix(Routes.payment) {
            let params = parsePaymentParams(from: destination)
            PaymentScreen(
                eventId: params.eventId,
                seatingId: params.seatingId,
                ticketPrice: params.ticketPrice,
                eventName: params.eventName,
                venue: params.venue,
                date: params.date,
                time: params.time,
                language: params.language,
                locationLink: params.locationLink
            )
        }
    }
    
    private func parseTicketSelectionParams(from destination: String) -> (eventId: String, eventName: String, venue: String, date: String, time: String, language: String, locationLink: String) {
        let components = destination.replacingOccurrences(of: "\(Routes.ticketSelection)/", with: "").split(separator: "?", maxSplits: 1).map(String.init)
        let eventId = components[0]
        
        var eventName = ""
        var venue = ""
        var date = ""
        var time = ""
        var language = ""
        var locationLink = ""
        
        if components.count > 1 {
            let queryString = components[1]
            let queryParams = queryString.split(separator: "&").map(String.init)
            for param in queryParams {
                let keyValue = param.split(separator: "=", maxSplits: 1).map(String.init)
                if keyValue.count == 2 {
                    switch keyValue[0] {
                    case "eventName":
                        eventName = keyValue[1].removingPercentEncoding ?? ""
                    case "venue":
                        venue = keyValue[1].removingPercentEncoding ?? ""
                    case "date":
                        date = keyValue[1].removingPercentEncoding ?? ""
                    case "time":
                        time = keyValue[1].removingPercentEncoding ?? ""
                    case "language":
                        language = keyValue[1].removingPercentEncoding ?? ""
                    case "locationLink":
                        locationLink = keyValue[1].removingPercentEncoding ?? ""
                    default:
                        break
                    }
                }
            }
        }
        
        return (eventId, eventName, venue, date, time, language, locationLink)
    }
    
    private func parsePaymentParams(from destination: String) -> (eventId: String, eventName: String, venue: String, date: String, time: String, seatingId: String, ticketPrice: Double, ticketName: String, language: String, locationLink: String) {
        let components = destination.replacingOccurrences(of: "\(Routes.payment)/", with: "").split(separator: "?", maxSplits: 1).map(String.init)
        let eventId = components[0]
        
        var eventName = ""
        var venue = ""
        var date = ""
        var time = ""
        var seatingId = ""
        var ticketPrice: Double = 0
        var ticketName = ""
        var language = ""
        var locationLink = ""
        
        if components.count > 1 {
            let queryString = components[1]
            let queryParams = queryString.split(separator: "&").map(String.init)
            for param in queryParams {
                let keyValue = param.split(separator: "=", maxSplits: 1).map(String.init)
                if keyValue.count == 2 {
                    switch keyValue[0] {
                    case "eventName":
                        eventName = keyValue[1].removingPercentEncoding ?? ""
                    case "venue":
                        venue = keyValue[1].removingPercentEncoding ?? ""
                    case "date":
                        date = keyValue[1].removingPercentEncoding ?? ""
                    case "time":
                        time = keyValue[1].removingPercentEncoding ?? ""
                    case "seatingId":
                        seatingId = keyValue[1]
                    case "ticketPrice":
                        ticketPrice = Double(keyValue[1]) ?? 0
                    case "ticketName":
                        ticketName = keyValue[1].removingPercentEncoding ?? ""
                    case "language":
                        language = keyValue[1].removingPercentEncoding ?? ""
                    case "locationLink":
                        locationLink = keyValue[1].removingPercentEncoding ?? ""
                    default:
                        break
                    }
                }
            }
        }
        
        return (eventId, eventName, venue, date, time, seatingId, ticketPrice, ticketName, language, locationLink)
    }
}
