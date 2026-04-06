import SwiftUI

struct PaymentScreenSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Event Ticket Card
                SkeletonBox(height: 145, cornerRadius: 12)
                    .padding(.horizontal, 10)
                
                // Payment Details
                SkeletonBox(height: 160, cornerRadius: 25)
                    .padding(.horizontal, 16)
                
                // User Details
                SkeletonBox(height: 100, cornerRadius: 25)
                    .padding(.horizontal, 16)
                
                Spacer().frame(height: 80)
            }
            .padding(.top, 16)
        }
    }
}
