import SwiftUI
import SwiftData

struct QuizView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var greekWord: String = ""
    @State private var trWords: [String] = []
    @State private var selectedAnswer: String?
    @State private var isCorrect: Bool?
    @State private var isButtonDisabled: Bool = false
    @State private var currentQuestionIndex: Int = 0
    @State private var totalQuestions: Int = 10
    @State private var correctAnswersCount: Int = 0
    @State private var showAlert: Bool = false

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.locale) private var locale

    let group: GroupMeta?

    init(viewModel: GroupsViewModel, group: GroupMeta? = nil) {
        self.viewModel = viewModel
        self.group = group
    }

    private var width: CGFloat {
        sizeClass == .regular ? UIScreen.main.bounds.width - 280 : UIScreen.main.bounds.width - 120
    }

    private var isEnglish: Bool {
        Locale.preferredLanguages.first?.hasPrefix("en") == true
    }

    private var title: String {
        if let group {
            return isEnglish ? group.nameEn : group.nameRu
        } else {
            return isEnglish ? "Random words" : "Случайные слова"
        }
    }

    private var parsedWords: [String] {
        let splitWords = greekWord.components(separatedBy: ",")
        if splitWords.count == 1 {
            let separatedWords = greekWord.split(separator: " ")
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
                return [greekWord]
            }
        } else {
            return splitWords
        }
    }

    var body: some View {
        NavigationStack {
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

                    Spacer()

                    if trWords.count == 3 {
                        ForEach(0..<trWords.count, id: \.self) { index in
                            Text(trWords[index])
                                .foregroundColor(.blackDN)
                                .frame(width: width, height: sizeClass == .regular ? 80 : 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.whiteDN)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    selectedAnswer == trWords[index]
                                                    ? (isCorrect == true ? Color.green : Color.red)
                                                    : Color.clear,
                                                    lineWidth: 3
                                                )
                                        )
                                )
                                .cornerRadius(16)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                                .font(sizeClass == .regular ? .title : .title3)
                                .onTapGesture {
                                    if !isButtonDisabled {
                                        handleAnswerSelection(answer: trWords[index])
                                    }
                                }
                                .padding(.top, 5)
                        }
                    } else {
                        Text(trWords.isEmpty ? "Loading options..." : "Not enough options")
                    }

                    Spacer()
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
            }
        }
        .task(id: group?.id) {
            await startQuiz()
        }
        .onSwipeDismiss()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Quiz completed"),
                message: Text("Your result: \(correctAnswersCount)/\(max(totalQuestions, 1))"),
                primaryButton: .default(Text("Play again")) {
                    resetQuiz()
                },
                secondaryButton: .default(Text("Select group")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private func startQuiz() async {
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
            greekWord = "No words"
            trWords = []
        }
    }

    private func handleAnswerSelection(answer: String) {
        selectedAnswer = answer
        let correctText = isEnglish ? viewModel.correctWord?.en : viewModel.correctWord?.ru
        isCorrect = (correctText == selectedAnswer)
        if isCorrect == true { correctAnswersCount += 1 }
        isButtonDisabled = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            if currentQuestionIndex < totalQuestions - 1 {
                currentQuestionIndex += 1
                updateQuizContent()
                selectedAnswer = nil
                isCorrect = nil
                isButtonDisabled = false
            } else {
                showAlert = true
            }
        }
    }

    private func updateQuizContent() {
        greekWord = viewModel.nextGreekWord()
        trWords = viewModel.optionsForCurrentWord(using: locale)
    }

    private func resetQuiz() {
        Task { await startQuiz() }
    }
}

#Preview {
    QuizView(viewModel: GroupsViewModel())
        .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self], inMemory: true)
}
