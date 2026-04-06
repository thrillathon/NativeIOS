import SwiftUI

struct EventsScreenSkeleton: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<2, id: \.self) { _ in
                    LargeEventCardSkeleton()
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
}

struct LargeEventCardSkeleton: View {
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                SkeletonBox(width: 270, height: 440, cornerRadius: 24)
                
                VStack(alignment: .leading, spacing: 6) {
                    SkeletonBox(width: 180, height: 12)
                    SkeletonBox(width: 200, height: 16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .frame(width: 270)
    }
}
