import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable nesting
struct Vocabulary: Codable {
    let vocabulary: VocabularyData
}

struct VocabularyData: Codable {
    let groups: [VocabularyGroup]
}

struct VocabularyGroup: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let words: [Word]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.words = try container.decode([Word].self, forKey: .words)
    }

    static func == (lhs: VocabularyGroup, rhs: VocabularyGroup) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Word: Codable, Identifiable {
    let id: UUID
    let gr: String
    let en: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.gr = try container.decode(String.self, forKey: .gr)
        self.en = try container.decode(String.self, forKey: .en)
    }
}

struct VocabularyWordDay: Codable {
    let vocabulary: VocabularyData

    struct VocabularyData: Codable {
        let words: [Word]

        struct Word: Codable {
            let gr: String
            let en: String
        }
    }
}
// swiftlint:enable identifier_name
// swiftlint:enable nesting
