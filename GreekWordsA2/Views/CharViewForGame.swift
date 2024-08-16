import SwiftUI

struct CharViewForGame: View {
    let letter: Character
    @Binding var isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.clear, lineWidth: 0)
                .background(isSelected ? Circle().foregroundColor(.grayDN) : Circle().foregroundColor(.white))
                .shadow(color: isSelected ? .black.opacity(0.2) : .clear,
                        radius: isSelected ? 5 : 0,
                        x: isSelected ? 2 : 0,
                        y: isSelected ? 2 : 0)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(letter))
                        .font(.headline)
                        .foregroundColor(.black)
                )
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
