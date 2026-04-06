import SwiftUI

struct TicketSelectionScreen: View {
    let eventId: String
    let eventName: String
    let venue: String
    let date: String
    let time: String
    let language: String
    let locationLink: String
    
    @StateObject private var viewModel = TicketSelectionViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var currentAdIndex = 0
    @State private var navigateToPayment = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            
            
            if viewModel.isLoading {
                // Loading state
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                }
                .frame(maxHeight: .infinity)
            } else if viewModel.errorMessage != nil && viewModel.tickets.isEmpty {
                // Error state
                VStack(spacing: 16) {
                    Text(viewModel.errorMessage ?? "Something went wrong")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        Task { await viewModel.loadTickets(eventId: eventId) }
                    }) {
                        Text("Retry")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                }
                .padding(20)
                .frame(maxHeight: .infinity, alignment: .center)
            } else if viewModel.tickets.isEmpty {
                // No tickets state
                VStack(spacing: 16) {
                    Text("No tickets available for this event")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        Task { await viewModel.loadTickets(eventId: eventId) }
                    }) {
                        Text("Retry")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                }
                .padding(20)
                .frame(maxHeight: .infinity, alignment: .center)
            } else {
                // Main content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Event Info Header
                        EventInfoHeader(
                            venue: venue,
                            date: date,
                            time: time,
                            locationLink: locationLink
                        )
                        
                        // Select Tickets Section
                        SelectTicketsSection(
                            tickets: viewModel.tickets,
                            selectedTicket: viewModel.selectedTicket,
                            onTicketSelect: { viewModel.selectTicket($0) }
                        )
                        
                        // Ad Banner if available
                        if !viewModel.adImageUrls.isEmpty {
                            TicketSelectionAdBanner(
                                adImageUrls: viewModel.adImageUrls,
                                currentIndex: $currentAdIndex
                            )
                        }
                        
                        Spacer()
                            .frame(height: 24)
                    }
                }
                .background(Color.white)
            }
            
            // Proceed Button (only show if ticket selected)
            if viewModel.selectedTicket != nil {
                ProceedBottomBar(
                    onButtonClick: {
                        viewModel.checkProfileAndProceed()
                    },
                    isLoading: viewModel.isCheckingProfile
                )
            }
        }
        .background(Color.white)
        .onAppear {
            viewModel.eventId = eventId
            viewModel.eventName = eventName
            viewModel.venue = venue
            viewModel.date = date
            viewModel.time = time
            viewModel.language = language
            viewModel.locationLink = locationLink
            Task { await viewModel.loadTickets(eventId: eventId) }
        }
        .onChange(of: viewModel.navigationEvent) { newEvent in
            if newEvent == .navigateToPayment {
                navigateToPayment = true
            }
        }
        .navigationDestination(isPresented: $navigateToPayment) {
            if let selectedTicket = viewModel.selectedTicket {
                PaymentScreen(
                    eventId: eventId,
                    seatingId: selectedTicket.id,
                    ticketPrice: selectedTicket.price,
                    eventName: eventName,
                    venue: venue,
                    date: date,
                    time: time,
                    language: language,
                    locationLink: locationLink
                )
            }
        }
        .navigationTitle(eventName)
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
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Event Info Header
struct EventInfoHeader: View {
    let venue: String
    let date: String
    let time: String
    let locationLink: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Venue with location icon
            HStack(spacing: 4) {
                Text(venue)
                    .font(.system(size: 10, weight: .regular))
                    .tracking(1.5)
                    .foregroundColor(Color(hex: "#999999"))
                
                Spacer()
                
                Button(action: {
                    if let url = URL(string: locationLink), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#00BCD4"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            
            // Date and Time
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black)
                        .frame(width: 16)
                    
                    Text(date)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black)
                        .frame(width: 16)
                    
                    Text(time)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Select Tickets Section
struct SelectTicketsSection: View {
    let tickets: [TicketType]
    let selectedTicket: TicketType?
    let onTicketSelect: (TicketType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Select Tickets")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("You can buy only one ticket at a time")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: "#999999"))
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 10) {
                ForEach(tickets, id: \.id) { ticket in
                    TicketCardView(
                        ticket: ticket,
                        isSelected: selectedTicket?.id == ticket.id,
                        onClick: { onTicketSelect(ticket) }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Ticket Card
struct TicketCardView: View {
    let ticket: TicketType
    let isSelected: Bool
    let onClick: () -> Void
    
    var isSoldOut: Bool {
        ticket.status == .soldOut
    }
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSoldOut ? Color(hex: "#CCCCCC") : .black)
                    
                    if let statusText = ticket.statusText {
                        Text(statusText)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(Color(hex: "#FF6B00"))
                    }
                }
                
                Spacer()
                
                // Price box
                Text(ticket.price == 0 ? "FREE" : "₹\(Int(ticket.price))")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(isSoldOut ? Color(hex: "#999999") : Color(hex: "#999999"))
                    .frame(width: 62, height: 30)
                    .background(isSelected ? Color(hex: "#FFF8DC") : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isSoldOut ? Color(hex: "#DDDDDD") : Color.black,
                                lineWidth: 1
                            )
                    )
                    .cornerRadius(10)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .background(Color(hex: "#F5F5F5"))
            .cornerRadius(10)
        }
        .disabled(isSoldOut)
        .opacity(isSoldOut ? 0.6 : 1.0)
    }
}

// MARK: - Ad Banner
struct TicketSelectionAdBanner: View {
    let adImageUrls: [String]
    @Binding var currentIndex: Int
    
    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: adImageUrls[currentIndex % adImageUrls.count])) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 160)
            .clipped()
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .onAppear {
                if adImageUrls.count > 1 {
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                        withAnimation {
                            currentIndex = (currentIndex + 1) % adImageUrls.count
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TicketSelectionScreen(
        eventId: "1",
        eventName: "Test Event",
        venue: "Test Venue",
        date: "2024-04-15",
        time: "19:00",
        language: "English",
        locationLink: ""
    )
}

#Preview {
    TicketSelectionScreen(
        eventId: "1",
        eventName: "Test Event",
        venue: "Test Venue",
        date: "2024-04-15",
        time: "19:00",
        language: "English",
        locationLink: ""
    )
}
