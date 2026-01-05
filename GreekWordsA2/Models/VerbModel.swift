import Foundation

struct Verb: Codable {
    let id: Int
    let verb: String
    let enWords: String
    let ruWords: String
    let future: String
    let past: String

    enum CodingKeys: String, CodingKey {
        case id
        case verb
        case enWords = "translation"
        case ruWords = "ru_translation"
        case future
        case past
    }
}
