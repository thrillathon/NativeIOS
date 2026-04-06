import SwiftUI

struct ScrollOffsetTrackerModifier: ViewModifier {
    var onOffsetChange: (CGFloat) -> Void
    @State private var lastOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .modifier(ScrollOffsetReaderModifier { offset in
                    onOffsetChange(offset)
                })
        }
    }
}

struct ScrollOffsetReaderModifier: ViewModifier {
    var onOffsetChange: (CGFloat) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: .global).minY) { newValue in
                            onOffsetChange(newValue)
                        }
                }
            )
    }
}

extension View {
    func trackScrollOffset(_ onOffsetChange: @escaping (CGFloat) -> Void) -> some View {
        modifier(ScrollOffsetTrackerModifier(onOffsetChange: onOffsetChange))
    }
}
