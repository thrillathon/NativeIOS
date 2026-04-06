import SwiftUI
import Combine

// MARK: - Communities Screen
struct CommunitiesScreen: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var searchQuery = ""
    @State private var selectedCommunity: Community?
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredCommunities: [Community] {
        if searchQuery.isEmpty {
            return viewModel.communities
        } else {
            return viewModel.communities.filter { community in
                community.name.localizedCaseInsensitiveContains(searchQuery) ||
                community.ownerName.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5F0").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Bar
                    CommonTopBar(title: "Communities")
                    
                    // Search Bar
                    VStack(spacing: 0) {
                        Divider()
                            .padding(.horizontal, 16)
                        
                        AppSearchBar(text: $searchQuery, placeholder: "Search communities...")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                        
                        Divider()
                            .padding(.horizontal, 16)
                    }
                    .background(Color.white)
                    
                    // Communities Grid
                    if viewModel.isLoading && viewModel.communities.isEmpty {
                        Spacer()
                        ProgressView()
                            .tint(Color(hex: "#D4B547"))
                        Spacer()
                    } else if filteredCommunities.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text(searchQuery.isEmpty ? "No communities available" : "No communities found")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(filteredCommunities) { community in
                                    CommunityCard(community: community) {
                                        selectedCommunity = community
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedCommunity) { community in
                CommunityEventDetailsScreen(community: community)
            }
        }
        .task {
            await viewModel.loadCommunities()
        }
    }
}

// MARK: - Community Card
struct CommunityCard: View {
    let community: Community
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // 9:16 Aspect Ratio Image
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: community.coverImage)) { phase in
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
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                    }
                    .frame(width: (UIScreen.main.bounds.width - 52) / 2)
                    .aspectRatio(9/16, contentMode: .fit)
                    .clipped()
                    
                    // Gradient overlay for better text visibility
                    LinearGradient(
                        colors: [Color.black.opacity(0.6), Color.clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 80)
                    
                    // Community info overlay
                    VStack(alignment: .leading, spacing: 4) {
                        Text(community.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 12))
                            Text(community.ownerName)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(12)
                }
                
                // Bottom info section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#D4B547"))
                        Text("\(community.memberCount) members")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Text(community.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
            }
            .frame(width: (UIScreen.main.bounds.width - 58) / 2)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}