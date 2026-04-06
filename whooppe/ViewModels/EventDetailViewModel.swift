import Foundation
import Combine

class EventDetailViewModel: ObservableObject {
    init() {}
    
    // var objectWillChange: ObservableObjectPublisher
    
    @Published var event: Event?
    @Published var eventName = ""
    @Published var eventDescription = ""
    @Published var eventDate = ""
    @Published var eventTime = ""
    @Published var eventVenue = ""
    @Published var eventLanguage = ""
    @Published var eventAgeLimit = ""
    @Published var eventImageUrl = ""
    @Published var eventStatus = ""
    @Published var ticketPrice: Double = 0
    @Published var locationLink = ""
    @Published var adImageUrls: [String] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var eventId = ""
    
    private let apiService = APIService.shared
    
    func loadEvent(eventId: String) async {
        await MainActor.run { isLoading = true }
        
        do {
            let event = try await apiService.getEventDetail(eventId: eventId)
            await MainActor.run {
                self.event = event
                self.eventId = event.id
                self.eventName = event.name
                self.eventDescription = event.description ?? ""
                self.eventDate = event.date
                self.eventTime = event.time
                self.eventVenue = event.venue
                self.eventLanguage = event.language ?? ""
                self.eventAgeLimit = event.ageLimit ?? ""
                self.eventImageUrl = event.coverImage
                self.eventStatus = event.status ?? ""
                self.ticketPrice = event.ticketPrice ?? 0
                self.locationLink = event.locationLink
                self.adImageUrls = event.adImageUrls ?? []
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func retryLoadEvent() {
        Task { await loadEvent(eventId: eventId) }
    }
}
