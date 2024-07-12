import SwiftUI

struct WordDayView: View {
    @State private var word: [Character] = Array("SWIFTWOW").shuffled()
    var numberOfPoints = 0
    let radius: CGFloat = 100
    let center: CGPoint

    init() {
        center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 1.6)
        numberOfPoints = word.count
    }

    var body: some View {
            ZStack {
                Circle()
                    .stroke(Color.blackDN.opacity(0.1), lineWidth: 1)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)

                ForEach(0..<numberOfPoints, id: \.self) { index in
                    let angle = 2 * .pi / Double(numberOfPoints) * Double(index)
                    let xxx = center.x + radius * CGFloat(cos(angle))
                    let yyy = center.y + radius * CGFloat(sin(angle))

                    CharViewForGame(letter: word[word.index(word.startIndex, offsetBy: index)])
                        .position(CGPoint(x: xxx, y: yyy))
                }
            }
        }
    }

#Preview {
    Color.grayDN
        .ignoresSafeArea()
        .overlay {
            WordDayView()
        }
}
