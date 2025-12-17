import Foundation
import SwiftData

@MainActor
final class GroupsViewModel: ObservableObject {
    @Published var groups: [GroupMeta] = []
    @Published var correctWord: Word?
    @Published private(set) var isSynced: Bool = false

    private var words: [Word] = []
    private var currentRoundWords: [Word] = []

    private let store = VocabularyStore()
    private var syncTask: Task<Void, Never>?

    func syncAndLoadGroups(modelContext: ModelContext) async {
        if let syncTask { await syncTask.value; return }

        syncTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await self.store.sync(modelContext: modelContext)
                self.groups = try self.store.fetchGroups(modelContext: modelContext)
                self.isSynced = true
            } catch {
                do { self.groups = try self.store.fetchGroups(modelContext: modelContext) } catch {}
                print("Sync/load failed: \(error)")
            }
        }

        await syncTask?.value
        syncTask = nil
    }

    @discardableResult
    func prepareRound(modelContext: ModelContext, group: GroupMeta?, count: Int = 10) async -> Int {
        if !isSynced {
            await syncAndLoadGroups(modelContext: modelContext)
        }

        do {
            words = try store.fetchWords(modelContext: modelContext, groupID: group?.id)
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

    func nextGreekWord() -> String {
        guard let word = currentRoundWords.popLast() else {
            correctWord = nil
            return ""
        }
        correctWord = word
        return word.gr
    }

    func optionsForCurrentWord() -> [String] {
        guard let correct = correctWord else { return [] }
        var options: [Word] = [correct]

        let others = words
            .filter { $0.compositeID != correct.compositeID }
            .shuffled()
            .prefix(2)

        options.append(contentsOf: others)
        options.shuffle()
        return options.map { $0.en }
    }
}
