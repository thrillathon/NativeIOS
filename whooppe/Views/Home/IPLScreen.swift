import SwiftUI

struct IPLScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var localBarVisible = true
    @State private var lastScrollOffset: CGFloat = 0
    var parentIsBarVisible: Binding<Bool>?
    
    init(parentIsBarVisible: Binding<Bool>? = nil) {
        self.parentIsBarVisible = parentIsBarVisible
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Bar
               
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("iplScroll")).minY)
                        }
                        .frame(height: 0)
                        
                        VStack(spacing: 0) {
                            ForEach(viewModel.events.filter { $0.name.contains("IPL") }, id: \.id) { event in
                                NavigationLink(value: Routes.createEventDetailRoute(eventId: event.id)) {
                                    IPLEventCard(event: event)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        if viewModel.events.filter({ $0.name.contains("IPL") }).isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "sportscourt")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                
                                Text("No IPL Events")
                                    .font(.headline)
                                
                                Text("Check back soon for upcoming matches")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        }
                    }
                }
                .coordinateSpace(name: "iplScroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
                .preference(key: ScrollOffsetPreferenceKey.self, value: scrollOffset)
                
                Spacer()
            }
            .navigationTitle("IPL Events")
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
                        }}
                        .navigationBarBackButtonHidden(true) // Add this to hide default back button


                    
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
}

struct IPLEventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: event.coverImage)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(height: 180)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(event.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    Label(event.venue, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Label(event.date, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct IPLScreen_Previews: PreviewProvider {
    static var previews: some View {
        IPLScreen()
    }
}
