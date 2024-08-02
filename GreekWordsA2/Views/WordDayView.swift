import SwiftUI

// swiftlint:disable identifier_name
struct WordDayView: View {
    @ObservedObject var viewModel: WordsDayViewModel
    @State private var word: [Character] = ["e", "x", "a", "m", "p", "l", "e"]
    @State private var selectedPoints: [CGPoint] = []
    @State private var currentPoint: CGPoint?
    @State private var allCirclesSelected = false
    @State private var selectedLetters: String = ""
    @State private var pathColor: Color = .greenUniversal
    @State var numberOfPoints: Int = 7
    private let radius: CGFloat = 100
    private var center: CGPoint {
        CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 1.6)
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
                let point = CGPoint(x: xxx, y: yyy)

                CharViewForGame(letter: word[index])
                    .position(point)
            }

            if !selectedPoints.isEmpty {
                Path { path in
                    path.addLines(selectedPoints)
                    if let currentPoint = currentPoint {
                        path.addLine(to: currentPoint)
                    }
                }
                .stroke(pathColor, lineWidth: 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .gesture(DragGesture()
            .onChanged { value in
                guard !allCirclesSelected else { return }
                currentPoint = value.location
                for index in 0..<numberOfPoints {
                    let angle = 2 * .pi / Double(numberOfPoints) * Double(index)
                    let xxx = center.x + radius * CGFloat(cos(angle))
                    let yyy = center.y + radius * CGFloat(sin(angle))
                    let point = CGPoint(x: xxx, y: yyy)
                    if distance(from: point, to: value.location) < 30 {
                        if selectedPoints.isEmpty || selectedPoints.last != point {
                            if !selectedPoints.contains(point) {
                                selectedPoints.append(point)
                                selectedLetters.append(word[index])
                            }
                        }
                    }
                }
                allCirclesSelected = selectedPoints.count == numberOfPoints
            }
            .onEnded { _ in
                if !allCirclesSelected {
                    selectedPoints.removeAll()
                    selectedLetters.removeAll()
                    pathColor = .greenUniversal
                } else {
                    let words = viewModel.grWord.split(separator: " ")
                    let targetWord = words.last ?? words.first ?? ""
                    if selectedLetters != targetWord {
                        pathColor = .red
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            selectedPoints.removeAll()
                            selectedLetters.removeAll()
                            pathColor = .greenUniversal
                            allCirclesSelected = false
                        }
                    }
                    currentPoint = nil
                }
            }
        )
        .onChange(of: viewModel.grWord) { newValue in
            let words = newValue.split(separator: " ")
            let targetWord = words.last ?? words.first ?? ""
            word = Array(targetWord)
            word.shuffle()
            numberOfPoints = word.count
        }
    }

    func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }
}
// swiftlint:enable identifier_name

#Preview {
    Color.grayDN
        .ignoresSafeArea()
        .overlay {
            WordDayView(viewModel: WordsDayViewModel())
        }
}
