import Foundation
import SwiftData

enum QuizMode {
    case direct
    case reverse
}

@MainActor
final class GroupsViewModel: ObservableObject {
    @Published var correctWord: Word?

    private var words: [Word] = []
    private var currentRoundWords: [Word] = []

    @discardableResult
    func prepareRound(modelContext: ModelContext, group: GroupMeta?, count: Int = 10) async -> Int {
        do {
            words = try fetchWords(modelContext: modelContext, groupID: group?.id)
            let number = min(count, words.count)
            currentRoundWords = Array(words.shuffled().prefix(number))
            correctWord = nil
            return currentRoundWords.count
        } catch {
            words = []
            currentRoundWords = []
            correctWord = nil
            print("Prepare round failed: \(error)")
            return 0
        }
    }

    func nextWord(for mode: QuizMode, isEnglish: Bool) -> String {
        guard let word = currentRoundWords.popLast() else {
            correctWord = nil
            return ""
        }
        correctWord = word

        switch mode {
        case .direct:
            return word.gr
        case .reverse:
            return isEnglish ? word.en : word.ru
        }
    }

    func optionsForCurrentWord(using locale: Locale, mode: QuizMode) -> [String] {
        guard let correct = correctWord else { return [] }
        var options: [Word] = [correct]

        let others = words
            .filter { $0.compositeID != correct.compositeID }
            .shuffled()
            .prefix(2)

        options.append(contentsOf: others)
        options.shuffle()
        switch mode {
        case .direct:
            let isEnglish = locale.language.languageCode?.identifier.hasPrefix("en") == true
            return options.map { isEnglish ? $0.en : $0.ru }
        case .reverse:
            return options.map { $0.gr }
        }
    }
}

private extension GroupsViewModel {
    func fetchWords(modelContext: ModelContext, groupID: Int?) throws -> [Word] {
        if let groupID {
            return try modelContext.fetch(
                FetchDescriptor<Word>(
                    predicate: #Predicate { $0.groupID == groupID },
                    sortBy: [SortDescriptor(\.localID)]
                )
            )
        } else {
            return try modelContext.fetch(
                FetchDescriptor<Word>(
                    sortBy: [SortDescriptor(\.localID)]
                )
            )
        }
    }
}
