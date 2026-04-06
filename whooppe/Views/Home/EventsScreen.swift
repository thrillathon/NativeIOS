import SwiftUI

struct EventsScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchQuery = ""
    @State private var bookmarkedEventIds: Set<String> = []
    @State private var scrollOffset: CGFloat = 0
    @State private var localBarVisible = true
    @State private var lastScrollOffset: CGFloat = 0
    var parentIsBarVisible: Binding<Bool>?
    
    init(parentIsBarVisible: Binding<Bool>? = nil) {
        self.parentIsBarVisible = parentIsBarVisible
    }
    
    var filteredEvents: [Event] {
        if searchQuery.isEmpty {
            return viewModel.events
        } else {
            return viewModel.events.filter { event in
                event.name.localizedCaseInsensitiveContains(searchQuery) ||
                event.venue.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Top Bar with Search
                    VStack(spacing: 8) {
                        CommonTopBar(title: "Events")
                        
                       
                        
                        // Search Bar - Always Visible
                        AppSearchBar(text: $searchQuery, placeholder: "Search events...")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                        
                        
                    }
                    .background(Color.white)
                    
                    // Events Content - Takes remaining space
                    ZStack {
                        if viewModel.isLoading && viewModel.events.isEmpty {
                            EventsScreenSkeleton()
                        } else if filteredEvents.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                Text(searchQuery.isEmpty ? "No events available" : "No events found")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        } else {
                            // MAIN VERTICAL SCROLLVIEW - This is what you need
                            ScrollView(.vertical, showsIndicators: true) {
                                VStack(alignment: .leading, spacing: 24) {
                                    // Trending Events Section
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Trending Now")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 20)
                                        
                                        // Horizontal scroll for trending events
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 16) {
                                                ForEach(filteredEvents.prefix(5), id: \.id) { event in
                                                    NavigationLink(destination: EventDetailScreen(eventId: event.id)) {
                                                        EventCardExact(
                                                            event: event,
                                                            isBookmarked: bookmarkedEventIds.contains(event.id),
                                                            onBookmarkClick: {
                                                                if bookmarkedEventIds.contains(event.id) {
                                                                    bookmarkedEventIds.remove(event.id)
                                                                } else {
                                                                    bookmarkedEventIds.insert(event.id)
                                                                }
                                                            }
                                                        )
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                        }
                                        .frame(height: 420)
                                    }
                                    
                                    // Upcoming Events Section
                                    if filteredEvents.count > 5 {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("Upcoming Events")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 20)
                                            
                                            // Horizontal scroll for upcoming events
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 16) {
                                                    ForEach(filteredEvents.dropFirst(5), id: \.id) { event in
                                                        NavigationLink(destination: EventDetailScreen(eventId: event.id)) {
                                                            EventCardExact(
                                                                event: event,
                                                                isBookmarked: bookmarkedEventIds.contains(event.id),
                                                                onBookmarkClick: {
                                                                    if bookmarkedEventIds.contains(event.id) {
                                                                        bookmarkedEventIds.remove(event.id)
                                                                    } else {
                                                                        bookmarkedEventIds.insert(event.id)
                                                                    }
                                                                }
                                                            )
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 20)
                                            }
                                            .frame(height: 420)
                                        }
                                    }
                                    
                                    Spacer().frame(height: 60)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .coordinateSpace(name: "eventScroll")
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, 
                                                   value: geo.frame(in: .named("eventScroll")).minY)
                                }
                            )
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                scrollOffset = value
                            }
                        }
                    }
                    .background(Color.white)
                }
            }
            .background(Color.white)
            .preference(key: ScrollOffsetPreferenceKey.self, value: scrollOffset)
        }
        .task {
            if viewModel.events.isEmpty {
                await viewModel.loadHomeData()
            }
        }
        .onChange(of: scrollOffset) { newValue in
            let delta = newValue - lastScrollOffset
            
            if delta > 30 {
                if parentIsBarVisible?.wrappedValue != false {
                    parentIsBarVisible?.wrappedValue = false
                }
            } else if delta < -30 {
                if parentIsBarVisible?.wrappedValue != true {
                    parentIsBarVisible?.wrappedValue = true
                }
            }
            
            if newValue > -50 && parentIsBarVisible?.wrappedValue != true {
                parentIsBarVisible?.wrappedValue = true
            }
            
            lastScrollOffset = newValue
        }
    }
}

struct EventCardExact: View {
    let event: Event
    let isBookmarked: Bool
    let onBookmarkClick: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                // Main Card
                VStack(spacing: 0) {
                    // Event Poster Image
                    ZStack {
                        AsyncImage(url: URL(string: event.coverImage)) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .aspectRatio(contentMode: .fill)
                    }
                    .frame(height: 360)
                    .clipped()
                    
                    // Event Info Section (white background)
                    VStack(alignment: .leading, spacing: 8) {
                        // Date and Time - Combined on one line
                        Text("\(event.date) | \(event.time)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.black)
                        
                        // Event Name and Location
                        Text("\(event.name)\(event.venue.isEmpty ? "" : " | \(event.venue)")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                }
                .frame(width: 270)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 0.5)
                )
                .shadow(radius: 8)
                
                // Bookmark Button (in top right corner of image)
                Button(action: onBookmarkClick) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
                .padding(12)
            }
        }
    }
}

#Preview {
    EventsScreen()
}