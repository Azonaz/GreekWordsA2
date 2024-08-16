import SwiftUI

// swiftlint:disable identifier_name
struct WordDayView: View {
    @ObservedObject var viewModel: WordsDayViewModel
    @State private var word: [Character] = ["e", "x", "a", "m", "p", "l", "e"]
    @State private var selectedPoints: [CGPoint] = []
    @State private var currentPoint: CGPoint?
    @State private var allCirclesSelected = false
    @State private var selectedLetters: String = ""
    @State private var pathColor: Color = .grayDN
    @State var numberOfPoints: Int = 7
    @State private var selectedLettersStates: [Bool] = Array(repeating: false, count: 7)
    @State private var isTextVisible = false
    private let radius: CGFloat = 100

    var body: some View {
        if isTextVisible {
            Text(selectedLetters)
                .foregroundColor(.blackDN)
                .frame(height: 40)
                .padding(.horizontal, 15)
                .background(Color.whiteDN)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                .font(.title3)
                .tracking(3)
                .padding(.top, 40)
        }

        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let circleDiameter = radius * 2.7
            let verticalPadding: CGFloat = 50

            ZStack {
                Circle()
                    .fill(Color.whiteDN)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                    .frame(width: circleDiameter, height: circleDiameter)
                    .position(x: screenWidth / 2, y: screenHeight - (circleDiameter / 2) - verticalPadding)

                if !selectedPoints.isEmpty {
                    Path { path in
                        path.addLines(selectedPoints)
                        if let currentPoint = currentPoint {
                            path.addLine(to: currentPoint)
                        }
                    }
                    .stroke(pathColor, lineWidth: 2)
                }

                ForEach(0..<numberOfPoints, id: \.self) { index in
                    let angle = 2 * .pi / Double(numberOfPoints) * Double(index)
                    let xxx = screenWidth / 2 + radius * CGFloat(cos(angle))
                    let yyy = screenHeight - (circleDiameter / 2) - verticalPadding + radius * CGFloat(sin(angle))
                    let point = CGPoint(x: xxx, y: yyy)

                    CharViewForGame(letter: word[index], isSelected: $selectedLettersStates[index])
                        .position(point)
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
                        let xxx = screenWidth / 2 + radius * CGFloat(cos(angle))
                        let yyy = screenHeight - (circleDiameter / 2) - verticalPadding + radius * CGFloat(sin(angle))
                        let point = CGPoint(x: xxx, y: yyy)
                        if distance(from: point, to: value.location) < 30 {
                            if selectedPoints.isEmpty || selectedPoints.last != point {
                                if !selectedPoints.contains(point) {
                                    selectedPoints.append(point)
                                    selectedLetters.append(word[index])
                                    selectedLettersStates[index] = true
                                    isTextVisible = true
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
                        pathColor = .grayDN
                        isTextVisible = false
                        selectedLettersStates = Array(repeating: false, count: numberOfPoints)
                    } else {
                        let words = viewModel.grWord.split(separator: " ")
                        let targetWord = words.last ?? words.first ?? ""
                        if selectedLetters != targetWord {
                            pathColor = .redUniversal
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                selectedPoints.removeAll()
                                selectedLetters.removeAll()
                                pathColor = .grayDN
                                allCirclesSelected = false
                                isTextVisible = false
                                selectedLettersStates = Array(repeating: false,
                                                              count: numberOfPoints)
                            }
                        } else {
                            pathColor = .greenUniversal
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                selectedPoints.removeAll()
                                selectedLetters.removeAll()
                                pathColor = .grayDN
                                allCirclesSelected = false
                                isTextVisible = false
                                selectedLettersStates = Array(repeating: false,
                                                              count: numberOfPoints)
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
                selectedLettersStates = Array(repeating: false, count: numberOfPoints)
            }
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
