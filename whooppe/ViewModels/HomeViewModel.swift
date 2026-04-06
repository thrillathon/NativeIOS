//
//  HomeViewModel.swift
//  whooppe
//
//  Created by Mr MAD on 4/4/26.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var communities: [Community] = []
    @Published var adData: [AdData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadHomeData() async {
        await MainActor.run { isLoading = true }
        
        print("📥 Loading Home Data...")
        
        // Load events
        do {
            let events = try await apiService.getEvents()
            print("✅ Events loaded: \(events.count) events")
            await MainActor.run {
                self.events = events
            }
        } catch {
            print("⚠️ Failed to load events: \(error.localizedDescription)")
            // Use mock data for development
            print("📦 Using mock event data for testing...")
            await MainActor.run {
                self.events = Self.createMockEvents()
            }
        }
        
        // Load communities
        do {
            let communities = try await apiService.getCommunities()
            print("✅ Communities loaded: \(communities.count) communities")
            await MainActor.run {
                self.communities = communities
            }
        } catch {
            print("⚠️ Failed to load communities: \(error.localizedDescription)")
            // Use mock data for development
            print("📦 Using mock community data for testing...")
            await MainActor.run {
                self.communities = Self.createMockCommunities()
            }
        }
        
        // Load ads (optional)
        do {
            await MainActor.run {
                self.adData = Self.createMockAds()
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Mock Data for Development
    private static func createMockEvents() -> [Event] {
        return [
            Event(
                id: "1",
                name: "Arijit Singh Live",
                description: "Experience the magic of Arijit Singh live",
                date: "15 Apr 2026",
                time: "7:30 PM",
                venue: "Indira Gandhi Indoor Stadium",
                city: "New Delhi",
                state: "Delhi",
                locationLink: "https://maps.google.com",
                language: "Hindi",
                category: "Music",
                ageLimit: "16+",
                coverImage: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=500",
                ticketPrice: 500,
                basePrice: 500,
                status: "live",
                adImageUrls: [],
                isFavorite: false
            ),
            Event(
                id: "2",
                name: "Comedy Night with AIB",
                description: "Laugh out loud with AIB comedy team",
                date: "20 Apr 2026",
                time: "8:00 PM",
                venue: "NSCI, Mumbai",
                city: "Mumbai",
                state: "Maharashtra",
                locationLink: "https://maps.google.com",
                language: "English",
                category: "Comedy",
                ageLimit: "18+",
                coverImage: "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=500",
                ticketPrice: 300,
                basePrice: 300,
                status: "live",
                adImageUrls: [],
                isFavorite: false
            ),
            Event(
                id: "3",
                name: "Electronic Music Festival",
                description: "A night of electronic beats and dance",
                date: "25 Apr 2026",
                time: "9:00 PM",
                venue: "Connaught Place",
                city: "New Delhi",
                state: "Delhi",
                locationLink: "https://maps.google.com",
                language: "English",
                category: "Music",
                ageLimit: "21+",
                coverImage: "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500",
                ticketPrice: 800,
                basePrice: 800,
                status: "live",
                adImageUrls: [],
                isFavorite: false
            ),
            Event(
                id: "4",
                name: "Backstreet Boys Concert",
                description: "The legendary boy band returns",
                date: "10 Apr 2026",
                time: "6:00 PM",
                venue: "Jawaharlal Nehru Stadium",
                city: "New Delhi",
                state: "Delhi",
                locationLink: "https://maps.google.com",
                language: "English",
                category: "Music",
                ageLimit: "All",
                coverImage: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500",
                ticketPrice: 1200,
                basePrice: 1200,
                status: "live",
                adImageUrls: [],
                isFavorite: false
            ),
            Event(
                id: "5",
                name: "Stand-up Comedy - Giri Wazir",
                description: "Hilarious comedy show by Giri Wazir",
                date: "18 Apr 2026",
                time: "7:00 PM",
                venue: "Auditorium, Bangalore",
                city: "Bangalore",
                state: "Karnataka",
                locationLink: "https://maps.google.com",
                language: "English",
                category: "Comedy",
                ageLimit: "16+",
                coverImage: "https://images.unsplash.com/photo-1514888286974-6c03bf1a6b4d?w=500",
                ticketPrice: 400,
                basePrice: 400,
                status: "live",
                adImageUrls: [],
                isFavorite: false
            ),
            Event(
                id: "6",
                name: "Jazz Night with Tabla",
                description: "Fusion of jazz and Indian classical",
                date: "22 Apr 2026",
                time: "8:30 PM",
                venue: "India Habitat Centre",
                city: "New Delhi",
                state: "Delhi",
                locationLink: "https://maps.google.com",
                language: "Hindi",
                category: "Music",
                ageLimit: "All",
                coverImage: "https://images.unsplash.com/photo-1511379938547-c1f69b13d835?w=500",
                ticketPrice: 600,
                basePrice: 600,
                status: "live",
                adImageUrls: [],
                isFavorite: false
            ),
            Event(
                id: "7",
                name: "Tech Talk & Innovation Summit",
                description: "Explore the future of technology",
                date: "28 Apr 2026",
                time: "10:00 AM",
                venue: "Taj Hotel, Delhi",
                city: "New Delhi",
                state: "Delhi",
                locationLink: "https://maps.google.com",
                language: "English",
                category: "Conference",
                ageLimit: "16+",
                coverImage: "https://images.unsplash.com/photo-1552664730-d307ca884978?w=500",
                ticketPrice: 200,
                basePrice: 200,
                status: "live",
                adImageUrls: [],
                isFavorite: false
            ),
            Event(
                id: "8",
                name: "Bollywood Dance Workshop",
                description: "Learn Bollywood moves with professionals",
                date: "12 Apr 2026",
                time: "5:00 PM",
                venue: "Dance Studio, Gurgaon",
                city: "Gurgaon",
                state: "Haryana",
                locationLink: "https://maps.google.com",
                language: "Hindi",
                category: "Workshop",
                ageLimit: "12+",
                coverImage: "https://images.unsplash.com/photo-1504492783494-fd484e13b779?w=500",
                ticketPrice: 350,
                basePrice: 350,
                status: "live",
                adImageUrls: [],
                isFavorite: false
            )
        ]
    }
    
    private static func createMockAds() -> [AdData] {
        return [
            AdData(
                id: "ad1",
                imageUrl: "https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=500",
                title: "Special Offer",
                description: "Get up to 50% off on selected events",
                actionUrl: "",
                displayType: "banner",
                platform: "iOS"
            ),
            AdData(
                id: "ad2",
                imageUrl: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=500",
                title: "Exclusive Deals",
                description: "Early bird offers on upcoming events",
                actionUrl: "",
                displayType: "banner",
                platform: "iOS"
            )
        ]
    }
    
    private static func createMockCommunities() -> [Community] {
        return [
            Community(
                id: "comm1",
                name: "Tech Innovators",
                ownerName: "Sarah Johnson",
                ownerId: "user1",
                coverImage: "https://images.unsplash.com/photo-1552664730-d307ca884978?w=500",
                description: "A community for tech enthusiasts and innovators",
                memberCount: 1234,
                eventIds: ["1", "3"]
            ),
            Community(
                id: "comm2",
                name: "Art Collective",
                ownerName: "Michael Chen",
                ownerId: "user2",
                coverImage: "https://images.unsplash.com/photo-1561070791-2526d30994b5?w=500",
                description: "Bringing artists together",
                memberCount: 856,
                eventIds: ["2"]
            ),
            Community(
                id: "comm3",
                name: "Fitness Warriors",
                ownerName: "Emily Rodriguez",
                ownerId: "user3",
                coverImage: "https://images.unsplash.com/photo-1517836357463-d25ddfcbf042?w=500",
                description: "Stay fit, stay healthy",
                memberCount: 2100,
                eventIds: ["4", "5"]
            ),
            Community(
                id: "comm4",
                name: "Music Makers",
                ownerName: "Lisa Thompson",
                ownerId: "user5",
                coverImage: "https://images.unsplash.com/photo-1511379938547-c1f69b13d835?w=500",
                description: "Create and share music",
                memberCount: 945,
                eventIds: ["6"]
            ),
            Community(
                id: "comm5",
                name: "Book Club",
                ownerName: "James Wilson",
                ownerId: "user6",
                coverImage: "https://images.unsplash.com/photo-150784272343-583f20270319?w=500",
                description: "Reading and discussing books",
                memberCount: 567,
                eventIds: ["7"]
            ),
            Community(
                id: "comm6",
                name: "Food Lovers",
                ownerName: "David Kim",
                ownerId: "user4",
                coverImage: "https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=500",
                description: "Exploring culinary delights",
                memberCount: 1876,
                eventIds: ["8"]
            )
        ]
    }
}