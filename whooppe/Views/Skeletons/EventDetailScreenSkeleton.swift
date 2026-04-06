import SwiftUI
import Combine

struct InfoRowSkeleton: View {
    var body: some View {
        HStack(alignment: .center) {
            SkeletonCircle(size: 18)
            Spacer().frame(width: 8)
            SkeletonBox(width: 150, height: 12)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
