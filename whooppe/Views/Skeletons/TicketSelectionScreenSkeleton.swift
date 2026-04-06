import SwiftUI

struct TicketSelectionScreenSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Event Info Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        SkeletonBox(width: 200, height: 10)
                        Spacer()
                        SkeletonCircle(size: 20)
                    }
                    
                    HStack {
                        SkeletonCircle(size: 16)
                        SkeletonBox(width: 80, height: 12)
                        Spacer().frame(width: 20)
                        SkeletonCircle(size: 16)
                        SkeletonBox(width: 60, height: 12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                // Select Tickets Section
                VStack(alignment: .leading, spacing: 16) {
                    SkeletonBox(width: 110, height: 16)
                    SkeletonBox(width: 200, height: 12)
                    
                    ForEach(0..<3, id: \.self) { _ in
                        TicketCardSkeleton()
                    }
                }
                .padding(.horizontal, 20)
                
                // Ad Banner
                SkeletonBox(height: 120, cornerRadius: 12)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct TicketCardSkeleton: View {
    var body: some View {
        SkeletonBox(height: 48, cornerRadius: 10)
    }
}
