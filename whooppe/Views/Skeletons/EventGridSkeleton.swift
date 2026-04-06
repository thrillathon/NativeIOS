import SwiftUI
import Combine

// MARK: - Grid Skeleton Card
struct EventGridSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image skeleton
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 180)
            
            // Content skeleton
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .frame(width: 120)
                
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                        .frame(width: 60)
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                        .frame(width: 50)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                    .frame(width: 100)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 14)
                    .frame(width: 80)
                    .padding(.top, 4)
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .opacity(isAnimating ? 0.5 : 1)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
