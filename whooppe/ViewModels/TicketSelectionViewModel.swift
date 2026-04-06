import Foundation
import Combine

class TicketSelectionViewModel: ObservableObject {
    @Published var eventId = ""
    @Published var eventName = ""
    @Published var venue = ""
    @Published var date = ""
    @Published var time = ""
    @Published var language = ""
    @Published var locationLink = ""
    @Published var tickets: [TicketType] = []
    @Published var selectedTicket: TicketType?
    @Published var isLoading = false
    @Published var isCheckingProfile = false
    @Published var errorMessage: String?
    @Published var adImageUrls: [String] = []
    @Published var navigationEvent: TicketNavigationEvent?
    
    private let apiService = APIService.shared
    
    func loadTickets(eventId: String) async {
        await MainActor.run { isLoading = true }
        
        do {
            let tickets = try await apiService.getTickets(eventId: eventId)
            await MainActor.run {
                self.tickets = tickets
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func selectTicket(_ ticket: TicketType) {
        selectedTicket = ticket
    }
    
    func checkProfileAndProceed() {
        isCheckingProfile = true
        // Check if profile is complete
        isCheckingProfile = false
        navigationEvent = .navigateToPayment
    }
    
    func retryLoadSeats() {
        Task { await loadTickets(eventId: eventId) }
    }
}

enum TicketNavigationEvent {
    case navigateToPayment
    case navigateToCompleteProfile
}
