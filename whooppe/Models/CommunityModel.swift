import SwiftUI
import Combine

// MARK: - Community Model
struct Community: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let ownerName: String
    let ownerId: String
    let coverImage: String
    let description: String
    let memberCount: Int
    let eventIds: [String]
    let createdAt: Date
    let facebookLink: String?
    let instagramLink: String?
    let telegramLink: String?
    let whatsappLink: String?

    init(id: String = UUID().uuidString,
         name: String,
         ownerName: String,
         ownerId: String,
         coverImage: String,
         description: String,
         memberCount: Int = 0,
         eventIds: [String] = [],
         facebookLink: String? = nil,
         instagramLink: String? = nil,
         telegramLink: String? = nil,
         whatsappLink: String? = nil) {
        self.id = id
        self.name = name
        self.ownerName = ownerName
        self.ownerId = ownerId
        self.coverImage = coverImage
        self.description = description
        self.memberCount = memberCount
        self.eventIds = eventIds
        self.createdAt = Date()
        self.facebookLink = facebookLink
        self.instagramLink = instagramLink
        self.telegramLink = telegramLink
        self.whatsappLink = whatsappLink
    }
}

// MARK: - Community ViewModel
class CommunityViewModel: ObservableObject {
    @Published var communities: [Community] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadCommunities() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Sample data
        let sampleCommunities = [
            Community(
                name: "Tech Innovators",
                ownerName: "Sarah Johnson",
                ownerId: "user1",
                coverImage: "https://picsum.photos/id/1/400/600",
                description: "A community for tech enthusiasts and innovators",
                facebookLink: "https://facebook.com/techinnovators",
                instagramLink: "https://instagram.com/techinnovators",
                telegramLink: "https://t.me/techinnovators",
                whatsappLink: "https://wa.me/919999999901"
            ),
            Community(
                name: "Art Collective",
                ownerName: "Michael Chen",
                ownerId: "user2",
                coverImage: "https://picsum.photos/id/2/400/600",
                description: "Bringing artists together",
                instagramLink: "https://instagram.com/artcollective",
                telegramLink: "https://t.me/artcollective"
            ),
            Community(
                name: "Fitness Warriors",
                ownerName: "Emily Rodriguez",
                ownerId: "user3",
                coverImage: "https://picsum.photos/id/3/400/600",
                description: "Stay fit, stay healthy",
                telegramLink: "https://t.me/fitnesswarriors",
                whatsappLink: "https://wa.me/919999999903",
            ),
            Community(
                name: "Food Lovers",
                ownerName: "David Kim",
                ownerId: "user4",
                coverImage: "https://picsum.photos/id/4/400/600",
                description: "Exploring culinary delights",
                facebookLink: "https://facebook.com/foodlovers",
                instagramLink: "https://instagram.com/foodlovers"
            ),
            Community(
                name: "Music Makers",
                ownerName: "Lisa Thompson",
                ownerId: "user5",
                coverImage: "https://picsum.photos/id/5/400/600",
                description: "Create and share music",
                instagramLink: "https://instagram.com/musicmakers",
                whatsappLink: "https://wa.me/919999999905"
            ),
            Community(
                name: "Book Club",
                ownerName: "James Wilson",
                ownerId: "user6",
                coverImage: "https://picsum.photos/id/6/400/600",
                description: "Reading and discussing books",
                facebookLink: "https://facebook.com/bookclub",
                telegramLink: "https://t.me/bookclub"
            )
        ]
        
        DispatchQueue.main.async {
            self.communities = sampleCommunities
            self.isLoading = false
        }
    }
}
