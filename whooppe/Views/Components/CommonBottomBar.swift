import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CommonBottomBar: View {
    let currentRoute: String?
    let onTabSelected: (Int) -> Void
    @Binding var isBarVisible: Bool
    
    @State private var selectedTab = 0
    
    let tabs: [(icon: String, title: String, route: String)] = [
        ("house.fill", "Home", "home"),
        ("calendar", "Events", "events"),
        ("qrcode.viewfinder", "Aadhaar", "aadhaar_verification"),
        ("sportscourt.fill", "Communities", "communities"),
        ("person.fill", "Profile", "profile")
    ]
    
    // Alternative icon options:
    /* HOME OPTIONS:
       "house.fill"          - Solid home
       "house"               - Outline home
       "building.2.fill"     - Building solid
       "square.grid.2x2.fill" - Grid solid
       "square.grid.2x2"     - Grid outline
    */
    
    /* EVENTS OPTIONS:
       "calendar"            - Calendar outline
       "calendar.circle"     - Calendar circle
       "calendar.circle.fill" - Calendar circle solid
       "star.fill"           - Star solid
       "list.bullet"         - List
       "ticket.fill"         - Ticket solid
    */
    
    /* AADHAAR OPTIONS:
       "qrcode.viewfinder"  - QR scanner (current)
       "qrcode"             - QR code
       "barcode.viewfinder" - Barcode scanner
       "id.card.fill"       - ID card solid
       "id.card"            - ID card outline
       "doctext.fill"       - Document solid
    */
    
    /* COMMUNITIES OPTIONS:
       "sportscourt.fill"   - Sports court solid (current)
       "sportscourt"        - Sports court outline
       "cricket"            - Cricket
       "flag.fill"          - Flag solid
       "flag"               - Flag outline
       "target"             - Target
    */
    
    /* PROFILE OPTIONS:
       "person.fill"        - Person solid (current)
       "person"             - Person outline
       "person.circle.fill" - Person circle solid
       "person.circle"      - Person circle outline
       "gearshape.fill"     - Settings solid
       "gearshape"          - Settings outline
       "ellipsis.circle"    - More options
    */
    
    var body: some View {
        VStack(spacing: 0) {
            // Apple-style pill-shaped tab bar
            VStack {
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        let tab = tabs[index]
                        let isSelected = currentRoute == tab.route
                        
                        Button(action: {
                            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.2)) {
                                selectedTab = index
                                onTabSelected(index)
                            }
                        }) {
                            if index == 2 {
                                // Center colored circle button
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#D4B547"))
                                        .frame(width: 52, height: 52)
                                        .shadow(color: Color(hex: "#D4B547").opacity(0.3), radius: 8, x: 0, y: 4)
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            } else {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 20, weight: .semibold))
                                    
                                    Text(tab.title)
                                        .font(.system(size: 11, weight: .semibold))
                                        .lineLimit(1)
                                }
                                .foregroundColor(isSelected ? Color(hex: "#D4B547") : .gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .contentShape(Rectangle())
                            }
                        }
                        
                        if index < tabs.count - 1 && index != 1 {
                            Divider()
                                .frame(height: 40)
                                .opacity(0.1)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 65)
            }
            .background(Color.white)
            .frame(height: 65)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 8)
            .padding(.horizontal, 16)
        //    .padding(.vertical, 4)
            
            
    
        }
        .offset(y: isBarVisible ? 0 : 150)
        .animation(.easeInOut(duration: 0.3), value: isBarVisible)
    }
}
