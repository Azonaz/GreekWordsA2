import SwiftUI
import SwiftData
import FSRS

extension TrainingView {
    func loadDueWords() async {
        do {
            let openIDs = try fetchOpenGroupIDs()
            guard !openIDs.isEmpty else {
                await MainActor.run { markNoGroups() }
                return
            }

            let wordsFromOpenGroups = try fetchWords(for: openIDs)
            var progresses = try fetchOrCreateProgress(for: wordsFromOpenGroups)

            let allowedIDs = Set(wordsFromOpenGroups.map(\.compositeID))
            progresses = progresses.filter { allowedIDs.contains($0.compositeID) }

            scheduler.trimAssignedNewWordsIfNeeded(progresses)
            let todaysProgresses = scheduler.wordsForToday(from: progresses)
            let counts = countsForToday(todaysProgresses)
            wordStates = statesDictionary(from: todaysProgresses)

            dueWords = todaysProgresses.compactMap { progress in
                wordsFromOpenGroups.first { $0.compositeID == progress.compositeID }
            }
            print("Words selected for today:", dueWords.count)

            await MainActor.run {
                updateUIAfterLoad(counts: counts)
            }
        } catch {
            print("Error loading data:", error)
        }
    }

    func handleRating(_ rating: Rating, for word: Word) async {
        do {
            guard let wordProgress = try context
                .fetch(FetchDescriptor<WordProgress>())
                .first(where: { $0.compositeID == word.compositeID })
            else {
                print("Error: Progress not found for", word.compositeID)
                return
            }

            let updated = scheduler.nextReview(for: wordProgress, rating: rating)
            wordProgress.apply(from: updated)
            try context.save()

            withAnimation {
                advance(after: rating, for: word)
            }

        } catch {
            print("Review error:", error)
        }
    }
}

private extension TrainingView {
    func fetchOpenGroupIDs() throws -> [Int] {
        let groups = try context.fetch(FetchDescriptor<GroupMeta>())
        let openIDs = groups.filter(\.opened).map(\.id)
        print("Open groups:", openIDs)
        return openIDs
    }

    func markNoGroups() {
        self.noGroups = true
        self.finished = false
        self.dueWords = []
    }

    func fetchWords(for openIDs: [Int]) throws -> [Word] {
        let allWords = try context.fetch(FetchDescriptor<Word>())
        let wordsFromOpenGroups = allWords.filter { openIDs.contains($0.groupID) }
        print("Words from open groups:", wordsFromOpenGroups.count)
        return wordsFromOpenGroups
    }

    func fetchOrCreateProgress(for words: [Word]) throws -> [WordProgress] {
        var progresses = try context.fetch(FetchDescriptor<WordProgress>())

        let allowedIDs = Set(words.map(\.compositeID))
        let existingIDs = Set(progresses.map(\.compositeID))
        let missingIDs = allowedIDs.subtracting(existingIDs)

        if !missingIDs.isEmpty {
            for word in words where missingIDs.contains(word.compositeID) {
                let progress = WordProgress(
                    compositeID: word.compositeID,
                    learned: false,
                    correctAnswers: 0,
                    seen: false
                )
                context.insert(progress)
            }

            try context.save()
            progresses = try context.fetch(FetchDescriptor<WordProgress>())
        }

        return progresses
    }

    struct DailyCounts {
        let new: Int
        let learning: Int
        let review: Int
    }

    func countsForToday(_ progresses: [WordProgress]) -> DailyCounts {
        DailyCounts(
            new: progresses.filter { $0.state == .new }.count,
            learning: progresses.filter { $0.state == .learning }.count,
            review: progresses.filter { $0.state == .review || $0.state == .relearning }.count
        )
    }

    func statesDictionary(from progresses: [WordProgress]) -> [String: ReviewState] {
        Dictionary(uniqueKeysWithValues: progresses.map { progress in
            let state: ReviewState = {
                switch progress.state {
                case .new:
                    return .new
                case .learning:
                    return .learning
                case .review, .relearning:
                    return .review
                }
            }()
            return (progress.compositeID, state)
        })
    }

    @MainActor
    func updateUIAfterLoad(counts: DailyCounts) {
        currentIndex = 0
        showTranslation = false
        finished = dueWords.isEmpty
        todayNew = counts.new
        todayLearning = counts.learning
        todayReview = counts.review
    }

    func advance(after rating: Rating, for word: Word) {
        if currentIndex + 1 < dueWords.count {
            currentIndex += 1
            showTranslation = false
        } else {
            finished = true
            trainingCount += 1
            if trainingCount == 5 {
                shouldShowRateButton = true
            }
        }

        if let state = wordStates[word.compositeID] {
            switch state {
            case .new:
                todayNew -= 1
            case .learning:
                todayLearning -= 1
            case .review:
                todayReview -= 1
            }
        }
    }
}
