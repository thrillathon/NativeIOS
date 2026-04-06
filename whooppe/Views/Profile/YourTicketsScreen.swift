import SwiftUI
import CoreImage

struct YourTicketsScreen: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var hasLoadedData = false
    @State private var selectedTab: Int = 0  // 0 = Confirmed, 1 = Order
    @State private var selectedTicketForQR: Booking? = nil
    
    // Filter tickets based on selected tab
    var displayedTickets: [Booking] {
        if selectedTab == 0 {
            // Tickets Confirmed - show only confirmed tickets
            return viewModel.userTickets.filter { $0.ticketStatus == .confirmed }
        } else {
            // Ticket Order - show all non-confirmed tickets
            return viewModel.userTickets.filter { $0.ticketStatus != .confirmed }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Tab Section
            HStack(spacing: 0) {
                // Left tab - Tickets Confirmed
                HStack(spacing: 0) {
                    Spacer()
                    Text("Tickets Confirmed")
                        .font(.system(size: 15, weight: .regular))
                        .tracking(0.2)
                        .foregroundColor(selectedTab == 0 ? .black : .gray.opacity(0.5))
                        .onTapGesture {
                            selectedTab = 0
                        }
                    Spacer()
                }
                
                // Vertical Divider
                Divider()
                    .frame(height: 20)
                
                // Right tab - Ticket Order
                HStack(spacing: 0) {
                    Spacer()
                    Text("Ticket Order")
                        .font(.system(size: 15, weight: .regular))
                        .tracking(0.2)
                        .foregroundColor(selectedTab == 1 ? .black : .gray.opacity(0.5))
                        .onTapGesture {
                            selectedTab = 1
                        }
                    Spacer()
                }
            }
            .padding(.vertical, 20)
            
            // Ticket List
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(Color(hex: "#FFD700"))
                    Spacer()
                }
            } else if let errorMessage = viewModel.errorMessage, viewModel.userTickets.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        viewModel.refreshUserData()
                    }) {
                        Text("Retry")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(Color.black)
                            .cornerRadius(4)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else if displayedTickets.isEmpty {
                VStack {
                    Spacer()
                    Text("No tickets found")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(displayedTickets, id: \.id) { ticket in
                            TicketCard(ticket: ticket)
                                .onTapGesture {
                                    selectedTicketForQR = ticket
                                }
                        }
                        Spacer()
                            .frame(height: 16)
                    }
                    .padding(.horizontal, 26)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.white)
        .navigationTitle("Your Tickets")
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
                                    .foregroundColor(.black)                    }
                }
            }
            .navigationBarBackButtonHidden(true) // Add this to hide default back button
              
        .task {
            if !hasLoadedData {
                hasLoadedData = true
                viewModel.refreshUserData()
            }
        }
        .sheet(item: $selectedTicketForQR) { ticket in
            TicketQRDialog(ticket: ticket)
        }
    }
}

struct TicketCard: View {
    let ticket: Booking
    @Environment(\.openURL) var openURL
    
    var ticketNumber: String {
        if let numbers = ticket.ticketNumbers, !numbers.isEmpty {
            return numbers
        }
        return "Not Allotted yet"
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 0) {
                // Main content row
                HStack(spacing: 12) {
                    // Movie Poster
                    VStack {
                        if let posterUrl = FormatUtils.getFullImageUrl(ticket.eventId.coverImage) {
                            AsyncImage(url: URL(string: posterUrl)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                case .failure:
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                @unknown default:
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 89, height: 119)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(width: 89, height: 119)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    // Movie Details Column
                    VStack(alignment: .leading, spacing: 4) {
                        // Movie Title
                        Text(ticket.eventId.name)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        // Language/Seat Type
                        Text(ticket.seatType ?? "")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.black)
                            .lineHeight(8)
                        
                        Spacer()
                            .frame(height: 25)
                        
                        // Date and Time
                        Text(FormatUtils.formatDate(ticket.eventId.date))
                            .font(.system(size: 8, weight: .regular))
                            .foregroundColor(.black)
                            .lineHeight(7)
                            .tracking(0.2)
                        
                        // Venue with location icon
                        HStack(spacing: 4) {
                            Text(ticket.eventId.venue)
                                .font(.system(size: 8, weight: .regular))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .tracking(0.2)
                            
                            if !ticket.eventId.locationLink.isEmpty {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        if let url = URL(string: ticket.eventId.locationLink) {
                                            openURL(url)
                                        }
                                    }
                            }
                        }
                        
                        Spacer()
                        
                        // User name and Ticket Number
                        HStack(spacing: 8) {
                            Text(ticket.userId.prefix(1).uppercased() + ticket.userId.dropFirst())
                                .font(.system(size: 8, weight: .regular))
                                .foregroundColor(.black)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("Ticket No: \(ticketNumber)")
                                .font(.system(size: 8, weight: .regular))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .tracking(-0.1)
                        }
                    }
                    
                    Spacer()
                }
                .padding(16)
                
                // Divider
                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                // Bottom section - Status and Ordered Date
                HStack {
                    // Status Badge (aligned with poster)
                    VStack {
                        VStack(alignment: .center) {
                            Text(ticket.ticketStatus.displayText)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(ticket.ticketStatus.color)
                                .tracking(-0.3)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 89)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    // Ordered Date
                    Text("Ordered Date: \(FormatUtils.formatDate(ticket.bookedAt))")
                        .font(.system(size: 8, weight: .regular))
                        .foregroundColor(.black)
                        .tracking(-0.1)
                        .padding(.trailing, 18)
                }
                .padding(.bottom, 8)
            }
            .frame(height: 175)
        }
        .background(Color.white)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

extension View {
    func lineHeight(_ height: CGFloat) -> some View {
        self
    }
}

struct TicketQRDialog: View {
    let ticket: Booking
    @Environment(\.dismiss) var dismiss
    @State private var qrImage: UIImage? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(8)
                }
            }
            .padding(24)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Event name
                    Text(ticket.eventId.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    // Date & Venue
                    Text("\(FormatUtils.formatDate(ticket.eventId.date)) • \(ticket.eventId.venue)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    // QR Code
                    VStack {
                        if let qrImage = qrImage {
                            Image(uiImage: qrImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 220)
                        } else {
                            VStack {
                                ProgressView()
                            }
                            .frame(width: 220, height: 220)
                            .background(Color.white)
                        }
                    }
                    .frame(width: 220, height: 220)
                    .background(Color.white)
                    .border(Color(hex: "#FFD700"), width: 2)
                    .cornerRadius(16)
                    .padding(12)
                    
                    // Ticket number
                    Text(ticket.ticketNumbers ?? "Not Allotted yet")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.black)
                        .tracking(0.5)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    
                    // Status badge
                    HStack {
                        Text(ticket.ticketStatus.displayText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ticket.ticketStatus.color)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(ticket.ticketStatus.color.opacity(0.1))
                    .cornerRadius(20)
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.white)
        .cornerRadius(28)
        .onAppear {
            generateQRCode()
        }
    }
    
    private func generateQRCode() {
        guard let qrCodeData = ticket.qrCodes, !qrCodeData.isEmpty else { return }
        
        if let qrImage = generateQR(from: qrCodeData) {
            self.qrImage = qrImage
        }
    }
    
    private func generateQR(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5.12, y: 5.12)
            if let output = filter.outputImage?.transformed(by: transform) {
                let ciContext = CIContext()
                if let cgImage = ciContext.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
}

#Preview {
    YourTicketsScreen()
}
