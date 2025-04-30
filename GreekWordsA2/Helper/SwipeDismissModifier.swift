import SwiftUI

struct SwipeDismissModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset = CGSize.zero

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragOffset = gesture.translation
                    }
                    .onEnded { _ in
                        if dragOffset.width > 100 {
                            dismiss()
                        }
                        dragOffset = .zero
                    }
            )
    }
}

extension View {
    func onSwipeDismiss() -> some View {
        self.modifier(SwipeDismissModifier())
    }
}
