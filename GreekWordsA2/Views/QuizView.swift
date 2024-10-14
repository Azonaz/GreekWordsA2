import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @State private var greekWord: String = ""
    @State private var enWords: [String] = []
    @State private var selectedAnswer: String?
    @State private var isCorrect: Bool?
    @State private var isButtonDisabled: Bool = false
    @State private var currentQuestionIndex: Int = 0
    @State private var totalQuestions: Int = 10
    @State private var correctAnswersCount: Int = 0
    @State private var showAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var sizeClass
    let group: VocabularyGroup?
    var width: CGFloat {
        sizeClass == .regular ? UIScreen.main.bounds.width - 280 : UIScreen.main.bounds.width - 120
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("\(currentQuestionIndex + 1)/\(totalQuestions)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(sizeClass == .regular ? .system(size: 28, weight: .semibold) : .system(size: 18, weight: .semibold))
                        .padding(.top, -10)
                        .padding(.trailing, sizeClass == .regular ? 40 : 20)
                    Spacer()
                    Text(greekWord)
                        .foregroundColor(.blackDN)
                        .font(sizeClass == .regular ? .largeTitle : .title2)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.whiteDN)
                                .frame(width: width, height: sizeClass == .regular ? 180 : 150)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                                .padding(.horizontal, 20)
                        )
                    Spacer()
                    if enWords.count == 3 {
                        ForEach(0..<enWords.count, id: \.self) { index in
                            Text(enWords[index])
                                .foregroundColor(.blackDN)
                                .frame(width: width, height: sizeClass == .regular ? 80 : 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.whiteDN)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedAnswer == enWords[index] ?
                                                        (isCorrect == true ? Color.green : Color.red) :
                                                            Color.clear, lineWidth: 3)
                                        )
                                )
                                .cornerRadius(16)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                                .font(sizeClass == .regular ? .title : .title3)
                                .onTapGesture {
                                    if !isButtonDisabled {
                                        handleAnswerSelection(answer: enWords[index])
                                    }
                                }
                                .padding(.top, 5)
                        }
                    } else {
                        Text("Loading options...")
                    }
                    Spacer()
                }
                .navigationTitle(group?.name ?? "Random words")
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: BackButton())
            }
        }
        .onAppear {
            viewModel.getWords {
                updateQuizContent()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Quiz сompleted"),
                message: Text("Your result: \(correctAnswersCount)/\(totalQuestions)"),
                primaryButton: .default(Text("Play again")) {
                    resetQuiz()
                },
                secondaryButton: .default(Text("Select group")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private func handleAnswerSelection(answer: String) {
        selectedAnswer = answer
        isCorrect = (viewModel.correctWord?.en == selectedAnswer)
        if isCorrect == true {
            correctAnswersCount += 1
        }
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
        greekWord = viewModel.setRandomWord()
        enWords = viewModel.setRandomValuesForWord()
    }

    private func resetQuiz() {
        correctAnswersCount = 0
        currentQuestionIndex = 0
        viewModel.getWords {
            updateQuizContent()
        }
        selectedAnswer = nil
        isCorrect = nil
        isButtonDisabled = false
    }
}

#Preview {
    QuizView(viewModel: GroupsViewModel(), group: nil)
}
