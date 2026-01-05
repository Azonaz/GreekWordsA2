import SwiftData
import FSRS
import Foundation

@Model
// swiftlint:disable identifier_name
final class Word {
    @Attribute(.unique) var compositeID: String
    var localID: Int
    var groupID: Int
    var gr: String
    var en: String
    var ru: String

    init(localID: Int, groupID: Int, gr: String, en: String, ru: String) {
        self.localID = localID
        self.groupID = groupID
        self.gr = gr
        self.en = en
        self.ru = ru
        self.compositeID = "\(groupID)_\(localID)"
    }
}
// swiftlint:enable identifier_name

@Model
final class GroupMeta {
    @Attribute(.unique) var id: Int
    var version: Int
    var nameEn: String
    var nameRu: String
    var opened: Bool = false

    init(id: Int, version: Int, nameEn: String, nameRu: String, opened: Bool = false) {
        self.id = id
        self.version = version
        self.nameEn = nameEn
        self.nameRu = nameRu
        self.opened = opened
    }
}

@Model
final class WordProgress {
    @Attribute(.unique) var compositeID: String
    // for migration
    var stateRaw: Int = CardState.new.rawValue

    var stability: Double = 0
    var difficulty: Double = 0
    var elapsedDays: Int = 0
    var scheduledDays: Int = 0
    var due: Date = Date.distantPast
    var lastReview: Date?
    var assignedDate: Date?
    var learned: Bool = false
    var correctAnswers: Int = 0
    var seen: Bool = false
    var lapses: Int = 0

    var state: CardState {
        get { CardState(rawValue: stateRaw) ?? .new }
        set { stateRaw = newValue.rawValue }
    }

    init(
        compositeID: String,
        learned: Bool = false,
        correctAnswers: Int = 0,
        seen: Bool = false
    ) {
        self.compositeID = compositeID
        self.learned = learned
        self.correctAnswers = correctAnswers
        self.seen = seen
    }
}

extension WordProgress {
    func apply(from next: WordProgress) {
        self.stability = next.stability
        self.difficulty = next.difficulty
        self.elapsedDays = next.elapsedDays
        self.scheduledDays = next.scheduledDays
        self.due = next.due
        self.state = next.state
        self.lastReview = next.lastReview
        self.assignedDate = next.assignedDate
        self.learned = next.learned
        self.correctAnswers = next.correctAnswers
        self.seen = next.seen
        self.lapses = next.lapses
    }
}
