import SwiftUI

struct VerbCardView: View {
    @Binding var isFlipped: Bool
    @Environment(\.horizontalSizeClass) var sizeClass
    let title: String
    let content: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.whiteDN)
                .frame(height: sizeClass == .regular ? 150 : 100)
                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                .overlay(
                    Text(isFlipped ? content : title)
                        .font(sizeClass == .regular ? .largeTitle : .title2)
                        .foregroundColor(.blackDN)
                        .multilineTextAlignment(.center)
                        .padding()
                        .scaleEffect(isFlipped ? CGSize(width: -1, height: 1) : CGSize(width: 1, height: 1))
                )
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(.easeInOut(duration: 0.4), value: isFlipped)
        }
        .onTapGesture {
            isFlipped.toggle()
        }
        .padding(.horizontal)
    }
}

#Preview {
    VerbCardPreview()
}

private struct VerbCardPreview: View {
    @State private var flipped = false

    var body: some View {
        VerbCardView(isFlipped: $flipped, title: "Ενεστώτας", content: "πηγαίνω")
    }
}
