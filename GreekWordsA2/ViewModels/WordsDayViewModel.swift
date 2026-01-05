import Foundation

@MainActor
class WordsDayViewModel: ObservableObject {
    @Published private(set) var dayOfMonth: Int = 0
    @Published var grWord: String = ""
    @Published var enWord: String = ""

    private let wordService = WordService()

    func setWordForCurrentDate() {
        dayOfMonth = Calendar.current.component(.day, from: Date())

        Task {
            do {
                let vocabularyWordDay = try await wordService.loadWordDay()

                let count = vocabularyWordDay.vocabulary.words.count
                guard count > 0 else { return }

                let index = max(0, min(dayOfMonth - 1, count - 1))
                grWord = vocabularyWordDay.vocabulary.words[index].gr
                enWord = vocabularyWordDay.vocabulary.words[index].en

                updateLastPlayedDate()
            } catch {
                print(error)
            }
        }
    }

    private func updateLastPlayedDate() {
        UserDefaults.standard.set(getCurrentDate(), forKey: "lastPlayedDate")
    }

    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

final class MockWordsDayViewModel: WordsDayViewModel {
    override init() {
        super.init()
        grWord = "example"
        enWord = "example"
    }
}
