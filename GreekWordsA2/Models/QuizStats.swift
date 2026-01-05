import SwiftData

@Model
final class QuizStats {
    var completedCount: Int
    var totalScore: Int

    var averageScore: Double {
        Double(totalScore) / Double(max(completedCount, 1))
    }

    init(completedCount: Int = 0, totalScore: Int = 0) {
        self.completedCount = completedCount
        self.totalScore = totalScore
    }
}
