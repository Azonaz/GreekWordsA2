import Foundation
import FSRS
import SwiftData

final class TrainingScheduler {
    private let fsrs = FSRS(
        parameters: FSRSParameters(
            requestRetention: 0.9,
            enableFuzz: false,
            enableShortTerm: true
        )
    )

    private var dailyNewWordsLimit: Int {
        let value = UserDefaults.standard.integer(forKey: "dailyNewWordsLimit")
        return value > 0 ? value : 20
    }

    /// Selects the words to be displayed today:
    /// - new (state == .new)
    /// - words whose repetition period has come (due <= now)
    /// - limits the number of new
    func wordsForToday(from all: [WordProgress]) -> [WordProgress] {
        // Read user setting for daily limit of new words
        let newLimit = dailyNewWordsLimit
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        // All words that were ever designated as “new” today
        let assignedToday = all.filter { progress in
            if let assigned = progress.assignedDate {
                return calendar.isDate(assigned, inSameDayAs: today)
            }
            return false
        }

        // How many words have been entered today (doesn't matter if new/learning/review)
        let assignedTodayCount = assignedToday.count

        // New words specifically from today's set,
        // which are still in the .new state (they need to be displayed)
        var todaysNewWords = assignedToday.filter { $0.state == .new }

        // If the limit has not yet been selected, you can add more new ones.
        if assignedTodayCount < newLimit {
            let remainingSlots = newLimit - assignedTodayCount

            // Candidates: words .new that were not assigned today
            let candidateNewWords = all.filter { progress in
                guard progress.state == .new else { return false }

                if let assigned = progress.assignedDate {
                    // already scheduled, but on a different day — can be reused as “postponed”
                    return !calendar.isDate(assigned, inSameDayAs: today)
                } else {
                    // never appointed — new candidate
                    return true
                }
            }

            let newlyAssigned = Array(candidateNewWords.prefix(remainingSlots))

            // Mark them as assigned today
            newlyAssigned.forEach { progress in
                progress.assignedDate = today
            }

            // Adding to today's new additions
            todaysNewWords.append(contentsOf: newlyAssigned)
        }

        // Repetitions according to schedule FSRS
        let dueWords = all.filter { progress in
            if progress.state == .learning { return true }
            return progress.state != .new && progress.due <= now
        }

        return todaysNewWords + dueWords
    }

    func trimAssignedNewWordsIfNeeded(_ progresses: [WordProgress]) {
        let limit = dailyNewWordsLimit
        let now = Date()
        let today = Calendar.current.startOfDay(for: now)

        let assignedToday = progresses.filter { progress in
            if let date = progress.assignedDate {
                return Calendar.current.isDate(date, inSameDayAs: today)
            }
            return false
        }

        let newAssigned = assignedToday.filter { $0.state == .new }

        if newAssigned.count > limit {
            let extra = newAssigned.count - limit
            for progress in newAssigned.suffix(extra) {
                progress.assignedDate = nil
            }
        }
    }

    /// FSRS-correct calculation of the next state
    func nextReview(for progress: WordProgress, rating: Rating) -> WordProgress {
        let now = Date()

        // lastReview should be stored in the WordProgress model
        // If it doesn't exist, we create it from the past due (fallback).
        let lastReview = progress.lastReview ?? (progress.state == .new ? nil : progress.due)

        let card = Card(
            due: progress.due,
            stability: progress.stability,
            difficulty: progress.difficulty,
            elapsedDays: Double(progress.elapsedDays),
            scheduledDays: Double(progress.scheduledDays),
            reps: progress.correctAnswers,
            lapses: progress.lapses,
            state: progress.state,
            lastReview: lastReview
        )

        var nextCard: Card
        do {
            let result = try fsrs.next(card: card, now: now, grade: rating)
            nextCard = result.card
        } catch {
            print("FSRS error:", error)
            return progress
        }

        let updated = WordProgress(
            compositeID: progress.compositeID,
            learned: (nextCard.state == .review),
            correctAnswers: nextCard.reps,
            seen: true
        )

        updated.stability = nextCard.stability
        updated.difficulty = nextCard.difficulty
        updated.elapsedDays = Int(nextCard.elapsedDays)
        updated.scheduledDays = Int(nextCard.scheduledDays)
        updated.due = nextCard.due
        updated.state = nextCard.state
        updated.lastReview = nextCard.lastReview
        updated.lapses = nextCard.lapses
        updated.assignedDate = progress.assignedDate

        return updated
    }
}
