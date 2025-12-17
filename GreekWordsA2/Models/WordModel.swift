// swiftlint:disable identifier_name
// swiftlint:disable nesting
struct VocabularyFile: Codable {
    let vocabulary: Vocabulary
}

struct Vocabulary: Codable {
    let groups: [WordGroup]
}

struct WordGroup: Codable {
    let id: Int
    let name: LocalizedString
    let version: Int
    let words: [WordItem]
}

struct LocalizedString: Codable {
    let en: String
    let ru: String
}

struct WordItem: Codable {
    let id: Int
    let gr: String
    let en: String
    let ru: String
}

struct VocabularyWordDay: Codable {
    let vocabulary: VocabularyData

    struct VocabularyData: Codable {
        let words: [WordDay]

        struct WordDay: Codable {
            let gr: String
            let en: String
            let ru: String?
        }
    }
}
// swiftlint:enable identifier_name
// swiftlint:enable nesting
