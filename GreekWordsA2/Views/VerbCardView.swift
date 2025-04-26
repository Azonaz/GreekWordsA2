import SwiftUI

struct VerbCardView: View {
    let title: String
    let content: String
    var resetTrigger: Bool

    @State private var isFlipped = false
    @Environment(\.horizontalSizeClass) var sizeClass

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
                        .rotation3DEffect(
                            .degrees(isFlipped ? 180 : 0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                )
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.5)) {
                isFlipped.toggle()
            }
        }
        .onChange(of: resetTrigger) { _ in
            isFlipped = false
        }
        .padding(.horizontal)
    }
}

#Preview {
    VerbCardView(title: "Ενεστώτας", content: "πηγαίνω", resetTrigger: false)
}
