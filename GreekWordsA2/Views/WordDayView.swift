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
    @Binding var isWordAlreadySolvedForToday: Bool
    private let radius: CGFloat = 100
    private let userDefaults = UserDefaults.standard
    private let solvedDateKey = "solvedDate"
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        if isTextVisible {
            Text(selectedLetters)
                .foregroundColor(.blackDN)
                .frame(height: 35)
                .padding(.horizontal, 15)
                .background(Color.whiteDN)
                .cornerRadius(16)
                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                .font(.title3)
                .tracking(3)
                .padding(.top, 35)
        }

        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let diameter = radius * 2.7
            let verticalPadding: CGFloat = 50

            if !isWordAlreadySolvedForToday {
                ZStack {
                    Circle()
                        .fill(Color.whiteDN)
                        .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                        .frame(width: diameter, height: diameter)
                        .position(x: screenWidth / 2, y: screenHeight - (diameter / 2) - verticalPadding)

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
                        let x = screenWidth / 2 + radius * CGFloat(cos(angle))
                        let y = screenHeight - (diameter / 2) - verticalPadding + radius * CGFloat(sin(angle))
                        let point = CGPoint(x: x, y: y)

                        CharViewForGame(letter: word[index], isSelected: $selectedLettersStates[index])
                            .position(point)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .gesture(DragGesture()
                    .onChanged { value in
                        guard !allCirclesSelected && !isWordAlreadySolvedForToday else { return }
                        currentPoint = value.location
                        for index in 0..<numberOfPoints {
                            let angle = 2 * .pi / Double(numberOfPoints) * Double(index)
                            let x = screenWidth / 2 + radius * CGFloat(cos(angle))
                            let y = screenHeight - (diameter / 2) - verticalPadding + radius * CGFloat(sin(angle))
                            let point = CGPoint(x: x, y: y)
                            if distance(from: point, to: value.location) < 30 {
                                if selectedPoints.isEmpty || selectedPoints.last != point {
                                    if !selectedPoints.contains(point) {
                                        selectedPoints.append(point)
                                        selectedLetters.append(word[index])
                                        selectedLettersStates[index] = true
                                        isTextVisible = true
                                        feedbackGenerator.impactOccurred()
                                    }
                                }
                            }
                        }
                        allCirclesSelected = selectedPoints.count == numberOfPoints
                    }
                    .onEnded { _ in
                        if !allCirclesSelected {
                            resetSelection()
                        } else {
                            checkSolution()
                        }
                    }
                )
                .onAppear {
                    checkIfWordSolvedToday()
                    if !isWordAlreadySolvedForToday {
                        updateWord(viewModel.grWord)
                    }
                }
                .onChange(of: viewModel.grWord) { newValue in
                    if !isWordAlreadySolvedForToday {
                        updateWord(newValue)
                    }
                }
            } else {
                VStack {
                    Text(viewModel.grWord)
                        .foregroundColor(.blackDN)
                        .font(.title)
                        .padding(.bottom, 10)

                    Text(viewModel.enWord)
                        .foregroundColor(.blackDN)
                        .font(.title3)
                }
                .frame(width: screenWidth - 80, height: 150)
                .background(Color.whiteDN)
                .cornerRadius(16)
                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                .position(x: screenWidth / 2, y: screenHeight / 1.5)
            }
        }
    }

    private func checkSolution() {
        let words = viewModel.grWord.split(separator: " ")
        let targetWord = words.last ?? words.first ?? ""
        if selectedLetters == targetWord {
            pathColor = .greenUniversal
            saveSolvedDate()
        } else {
            pathColor = .redUniversal
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            resetSelection()
            pathColor = .grayDN
        }
    }

    private func resetSelection() {
        selectedPoints.removeAll()
        selectedLetters.removeAll()
        isTextVisible = false
        selectedLettersStates = Array(repeating: false, count: numberOfPoints)
        allCirclesSelected = false
    }

    private func updateWord(_ newValue: String) {
        let words = newValue.split(separator: " ")
        let targetWord = words.last ?? words.first ?? ""
        word = Array(targetWord)
        word.shuffle()
        numberOfPoints = word.count
        selectedLettersStates = Array(repeating: false, count: numberOfPoints)
    }

    private func saveSolvedDate() {
        let today = getCurrentDate()
        userDefaults.set(today, forKey: solvedDateKey)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            isWordAlreadySolvedForToday = true
            isTextVisible = false
        }
    }

    private func checkIfWordSolvedToday() {
        let today = getCurrentDate()
        if let savedDate = userDefaults.string(forKey: solvedDateKey) {
            isWordAlreadySolvedForToday = (savedDate == today)
        } else {
            isWordAlreadySolvedForToday = false
        }
    }

    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
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
            WordDayView(viewModel: WordsDayViewModel(), isWordAlreadySolvedForToday: .constant(false))
        }
}
