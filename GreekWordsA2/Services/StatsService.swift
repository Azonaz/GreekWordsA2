import Foundation
import FSRS
import SwiftData

final class StatsService {
    private static let seenVerbIDsKey = "verb_seen_ids"
    private static let wordDayHistoryKey = "word_day_history"
    private static let wordDayLastSolvedKey = "solvedDate"
    private static var cachedVerbs: [Verb]?

    static func verbsList() -> [Verb] {
        loadVerbs()
    }

    // Quiz stats
    static func totalWords(_ words: [Word]) -> Int {
        words.count
    }

    static func seenWords(_ progress: [WordProgress]) -> Int {
        progress.filter { $0.seen }.count
    }

    static func learnedWords(_ progress: [WordProgress]) -> Int {
        progress.filter { $0.learned }.count
    }

    static func completedQuizzes(_ stats: [QuizStats]) -> Int {
        stats.first?.completedCount ?? 0
    }

    static func averageQuizScore(_ stats: [QuizStats]) -> Int {
        Int(stats.first?.averageScore ?? 0)
    }

    static func recordQuizResult(score: Int, container: ModelContainer) async {
        let context = ModelContext(container)
        context.autosaveEnabled = false

        do {
            let descriptor = FetchDescriptor<QuizStats>()
            if let stats = try context.fetch(descriptor).first {
                stats.completedCount += 1
                stats.totalScore += score
            } else {
                let stats = QuizStats(completedCount: 1, totalScore: score)
                context.insert(stats)
            }

            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Failed to record quiz result: \(error)")
        }
    }

    // Training stats
    static func studyingWordsCount(words: [Word], groups: [GroupMeta]) -> Int {
        let openIDs = groups.filter { $0.opened }.map(\.id)
        return words.filter { openIDs.contains($0.groupID) }.count
    }

    static func learnedWordsCount(_ progress: [WordProgress]) -> Int {
        progress.filter { $0.learned }.count
    }

    // Verb stats
    static func totalVerbs() -> Int {
        verbsList().count
    }

    static func seenVerbsCount() -> Int {
        loadSeenVerbIDs().count
    }

    static func markVerbSeen(id: Int) {
        var ids = loadSeenVerbIDs()
        let inserted = ids.insert(id).inserted
        guard inserted else { return }
        UserDefaults.standard.set(Array(ids), forKey: seenVerbIDsKey)
    }

    private static func loadVerbs() -> [Verb] {
        if let cachedVerbs { return cachedVerbs }
        guard
            let url = Bundle.main.url(forResource: "verbs", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([Verb].self, from: data)
        else {
            return []
        }
        cachedVerbs = decoded
        return decoded
    }

    private static func loadSeenVerbIDs() -> Set<Int> {
        let storedIDs = UserDefaults.standard.array(forKey: seenVerbIDsKey) as? [Int] ?? []
        return Set(storedIDs)
    }

    // Word of the day stats
    static func recordWordDayCompletion(on date: Date = Date()) {
        let formatter = wordDayDateFormatter()
        let dateString = formatter.string(from: date)
        var dates = loadWordDayHistory()
        if !dates.contains(dateString) {
            dates.append(dateString)
            saveWordDayHistory(dates)
        }
        UserDefaults.standard.set(dateString, forKey: wordDayLastSolvedKey)
    }

    static func recordWordDayCompletion(dateString: String) {
        var dates = loadWordDayHistory()
        if !dates.contains(dateString) {
            dates.append(dateString)
            saveWordDayHistory(dates)
        }
        UserDefaults.standard.set(dateString, forKey: wordDayLastSolvedKey)
    }

    static func isWordDayCompleted(on date: Date = Date()) -> Bool {
        let formatter = wordDayDateFormatter()
        let dateString = formatter.string(from: date)
        return isWordDayCompleted(dateString: dateString)
    }

    static func isWordDayCompleted(dateString: String) -> Bool {
        let dates = Set(loadWordDayHistory())
        return dates.contains(dateString)
    }

    static func wordDayCompletedDaysCount() -> Int {
        Set(loadWordDayHistory()).count
    }

    static func wordDayCurrentStreak(asOf date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let formatter = wordDayDateFormatter()
        let completionDays = Set(
            loadWordDayHistory()
                .compactMap { formatter.date(from: $0) }
                .map { calendar.startOfDay(for: $0) }
        )

        var streak = 0
        var cursor = calendar.startOfDay(for: date)

        while completionDays.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return streak
    }

    private static func wordDayDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }

    private static func loadWordDayHistory() -> [String] {
        let defaults = UserDefaults.standard
        var dates = defaults.stringArray(forKey: wordDayHistoryKey) ?? []

        if let lastSolved = defaults.string(forKey: wordDayLastSolvedKey), !dates.contains(lastSolved) {
            dates.append(lastSolved)
            saveWordDayHistory(dates)
        }

        return dates
    }

    private static func saveWordDayHistory(_ dates: [String]) {
        let uniqueDates = Array(Set(dates)).sorted()
        UserDefaults.standard.set(uniqueDates, forKey: wordDayHistoryKey)
    }
}
