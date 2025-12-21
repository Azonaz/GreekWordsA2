import SwiftUI
import SwiftData

struct QuizView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var questionWord: String = ""
    @State private var options: [String] = []
    @State private var selectedAnswer: String?
    @State private var isCorrect: Bool?
    @State private var isButtonDisabled: Bool = false
    @State private var currentQuestionIndex: Int = 0
    @State private var totalQuestions: Int = 10
    @State private var correctAnswersCount: Int = 0
    @State private var showAlert: Bool = false
    @State private var isBlurActive: Bool = false

    @AppStorage("isBlurEnabled") private var isBlurEnabled = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.locale) private var locale

    let group: GroupMeta?
    let mode: QuizMode

    init(viewModel: GroupsViewModel, group: GroupMeta? = nil, mode: QuizMode = .direct) {
        self.viewModel = viewModel
        self.group = group
        self.mode = mode
    }

    private var width: CGFloat {
        sizeClass == .regular ? UIScreen.main.bounds.width - 280 : UIScreen.main.bounds.width - 120
    }

    private var isEnglish: Bool {
        locale.language.languageCode?.identifier.hasPrefix("en") == true
    }

    private var isReverse: Bool {
        mode == .reverse
    }

    private var title: String {
        if let group {
            return isEnglish ? group.nameEn : group.nameRu
        } else {
            if isReverse {
                return isEnglish ? "Reverse quiz" : "Обратный квиз"
            } else {
                return isEnglish ? "Random words" : "Случайные слова"
            }
        }
    }

    private var parsedWords: [String] {
        if isReverse { return [questionWord] }

        let splitWords = questionWord.components(separatedBy: ",")
        if splitWords.count == 1 {
            let separatedWords = questionWord.split(separator: " ")
            if separatedWords.count > 2 {
                if separatedWords[0].count > 2 {
                    let firstPart = String(separatedWords[0])
                    let secondPart = String(separatedWords[1])
                    let thirdPart = separatedWords.dropFirst(2).joined(separator: " ")
                    return [firstPart, secondPart, String(thirdPart)]
                } else {
                    let firstPart = separatedWords.prefix(2).joined(separator: " ")
                    let secondPart = separatedWords.dropFirst(2).joined(separator: " ")
                    return [String(firstPart), String(secondPart)]
                }
            } else {
                return [questionWord]
            }
        } else {
            return splitWords
        }
    }

    private var shouldBlurAnswers: Bool {
        isBlurEnabled && isBlurActive
    }

    private var isPhoneLandscape: Bool {
        UIDevice.current.userInterfaceIdiom == .phone && vSizeClass == .compact
    }

    private var landscapeWidth: CGFloat {
        UIScreen.main.bounds.width * 0.45
    }

    var body: some View {
        ZStack {
            Color.grayDN.edgesIgnoringSafeArea(.all)

            VStack {
                Text("\(currentQuestionIndex + 1)/\(max(totalQuestions, 1))")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(sizeClass == .regular
                          ? .system(size: 28, weight: .semibold)
                          : .system(size: 18, weight: .semibold))
                    .padding(.top, -10)
                    .padding(.trailing, sizeClass == .regular ? 40 : 20)

                Spacer()

                if isPhoneLandscape {
                    HStack(spacing: 20) {
                        questionCard(width: landscapeWidth)
                            .frame(maxHeight: .infinity, alignment: .center)

                        VStack(spacing: 12) {
                            answersSection(width: landscapeWidth)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 20)
                } else {
                    questionCard(width: width)

                    Spacer()

                    answersSection(width: width)
                }

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if shouldBlurAnswers {
                    isBlurActive = false
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .task(id: group?.id) {
            await startQuiz()
        }
        .onSwipeDismiss()
        .onChange(of: isBlurEnabled) { _, newValue in
            isBlurActive = newValue
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(Texts.result),
                message: Text("\(correctAnswersCount)/\(max(totalQuestions, 1))"),
                primaryButton: .default(Text(Texts.restart)) {
                    resetQuiz()
                },
                secondaryButton: .default(Text(Texts.back)) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

private extension QuizView {
    @ViewBuilder
    func questionCard(width: CGFloat) -> some View {
        VStack {
            ForEach(parsedWords, id: \.self) { word in
                Text(word)
                    .foregroundColor(.blackDN)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 1)
            }
        }
        .frame(width: width, height: sizeClass == .regular ? 180 : 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.whiteDN)
                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                .padding(.horizontal, 20)
        )
    }

    @ViewBuilder
    func answersSection(width: CGFloat) -> some View {
        if options.count == 3 {
            ForEach(0..<options.count, id: \.self) { index in
                answerButton(text: options[index], width: width, isFirst: index == 0)
            }
        } else {
            ProgressView()
        }
    }

    func answerButton(text: String, width: CGFloat, isFirst: Bool) -> some View {
        Text(text)
            .foregroundColor(.blackDN)
            .frame(width: width, height: sizeClass == .regular ? 80 : 60)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.whiteDN)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedAnswer == text
                                ? (isCorrect == true ? Color.green : Color.red)
                                : Color.clear,
                                lineWidth: 3
                            )
                    )
            )
            .cornerRadius(16)
            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
            .font(sizeClass == .regular ? .title : .title3)
            .blur(radius: shouldBlurAnswers ? 10 : 0)
            .allowsHitTesting(!shouldBlurAnswers)
            .onTapGesture {
                if !isButtonDisabled {
                    handleAnswerSelection(answer: text)
                }
            }
            .padding(.top, isFirst ? 0 : 5)
    }

    @MainActor
    func startQuiz() async {
        let roundCount = await viewModel.prepareRound(modelContext: modelContext, group: group, count: 10)

        totalQuestions = roundCount
        currentQuestionIndex = 0
        correctAnswersCount = 0
        selectedAnswer = nil
        isCorrect = nil
        isButtonDisabled = false
        showAlert = false

        if roundCount > 0 {
            updateQuizContent()
        } else {
            questionWord = "No words"
            options = []
        }
    }

    func handleAnswerSelection(answer: String) {
        selectedAnswer = answer
        let correctText = correctAnswer
        isCorrect = (correctText == selectedAnswer)
        if isCorrect == true { correctAnswersCount += 1 }
        isButtonDisabled = true
        viewModel.markCurrentWordAsSeen(modelContext: modelContext)

        let isLastQuestion = currentQuestionIndex >= totalQuestions - 1

        if isLastQuestion {
            let score = calculateScorePercent()
            recordQuizStats(scorePercent: score)
            showAlert = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                currentQuestionIndex += 1
                updateQuizContent()
                selectedAnswer = nil
                isCorrect = nil
                isButtonDisabled = false
            }
        }
    }

    func updateQuizContent() {
        questionWord = viewModel.nextWord(for: mode, isEnglish: isEnglish)
        options = viewModel.optionsForCurrentWord(using: locale, mode: mode)
        isBlurActive = isBlurEnabled
    }

    func resetQuiz() {
        Task { await startQuiz() }
    }

    var correctAnswer: String? {
        guard let correct = viewModel.correctWord else { return nil }

        switch mode {
        case .direct:
            return isEnglish ? correct.en : correct.ru
        case .reverse:
            return correct.gr
        }
    }

    func calculateScorePercent() -> Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(correctAnswersCount) / Double(totalQuestions)) * 100)
    }

    func recordQuizStats(scorePercent: Int) {
        let container = modelContext.container
        Task.detached(priority: .background) {
            await StatsService.recordQuizResult(score: scorePercent, container: container)
        }
    }
}
