import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query(sort: [SortDescriptor(\Word.localID)]) private var words: [Word]
    @Query private var progress: [WordProgress]
    @Query private var quizStats: [QuizStats]
    @Query private var groups: [GroupMeta]
    @Environment(\.horizontalSizeClass) var sizeClass

    private var totalWords: Int {
        StatsService.totalWords(words)
    }

    private var seenWords: Int {
        StatsService.seenWords(progress)
    }

    private var completedQuizzes: Int {
        StatsService.completedQuizzes(quizStats)
    }

    private var averageScore: Int {
        StatsService.averageQuizScore(quizStats)
    }

    private var trainingWords: Int {
        StatsService.studyingWordsCount(words: words, groups: groups)
    }

    private var learnedTrainingWords: Int {
        StatsService.learnedWordsCount(progress)
    }

    private var totalVerbs: Int {
        StatsService.totalVerbs()
    }

    private var seenVerbs: Int {
        StatsService.seenVerbsCount()
    }

    private var wordDayStreak: Int {
        StatsService.wordDayCurrentStreak()
    }

    private var completedWordDays: Int {
        StatsService.wordDayCompletedDaysCount()
    }

    private var statCards: [StatCard] {
        [
            StatCard(
                title: Texts.allWords,
                value: "\(totalWords)",
                icon: "text.book.closed.fill",
                tint: .greenUniversal
            ),
            StatCard(
                title: Texts.wordsSeen,
                value: "\(seenWords)",
                icon: "eye.fill",
                tint: .greenUniversal
            ),
            StatCard(
                title: Texts.quizzesCompleted,
                value: "\(completedQuizzes)",
                icon: "checkmark.seal.fill",
                tint: .greenUniversal
            ),
            StatCard(
                title: Texts.averagePercentage,
                value: "\(averageScore)%",
                icon: "chart.bar.fill",
                tint: .greenUniversal
            )
        ]
    }

    private var trainingCards: [StatCard] {
        [
            StatCard(
                title: Texts.wordsLearn,
                value: "\(trainingWords)",
                icon: "list.bullet.clipboard.fill",
                tint: .greenUniversal
            ),
            StatCard(
                title: Texts.wordsLearned,
                value: "\(learnedTrainingWords)",
                icon: "star.fill",
                tint: .greenUniversal
            )
        ]
    }

    private var verbCards: [StatCard] {
        [
            StatCard(
                title: Texts.totalVerbs,
                value: "\(totalVerbs)",
                icon: "textformat.123",
                tint: .greenUniversal
            ),
            StatCard(
                title: Texts.seenVerbs,
                value: "\(seenVerbs)",
                icon: "eye.fill",
                tint: .greenUniversal
            )
        ]
    }

    private var wordDayCards: [StatCard] {
        [
            StatCard(
                title: Texts.wordDayStreak,
                value: "\(wordDayStreak)",
                icon: "flame.fill",
                tint: .greenUniversal
            ),
            StatCard(
                title: Texts.wordDayCompleted,
                value: "\(completedWordDays)",
                icon: "calendar",
                tint: .greenUniversal
            )
        ]
    }

    private let grid = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color.grayDN
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(Texts.quiz)
                        .font(sizeClass == .regular ? .title : .title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blackDN)
                        .padding(.top, 8)

                    LazyVGrid(columns: grid, spacing: 16) {
                        ForEach(statCards) { card in
                            StatCardView(card: card)
                        }
                    }

                    Text(Texts.training)
                        .font(sizeClass == .regular ? .title : .title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blackDN)

                    LazyVGrid(columns: grid, spacing: 16) {
                        ForEach(trainingCards) { card in
                            StatCardView(card: card)
                        }
                    }

                    Text(Texts.verbs)
                        .font(sizeClass == .regular ? .title : .title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blackDN)

                    LazyVGrid(columns: grid, spacing: 16) {
                        ForEach(verbCards) { card in
                            StatCardView(card: card)
                        }
                    }

                    Text(Texts.wordDay)
                        .font(sizeClass == .regular ? .title : .title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blackDN)

                    LazyVGrid(columns: grid, spacing: 16) {
                        ForEach(wordDayCards) { card in
                            StatCardView(card: card)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.statistics)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

private struct StatCard: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let tint: Color
}

private struct StatCardView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    let card: StatCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: card.icon)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(card.tint.opacity(0.7))
                    .clipShape(Circle())

                Spacer()

                Text(card.value)
                    .font(sizeClass == .regular ? .title : .title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blackDN)
            }

            Text(card.title)
                .font(.headline)
                .foregroundColor(.blackDN.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 110, maxHeight: 130, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.whiteDN)
                .shadow(color: .grayUniversal.opacity(0.3), radius: 8, x: 2, y: 4)
        )
    }
}
