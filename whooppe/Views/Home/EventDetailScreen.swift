import SwiftUI

struct EventDetailScreen: View {
    let eventId: String
    @StateObject private var viewModel = EventDetailViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var isDescriptionExpanded = false
    @State private var currentAdIndex = 0
    @State private var navigateToTicketSelection = false
    @State private var adTimer: Timer? = nil
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let imageHeight: CGFloat = 450
                
                ZStack(alignment: .top) {
                    // Full-bleed Event Image
                    AsyncImage(url: URL(string: viewModel.event?.coverImage ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: imageHeight)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
                    .zIndex(0)
                    .padding(.vertical, -10)

                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: imageHeight - 110)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Event Title and Status
                                HStack(alignment: .top, spacing: 12) {
                                    Text(viewModel.event?.name ?? "Event Name")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.black)
                                        .lineLimit(2)
                                        .flexibleWidth()
                                    
                                    Text((viewModel.event?.status ?? "Upcoming").uppercased())
                                        .font(.system(size: 12, weight: .regular ))
                                        .foregroundColor(Color(hex: "#4CAF50"))
                                        .tracking(0.5)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "#E8F5E9"))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(hex: "#4CAF50").opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                                
                                // Description
                                ExpandableDescription(
                                    text: viewModel.event?.description ?? "No description available",
                                    isExpanded: $isDescriptionExpanded
                                )
                                .padding(.horizontal, 20)
                                
                                // Event Info Section
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 20) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "calendar")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                                .frame(width: 20)
                                            Text(viewModel.event?.date ?? "TBD")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                        }
                                        
                                        HStack(spacing: 8) {
                                            Image(systemName: "clock")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                                .frame(width: 20)
                                            Text(viewModel.event?.time ?? "TBD")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                        }
                                        
                                        Spacer(minLength: 0)
                                    }
                                    
                                    EventInfoRow(
                                        icon: "globe",

                                        label: "Language - \(viewModel.event?.language ?? "English")"
                                    )
                                    
                                    EventInfoRow(
                                        icon: "person.fill",
                                        label: "Age Limit - \(viewModel.event?.ageLimit ?? "All")"
                                    )
                                    
                                    EventInfoRow(
                                        icon: "mappin.circle.fill",
                                        label: viewModel.event?.venue ?? "TBD",
                                        isVenue: true,
                                        locationLink: viewModel.event?.locationLink
                                    )
                                }
                                .padding(.horizontal, 20)
                                
                                // Ad Banner
                                if let ads = viewModel.event?.adImageUrls, !ads.isEmpty {
                                    AdCarouselView(
                                        ads: ads,
                                        currentIndex: $currentAdIndex,
                                        timer: $adTimer
                                    )
                                    .padding(.horizontal, 20)
                                }
                                
                                Spacer(minLength: 100)
                            }
                            .background(Color.white)
                        }
                        .background(Color.white)
                        .ignoresSafeArea(edges: .bottom)
                    }
                    .zIndex(1)
                }
            }
            .overlay(alignment: .bottom) {
                // Bottom Ticket Bar
                VStack(spacing: 0) {
                    Divider()
                        .opacity(0.3)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Starting at")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#B8860B"))
                            Text("₹\(Int(viewModel.event?.ticketPrice ?? 0))")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color(hex: "#8B6914"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            navigateToTicketSelection = true
                        }) {
                            Text("Grab Your Ticket")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 180, height: 44)
                                .background(Color(hex: "#D4B547"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#FFF8DC"))
                }
                .background(Color(hex: "#FFF8DC"))
            }
        }
        .task {
            await viewModel.loadEvent(eventId: eventId)
        }
        .navigationDestination(isPresented: $navigateToTicketSelection) {
            if let event = viewModel.event {
                TicketSelectionScreen(
                    eventId: event.id,
                    eventName: event.name,
                    venue: event.venue,
                    date: event.date,
                    time: event.time,
                    language: event.language ?? "English, Hindi",
                    locationLink: event.locationLink
                )
            }
        }
    }
}

// MARK: - Ad Carousel Component
struct AdCarouselView: View {
    let ads: [String]
    @Binding var currentIndex: Int
    @Binding var timer: Timer?
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(ads.enumerated()), id: \.offset) { index, adURL in
                AsyncImage(url: URL(string: adURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .tag(index)
            }
        }
        .frame(height: 120)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .onAppear {
            if ads.count > 1 && timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                    withAnimation {
                        currentIndex = (currentIndex + 1) % ads.count
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

// MARK: - Expandable Description Component
struct ExpandableDescription: View {
    let text: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#666666"))
                        .lineSpacing(4)
                    
                    HStack(spacing: 0) {
                        Text(" ")
                        Text("less")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "#D4B547"))
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#666666"))
                        .lineSpacing(4)
                        .lineLimit(2)
                    
                    HStack(spacing: 0) {
                        Text("... ")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#666666"))
                        Text("more")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "#D4B547"))
                    }
                    .lineLimit(1)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }
                }
            }
        }

    }
}

// MARK: - Event Info Row Component
struct EventInfoRow: View {
    let icon: String
    let label: String
    var isVenue: Bool = false
    var locationLink: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .frame(width: 24)
            
            Text(isVenue ? "Venue - \(label)" : label)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .lineLimit(isVenue ? 2 : 1)
            
            if isVenue {
                if let locationLink = locationLink, let url = URL(string: locationLink) {
                    Link(destination: url) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#00BCD4"))
                    }
                }
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func flexibleWidth() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
#Preview {
    EventDetailScreen(eventId: "")
}
