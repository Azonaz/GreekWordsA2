import SwiftUI

struct VerbCardView: View {
    @Binding var isFlipped: Bool
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    let title: String
    let content: String
    private var cardHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone && vSizeClass == .compact {
            return 80
        }
        return sizeClass == .regular ? 150 : 100
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.whiteDN)
                .frame(height: cardHeight)
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
