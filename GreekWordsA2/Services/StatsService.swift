import Foundation
import FSRS
import SwiftData

final class StatsService {
    private static let seenVerbIDsKey = "verb_seen_ids"
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
}
