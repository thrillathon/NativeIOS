import SwiftUI
import Combine

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var tokenManager: TokenManager
    @State private var selectedTab = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var isBarVisible = true
    @State private var lastScrollOffset: CGFloat = 0
    @State private var searchQuery = ""
    @State private var selectedEventId: String? = nil
    @State private var navigateToEventDetail = false
    @State private var selectedCommunity: Community? = nil
    @State private var navigateToCommunityDetail = false
    @State private var navigateToIPL = false
    
    var currentRoute: String {
        switch selectedTab {
        case 0: return "home"
        case 1: return "events"
        case 2: return "aadhaar_verification"
        case 3: return "communities"
        case 4: return "profile"
        default: return "home"
        }
    }
    
    var filteredEvents: [Event] {
        if searchQuery.isEmpty {
            return viewModel.events
        }
        return viewModel.events.filter { event in
            event.name.localizedCaseInsensitiveContains(searchQuery) ||
            event.venue.localizedCaseInsensitiveContains(searchQuery) ||
            (event.category ?? "").localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    var filteredCommunities: [Community] {
        if searchQuery.isEmpty {
            return viewModel.communities
        }
        return viewModel.communities.filter { community in
            community.name.localizedCaseInsensitiveContains(searchQuery) ||
            community.ownerName.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header Bar (only for home tab)
                if selectedTab == 0 {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Whooppe")
                                .font(.custom("Spectral", size: 22))
                                .foregroundColor(Color(hex: "#FF6B35"))
                            
                            Spacer()
                            
                            Button(action: {
                                selectedTab = 4  // Navigate to Notifications
                            }) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 56)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        // Search Bar for home tab - Always Visible
                        AppSearchBar(text: $searchQuery, placeholder: "Search...")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        
                        Divider()
                            .padding(.horizontal, 16)
                    }
                    .background(Color.white)
                }
                
                // Tab Content - Takes remaining space
                ZStack {
                    switch selectedTab {
                    case 0:
                        NavigationStack {
                            ScrollView {
                                VStack(spacing: 24) {
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                                    }
                                    .frame(height: 0)
                                    
                     
                                    
                                    // Live Concert Banner Carousel
                                    LiveConcertCarousel()
                                    
                                    // Events Section
                                    EventsSection(
                                        events: filteredEvents,
                                        onEventClick: { event in
                                            selectedEventId = event.id
                                            navigateToEventDetail = true
                                        }
                                    )
                                    
                                    // Community Owners Section
                                    if !filteredCommunities.isEmpty {
                                        CommunityOwnersSection(
                                            communities: filteredCommunities,
                                            onCommunityClick: { community in
                                                selectedCommunity = community
                                                navigateToCommunityDetail = true
                                            }
                                        )
                                    }
                                    
                                    // Ads Section
                                    if !viewModel.adData.isEmpty {
                                        AdSection(ads: viewModel.adData)
                                    }
                                    
                                    Spacer().frame(height: 120)
                                }
                            }
                            .coordinateSpace(name: "scroll")
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                scrollOffset = value
                            }
                            .refreshable {
                                await viewModel.loadHomeData()
                            }
                            .navigationDestination(isPresented: $navigateToEventDetail) {
                                if let eventId = selectedEventId {
                                    EventDetailScreen(eventId: eventId)
                                }
                            }
                            .navigationDestination(isPresented: $navigateToCommunityDetail) {
                                if let community = selectedCommunity {
                                    CommunityEventDetailsScreen(community: community)
                                }
                            }
                        }
                        .preference(key: ScrollOffsetPreferenceKey.self, value: scrollOffset)
                    case 1:
                        EventsScreen(parentIsBarVisible: $isBarVisible)
                    case 2:
                          AadhaarVerificationScreen()
                    case 3:
                        CommunitiesScreen()
                    case 4:
                        ProfileScreen()
                    default:
                        HomeScreen()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingButton(action: {
                        navigateToIPL = true
                    })
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
                
                }
            }
            
            // Bottom Navigation Bar
            CommonBottomBar(currentRoute: currentRoute, onTabSelected: { tabIndex in
                selectedTab = tabIndex
            }, isBarVisible: $isBarVisible)
        }
        .onChange(of: scrollOffset) { newValue in
            let delta = newValue - lastScrollOffset
            
            if delta > 30 {
                // Scrolling up
                if isBarVisible {
                    isBarVisible = false
                }
            } else if delta < -30 {
                // Scrolling down
                if !isBarVisible {
                    isBarVisible = true
                }
            }
            
            if newValue > -50 && !isBarVisible {
                isBarVisible = true
            }
            
            lastScrollOffset = newValue
        }
        .navigationDestination(isPresented: $navigateToIPL) {
            IPLScreen(parentIsBarVisible: $isBarVisible)
        }
        .task {
            await viewModel.loadHomeData()
        }
    }
}

struct LiveConcertCarousel: View {
    @State private var currentPage = 0
    let banners = [
        ("Live Concert", "Nov 23", "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3"),
        ("Music Fest", "Dec 5", "https://images.unsplash.com/photo-1459749411175-04bf5292ceea"),
        ("DJ Night", "Dec 15", "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7")
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentPage) {
                ForEach(0..<banners.count, id: \.self) { index in
                    BannerCard(
                        title: banners[index].0,
                        date: banners[index].1,
                        imageUrl: banners[index].2
                    )
                    .tag(index)
                }
            }
            .frame(height: 140)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
                currentPage = (currentPage + 1) % banners.count
            }
            
            // Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<banners.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.black : Color.gray.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct BannerCard: View {
    let title: String
    let date: String
    let imageUrl: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.3)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Color.gray.opacity(0.3)
                @unknown default:
                    Color.gray.opacity(0.3)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            HStack(alignment: .bottom, spacing: 4) { // Changed to VStack for better layout
                Text(title)
                    .font(.custom("Spectral", size: 24))
                    .foregroundColor(Color(hex: "#F5F5F0"))
                Text(date)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#F5F5F0"))
            }
            .padding(.leading, 16)
            .padding(.bottom, 53) // Reduced from 45 to 20
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct EventsSection: View {
    let events: [Event]
    let onEventClick: (Event) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Events") {
                // See all action
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(events) { event in
                        EventCard(event: event)
                            .onTapGesture {
                                onEventClick(event)
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: event.coverImage)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 136, height: 188)
            .clipShape(RoundedRectangle(cornerRadius: 8))
                    

            Text(event.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(event.date)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(width: 136)
    }
}

struct SectionHeader: View {
    let title: String
    let onSeeAll: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "#FF6B35"))
            
            Spacer()
            
            Button(action: onSeeAll) {
                HStack(spacing: 4) {
                    Text("See all")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#FF6B35"))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#FF6B35"))
                }
            }
        }
        .padding(.horizontal, 25)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search events...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct AdSection: View {
    let ads: [AdData]
    @State private var currentIndex = 0
    
    var body: some View {
        if !ads.isEmpty {
            AsyncImage(url: URL(string: ads[currentIndex].imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
                if ads.count > 1 {
                    currentIndex = (currentIndex + 1) % ads.count
                }
            }
        }
    }
}

struct CommunityOwnersSection: View {
    let communities: [Community]
    let onCommunityClick: (Community) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Community Owners", onSeeAll: {
                // See all action
            })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(communities) { community in
                        CommunityCard(community: community, onTap: {
                            onCommunityClick(community)
                        })
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct HomeScreenCommunityCard: View {
    let community: Community
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: community.coverImage)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 136, height: 188)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(community.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text("By \(community.ownerName)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                Text("\(community.memberCount)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 136)
    }
}
