import SwiftUI

struct HomeScreenSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Banner Carousel Skeleton
                BannerCarouselSkeleton()
                
                // Events Section Skeleton
                SectionSkeleton(title: "Events")
                
                // Ad Section Skeleton
                AdSkeleton()
                
                // Music Concerts Section Skeleton
                SectionSkeleton(title: "Music Concerts")
            }
        }
    }
}

struct BannerCarouselSkeleton: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            SkeletonBox(height: 160, cornerRadius: 20)
                .padding(.horizontal, 24)
            
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonCircle(size: 8)
                }
            }
        }
    }
}

struct SectionSkeleton: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                SkeletonBox(width: 80, height: 20)
                Spacer()
                SkeletonBox(width: 50, height: 14)
            }
            .padding(.horizontal, 25)
            
            // Event Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { _ in
                        EventCardSkeleton()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct EventCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SkeletonBox(width: 136, height: 188, cornerRadius: 8)
            SkeletonBox(width: 110, height: 14)
            SkeletonBox(width: 70, height: 12)
        }
        .frame(width: 136)
    }
}

struct AdSkeleton: View {
    var body: some View {
        SkeletonBox(height: 180, cornerRadius: 12)
            .padding(.horizontal, 20)
    }
}
