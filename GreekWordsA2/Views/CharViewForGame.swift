import SwiftUI

struct CharViewForGame: View {
    let letter: Character

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
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
            CharViewForGame(letter: "A")
        }
}
