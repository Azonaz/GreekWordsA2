import SwiftUI
import SwiftData
import FSRS

enum ReviewState {
    case new
    case learning
    case review
}

struct TrainingView: View {
    @Environment(\.modelContext) var context
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.verticalSizeClass) var vSizeClass

    @State var isEnglish: Bool = Locale.preferredLanguages.first?.hasPrefix("en") == true
    @State var dueWords: [Word] = []
    @State var currentIndex = 0
    @State var showTranslation = false
    @State var finished = false
    @State var noGroups = false
    @State var todayNew = 0
    @State var todayReview = 0
    @State var todayLearning = 0
    @State var wordStates: [String: ReviewState] = [:]

    @AppStorage("trainingCount") var trainingCount = 0
    @AppStorage("shouldShowRateButton") var shouldShowRateButton = false

    var todayTotal: Int {
        max(dueWords.count - currentIndex, 0)
    }

    var buttonHeight: CGFloat {
        sizeClass == .regular ? 90 : 70
    }

    var cornerRadius: CGFloat {
        sizeClass == .regular ? 20 : 16
    }

    var isPhoneLandscape: Bool {
        UIDevice.current.userInterfaceIdiom == .phone && vSizeClass == .compact
    }

    let scheduler = TrainingScheduler()

    var body: some View {
        ZStack {
            Color.grayDN.edgesIgnoringSafeArea(.all)

            VStack {
                if noGroups {
                    Text(Texts.noOpenGroups)
                        .foregroundColor(.blackDN)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.whiteDN)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                        )
                        .padding(.horizontal, 16)
                } else if finished {
                    Text(Texts.wordsDone)
                        .foregroundColor(.blackDN)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.whiteDN)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                        )
                        .padding(.horizontal, 16)
                } else if currentIndex < dueWords.count {
                    let word = dueWords[currentIndex]

                    if isPhoneLandscape {
                        landscapePhoneLayout(word)
                    } else {
                        portraitLayout(word)
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            await loadDueWords()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                Text(Texts.training)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
