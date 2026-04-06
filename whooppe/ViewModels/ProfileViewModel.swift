import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var userPhone = ""
    @Published var userState = ""
    @Published var userTickets: [Booking] = []
    @Published var logoutSuccess = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService()
    private var isFetching = false
    
    func refreshUserData() {
        if isFetching {
            print("⏳ Request already in progress, skipping duplicate call")
            return
        }
        Task {
            await fetchUserProfile()
            await fetchUserTickets()
        }
    }
    
    @MainActor
    private func fetchUserProfile() async {
        do {
            let profileData = try await apiService.getUserProfileData()
            self.userName  = profileData.user?.name  ?? ""
            self.userEmail = profileData.user?.email ?? ""
            self.userPhone = profileData.user?.phone ?? ""
            self.userState = profileData.user?.state ?? ""
            print("✅ Profile loaded: \(self.userName)")
        } catch {
            print("❌ Error fetching profile: \(error)")
        }
    }

    @MainActor
    private func fetchUserTickets() async {
        guard !isFetching else {
            print("⏳ Request already in progress, skipping")
            return
        }
        
        isFetching = true
        isLoading = true
        errorMessage = nil
        print("🔄 Starting to fetch user tickets...")
        
        do {
            let bookings = try await apiService.getBookings()
            self.userTickets = bookings
            print("✅ Successfully fetched \(bookings.count) bookings")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Error fetching bookings: \(error)")
        }
        
        isLoading = false
        isFetching = false
    }
    
    func logout() {
        TokenManager.shared.clearAll()
        logoutSuccess = true
    }
    
    func resetLogoutState() {
        logoutSuccess = false
    }
}
