import Foundation

class WordsDayViewModel: ObservableObject {
    @Published private(set) var dayOfMonth: Int = 0
    @Published var grWord: String = "example"
    @Published var enWord: String = ""
    private let wordService = WordService()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func setWordForCurrentDate() {
        let calendar = Calendar.current
        dayOfMonth = calendar.component(.day, from: Date())
        wordService.loadWordDay { result in
            switch result {
            case .success(let vocabularyWordDay):
                DispatchQueue.main.async { [self] in
                    let validIndex = max(0, min(self.dayOfMonth - 1, vocabularyWordDay.vocabulary.words.count - 1))
                    self.grWord = vocabularyWordDay.vocabulary.words[validIndex].gr
                    self.enWord = vocabularyWordDay.vocabulary.words[validIndex].en
                    updateLastPlayedDate()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    private func updateLastPlayedDate() {
        let today = getCurrentDate()
        UserDefaults.standard.set(today, forKey: "lastPlayedDate")
    }

   func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

class MockWordsDayViewModel: WordsDayViewModel {
    override init() {
        super.init()
        self.grWord = "example"
        self.enWord = "example"
    }
}
