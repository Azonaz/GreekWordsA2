import SwiftUI

struct LetterItem: Identifiable, Equatable {
    let id = UUID()
    let character: Character
}

// swiftlint:disable identifier_name
struct WordDayView: View {
    @ObservedObject var viewModel: WordsDayViewModel
    @State private var word: [LetterItem] = []
    @State private var selectedPoints: [CGPoint] = []
    @State private var currentPoint: CGPoint?
    @State private var allCirclesSelected = false
    @State private var selectedLetters: [LetterItem] = []
    @State private var pathColor: Color = .grayDN
    @State var numberOfPoints: Int = 7
    @State private var selectedLettersStates: [Bool] = Array(repeating: false, count: 7)
    @State private var isTextVisible = false
    @Binding var isWordAlreadySolvedForToday: Bool
    @Environment(\.horizontalSizeClass) var sizeClass
    private let userDefaults = UserDefaults.standard
    private let solvedDateKey = "solvedDate"
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var radius: CGFloat {
        return sizeClass == .regular ? 150 : 100
    }
    private var paddingHorizontal: CGFloat {
        sizeClass == .regular ? 160 : 80
    }

    var body: some View {
        if isTextVisible {
            SelectedLettersView(selectedLetters: selectedLetters)
        }

        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let diameter = radius * 2.7
            let verticalPadding: CGFloat = sizeClass == .regular ? 100 : 60

            if !isWordAlreadySolvedForToday {
                ZStack {
                    createCircle(diameter: diameter,
                                 screenWidth: screenWidth,
                                 screenHeight: screenHeight,
                                 verticalPadding: verticalPadding)
                    if !selectedPoints.isEmpty {
                        createPath()
                    }
                    ForEach(0..<numberOfPoints, id: \.self) { index in
                        if index < word.count {
                            let angle = 2 * .pi / Double(numberOfPoints) * Double(index)
                            let x = screenWidth / 2 + radius * CGFloat(cos(angle))
                            let y = screenHeight - (diameter / 2) - verticalPadding + radius * CGFloat(sin(angle))
                            let point = CGPoint(x: x, y: y)

                            CharViewForGame(letter: word[index].character, isSelected: $selectedLettersStates[index])
                                .position(point)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .gesture(createDragGesture(screenWidth: screenWidth,
                                           screenHeight: screenHeight,
                                           verticalPadding: verticalPadding))
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
                createSolvedWordView(screenWidth: screenWidth, screenHeight: screenHeight)
            }
        }
    }

    struct SelectedLettersView: View {
        let selectedLetters: [LetterItem]

        var body: some View {
            Text(selectedLetters.map { String($0.character) }.joined())
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
    }

    private func createSolvedWordView(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        VStack {
            Text(viewModel.grWord)
                .foregroundColor(.blackDN)
                .font(sizeClass == .regular ? .largeTitle : .title)
                .padding(.bottom, sizeClass == .regular ? 20 : 10)

            Text(viewModel.enWord)
                .foregroundColor(.blackDN)
                .font(sizeClass == .regular ? .title2 : .title3)
        }
        .frame(height: 150)
        .padding(.horizontal, paddingHorizontal)
        .background(Color.whiteDN)
        .cornerRadius(16)
        .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
        .position(x: screenWidth / 2, y: screenHeight / 1.5)
    }

    private func createDragGesture(screenWidth: CGFloat, screenHeight: CGFloat,
                                   verticalPadding: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard !allCirclesSelected && !isWordAlreadySolvedForToday else { return }
                currentPoint = value.location
                let points = calculateLetterPositions(numberOfPoints: numberOfPoints,
                                                      screenWidth: screenWidth,
                                                      screenHeight: screenHeight,
                                                      radius: radius,
                                                      verticalPadding: verticalPadding)
                for (index, point) in points.enumerated() where distance(from: point, to: value.location) < 30 {
                    if selectedPoints.count >= 2 && selectedPoints[selectedPoints.count - 2] == point {
                        removeLastSelection()
                    } else if !selectedPoints.contains(point) {
                        selectedPoints.append(point)
                        selectedLetters.append(word[index])
                        selectedLettersStates[index] = true
                        isTextVisible = true
                        feedbackGenerator.impactOccurred()
                    }
                    break
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
    }

    private func createPath() -> some View {
        Path { path in
            path.addLines(selectedPoints)
            if let currentPoint = currentPoint {
                path.addLine(to: currentPoint)
            }
        }
        .stroke(pathColor, lineWidth: 2)
    }

    private func calculateLetterPositions(numberOfPoints: Int, screenWidth: CGFloat, screenHeight: CGFloat,
                                          radius: CGFloat, verticalPadding: CGFloat) -> [CGPoint] {
        (0..<numberOfPoints).map { index in
            let angle = 2 * .pi / Double(numberOfPoints) * Double(index)
            let x = screenWidth / 2 + radius * CGFloat(cos(angle))
            let y = screenHeight - ((radius * 2.7) / 2) - verticalPadding + radius * CGFloat(sin(angle))
            return CGPoint(x: x, y: y)
        }
    }

    private func createCircle(diameter: CGFloat, screenWidth: CGFloat, screenHeight: CGFloat,
                              verticalPadding: CGFloat) -> some View {
        Circle()
            .fill(Color.whiteDN)
            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
            .frame(width: diameter, height: diameter)
            .position(x: screenWidth / 2, y: screenHeight - (diameter / 2) - verticalPadding)
    }

    private func handleLetterTap(at index: Int, point: CGPoint) {
        let selectedLetter = word[index]
        if let selectedIndex = selectedLetters.firstIndex(where: { $0.id == selectedLetter.id }) {
            selectedPoints.removeAll { $0 == point }
            selectedLetters.remove(at: selectedIndex)
            selectedLettersStates[index] = false
            isTextVisible = !selectedLetters.isEmpty
        } else {
            selectedPoints.append(point)
            selectedLetters.append(selectedLetter)
            selectedLettersStates[index] = true
            isTextVisible = true
            feedbackGenerator.impactOccurred()
        }
    }

    private func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }

    private func checkSolution() {
        let words = viewModel.grWord.split(separator: " ")
        let targetWord = words.last ?? words.first ?? ""
        let selectedWord = selectedLetters.map { String($0.character) }.joined()
        if selectedWord == targetWord {
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

    private func removeLastSelection() {
        guard selectedPoints.last != nil else { return }
        selectedPoints.removeLast()
        let lastLetter = selectedLetters.removeLast()
        if let index = word.firstIndex(of: lastLetter) {
            selectedLettersStates[index] = false
        }
        if selectedLetters.isEmpty {
            isTextVisible = false
        }
    }

    private func updateWord(_ newValue: String) {
        let words = newValue.split(separator: " ")
        let targetWord = words.last ?? words.first ?? ""
        word = targetWord.map { LetterItem(character: $0) }
        word.shuffle()
        numberOfPoints = word.count
        selectedLettersStates = Array(repeating: false, count: numberOfPoints)
    }

    private func saveSolvedDate() {
        let today = viewModel.getCurrentDate()
        userDefaults.set(today, forKey: solvedDateKey)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            isWordAlreadySolvedForToday = true
            isTextVisible = false
        }
    }

    private func checkIfWordSolvedToday() {
        let today = viewModel.getCurrentDate()
        if let savedDate = userDefaults.string(forKey: solvedDateKey) {
            isWordAlreadySolvedForToday = (savedDate == today)
        } else {
            isWordAlreadySolvedForToday = false
        }
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
