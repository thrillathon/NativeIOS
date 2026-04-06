import SwiftUI

struct CommonTopBar: View {
    let title: String
    let userName: String
    let location: String
    let showHomeIcons: Bool
    let unreadNotificationCount: Int
    let onBack: (() -> Void)?
    let onNotification: (() -> Void)?
    
    init(title: String = "Welcome,",
         userName: String = "",
         location: String = "Nayapura, Kota",
         showHomeIcons: Bool = true,
         unreadNotificationCount: Int = 0,
         onBack: (() -> Void)? = nil,
         onNotification: (() -> Void)? = nil) {
        self.title = title
        self.userName = userName
        self.location = location
        self.showHomeIcons = showHomeIcons
        self.unreadNotificationCount = unreadNotificationCount
        self.onBack = onBack
        self.onNotification = onNotification
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showHomeIcons && onBack == nil {
                // Home Screen Layout
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text(title)
                                .font(.custom("Spectral", size: 18))
                                .foregroundColor(Color(hex: "#F5F5F0"))
                            Text(userName.capitalized)
                                .font(.custom("Spectral", size: 20))
                                .fontWeight(.light)
                                .foregroundColor(Color(hex: "#FFF8E7"))
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "#F5F5F0"))
                            Text("Bharat")
                                .font(.custom("Spectral", size: 11))
                                .foregroundColor(Color(hex: "#F5F5F0").opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    // Notification Bell
                    Button(action: { onNotification?() }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#F5F5F0"))
                            
                            if unreadNotificationCount > 0 {
                                Text(unreadNotificationCount > 9 ? "9+" : "\(unreadNotificationCount)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 16, minHeight: 16)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                                    .offset(x: 8, y: -6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 26)
                .padding(.top, 12)
                .padding(.bottom, 8)
            } else {
                // Detail Screen Layout
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Text(title)
                            .font(.custom("Spectral", size: 20))
                            .fontWeight(.heavy)
                            .foregroundColor(Color(hex: "#F5F5F0"))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 26)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
        }
        .background(Color(hex: "#D4B547"))
    }
}
