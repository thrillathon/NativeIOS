import SwiftUI
import Combine

// MARK: - Community Event Details Screen (with 2-column grid)
struct CommunityEventDetailsScreen: View {
    let community: Community
    @StateObject private var eventViewModel = HomeViewModel()
    @State private var selectedEvent: Event?
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F5F0").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Community header 
                VStack(spacing: 8) {
                    
                    VStack(spacing: 4) {
                        Text(community.name)
                            .font(.system(size: 20, weight: .bold))
                        
                        HStack {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#D4B547"))
                            Text("Organized by \(community.ownerName)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Text(community.description)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                        
                        HStack(spacing: 16) {
                            Label("\(community.memberCount) members", systemImage: "person.2.fill")
                            Label("\(community.eventIds.count) events", systemImage: "calendar")
                        }
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#D4B547"))
                        .padding(.top, 4)

                        // Social links — only shown when link exists
                        let socialLinks: [(url: String?, icon: String, color: Color)] = [
                            (community.facebookLink,  "f.circle.fill",       Color(hex: "#1877F2")),
                            (community.instagramLink, "camera.circle.fill",  Color(hex: "#E1306C")),
                            (community.telegramLink,  "paperplane.circle.fill", Color(hex: "#2AABEE")),
                            (community.whatsappLink,  "message.circle.fill", Color(hex: "#25D366")),
                        ]
                        let activeSocial = socialLinks.filter { $0.url?.isEmpty == false }
                        if !activeSocial.isEmpty {
                            VStack(spacing: 8) {
                                Text("Tap a link below to join the community")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)

                                HStack(spacing: 20) {
                                    ForEach(Array(activeSocial.enumerated()), id: \.offset) { _, item in
                                        if let urlString = item.url, let url = URL(string: urlString) {
                                            Link(destination: url) {
                                                Image(systemName: item.icon)
                                                    .font(.system(size: 28))
                                                    .foregroundColor(item.color)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 6)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(0)
                .padding(.top, 12)
                
                // Events Grid (2 columns)
                if eventViewModel.isLoading && eventViewModel.events.isEmpty {
                    Spacer()
                    ProgressView()
                        .tint(Color(hex: "#D4B547"))
                    Spacer()
                } else if eventViewModel.events.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No events organized by this community yet")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(eventViewModel.events) { event in
                                CommunityEventGridCard(event: event) {
                                    selectedEvent = event
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationDestination(item: $selectedEvent) { event in
                EventDetailScreen(eventId: event.id)
            }
        }
         .navigationTitle("Events by \(community.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#D4B547"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                // Remove the default back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)                          
                    }
                }
            }
            .navigationBarBackButtonHidden(true) // Add this to hide default back button
            

        .task {
            await eventViewModel.loadHomeData()
        }
    }
}

// MARK: - Community Event Card
// MARK: - Community Event Grid Card (2-column version)
struct CommunityEventGridCard: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Event image
                AsyncImage(url: URL(string: event.coverImage)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .tint(Color(hex: "#D4B547"))
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(height: 180)
                .clipped()
                
                // Event details
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(event.date)
                            .font(.system(size: 11))
                        }
                    .foregroundColor(.gray)    
                        
                     HStack(spacing: 6) {    
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(event.time)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(event.venue)
                            .font(.system(size: 11))
                            .lineLimit(1)
                    }
                    .foregroundColor(.gray)
                    
                    // Bookmark/Price indicator
                    HStack {
                        if let price = event.ticketPrice, price > 0 {
                            Text("₹\(Int(price))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "#D4B547"))
                        } else {
                            Text("FREE")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#D4B547"))
                    }
                    .padding(.top, 4)
                }
                .padding(12)
                .background(Color.white)
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
