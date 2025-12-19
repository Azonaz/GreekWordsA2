import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query(sort: [SortDescriptor(\Word.localID)]) private var words: [Word]
    @Query private var progress: [WordProgress]
    @Query private var quizStats: [QuizStats]
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

    private var statCards: [StatCard] {
        [
            StatCard(
                title: "Всего слов",
                value: "\(totalWords)",
                icon: "text.book.closed.fill",
                tint: .greenUniversal
            ),
            StatCard(
                title: "Просмотрено",
                value: "\(seenWords)",
                icon: "eye.fill",
                tint: .greenUniversal
            ),
            StatCard(
                title: "Пройдено квизов",
                value: "\(completedQuizzes)",
                icon: "checkmark.seal.fill",
                tint: .greenUniversal
            ),
            StatCard(
                title: "Средний результат",
                value: "\(averageScore)%",
                icon: "chart.bar.fill",
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
                    Text("Quiz")
                        .font(sizeClass == .regular ? .largeTitle : .title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blackDN)
                        .padding(.top, 8)

                    LazyVGrid(columns: grid, spacing: 16) {
                        ForEach(statCards) { card in
                            StatCardView(card: card)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                Text("Statistics")
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onSwipeDismiss()
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
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.whiteDN)
                .shadow(color: .grayUniversal.opacity(0.3), radius: 8, x: 2, y: 4)
        )
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self, QuizStats.self], inMemory: true)
}
