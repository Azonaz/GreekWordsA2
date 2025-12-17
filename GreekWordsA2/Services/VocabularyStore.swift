import Foundation
import SwiftData

@MainActor
final class VocabularyStore {
    private let service: WordService

    init(service: WordService = WordService()) {
        self.service = service
    }

    func sync(modelContext: ModelContext) async throws {
        let remoteGroups = try await service.fetchGroups()

        let existingMetas = try modelContext.fetch(FetchDescriptor<GroupMeta>())
        var metaByID: [Int: GroupMeta] = Dictionary(uniqueKeysWithValues: existingMetas.map { ($0.id, $0) })

        for rGroup in remoteGroups {
            let meta: GroupMeta
            let isNewMeta: Bool

            if let found = metaByID[rGroup.id] {
                meta = found
                isNewMeta = false
            } else {
                meta = GroupMeta(id: rGroup.id, version: -1, nameEn: rGroup.name.en, nameRu: rGroup.name.ru)
                modelContext.insert(meta)
                metaByID[rGroup.id] = meta
                isNewMeta = true
            }

            meta.nameEn = rGroup.name.en
            meta.nameRu = rGroup.name.ru

            let needsWordsUpdate = isNewMeta || meta.version != rGroup.version
            guard needsWordsUpdate else { continue }

            let oldWords = try modelContext.fetch(
                FetchDescriptor<Word>(predicate: #Predicate { $0.groupID == rGroup.id })
            )
            for word in oldWords { modelContext.delete(word) }

            for item in rGroup.words {
                let newWord = Word(localID: item.id, groupID: rGroup.id, gr: item.gr, en: item.en, ru: item.ru)
                modelContext.insert(newWord)

                let compositeID = newWord.compositeID
                if try modelContext.fetch(
                    FetchDescriptor<WordProgress>(predicate: #Predicate { $0.compositeID == compositeID })
                ).first == nil {
                    modelContext.insert(
                        WordProgress(
                            compositeID: compositeID,
                            learned: false,
                            correctAnswers: 0,
                            seen: false
                        )
                    )
                }
            }

            meta.version = rGroup.version
        }

        try modelContext.save()
    }
}

extension VocabularyStore {
    func fetchGroups(modelContext: ModelContext) throws -> [GroupMeta] {
        try modelContext.fetch(
            FetchDescriptor<GroupMeta>(
                sortBy: [SortDescriptor(\.id)]
            )
        )
    }

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
