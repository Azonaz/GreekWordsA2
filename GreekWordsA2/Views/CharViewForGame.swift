import SwiftUI

struct CharViewForGame: View {
    let letter: Character
    @Binding var isSelected: Bool
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.clear, lineWidth: 0)
                .background(isSelected ? Circle().foregroundColor(.grayDN) : Circle().foregroundColor(.whiteDN))
                .shadow(color: isSelected ? .grayUniversal.opacity(0.5) : .clear,
                        radius: isSelected ? 5 : 0,
                        x: isSelected ? 2 : 0,
                        y: isSelected ? 2 : 0)
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Text(String(letter))
                        .font(.largeTitle)
                        .foregroundColor(.blackDN)
                )
        }
    }

    var circleSize: CGFloat {
        if sizeClass == .regular {
            return 80
        } else {
            return 50
        }
    }
}

#Preview {
    Color.grayDN
        .ignoresSafeArea()
        .overlay {
            CharViewForGame(letter: "A", isSelected: Binding.constant(false))
        }
}
