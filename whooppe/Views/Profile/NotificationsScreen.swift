import SwiftUI

struct NotificationsScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var notifications: [NotificationItem] = [
        NotificationItem(
            id: "1",
            title: "Booking Confirmed",
            message: "Your ticket booking for IPL Match has been confirmed",
            date: "Today",
            isRead: false,
            type: .booking
        ),
        NotificationItem(
            id: "2",
            title: "Event Reminder",
            message: "Your IPL match starts tomorrow at 7:00 PM",
            date: "Yesterday",
            isRead: true,
            type: .reminder
        ),
        NotificationItem(
            id: "3",
            title: "Special Offer",
            message: "Get 20% off on your next event booking",
            date: "3 days ago",
            isRead: true,
            type: .offer
        ),
        NotificationItem(
            id: "4",
            title: "Payment Received",
            message: "Payment of ₹1,500 received for your booking",
            date: "1 week ago",
            isRead: true,
            type: .payment
        ),
    ]
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            
            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.2))
            
            if notifications.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "bell.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No Notifications")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("You're all caught up!")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(notifications) { notification in
                            NotificationRow(notification: notification)
                            
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .background(Color.white)
    
     .navigationTitle("Notifications")
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
}
}
struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let date: String
    let isRead: Bool
    let type: NotificationType
}

enum NotificationType {
    case booking
    case reminder
    case offer
    case payment
    
    var icon: String {
        switch self {
        case .booking: return "ticket.fill"
        case .reminder: return "bell.fill"
        case .offer: return "tag.fill"
        case .payment: return "creditcard.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .booking: return Color(hex: "#2196F3")
        case .reminder: return Color(hex: "#FF9800")
        case .offer: return Color(hex: "#4CAF50")
        case .payment: return Color(hex: "#9C27B0")
        }
    }
}

struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                Image(systemName: notification.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(notification.type.color)
                    .frame(width: 32, height: 32)
                    .background(notification.type.color.opacity(0.1))
                    .clipShape(Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(notification.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color(hex: "#2196F3"))
                                .frame(width: 8, height: 8)
                        }
                        
                        Spacer()
                        
                        Text(notification.date)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    
                    Text(notification.message)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(16)
            .background(notification.isRead ? Color.white : Color.blue.opacity(0.02))
        }
    }
}

#Preview {
    NotificationsScreen()
}
