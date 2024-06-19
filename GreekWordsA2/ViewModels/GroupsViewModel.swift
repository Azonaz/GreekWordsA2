import Foundation

final class GroupsViewModel: ObservableObject {
    @Published var groups = [VocabularyGroup]()
    @Published var selectedIndexPath: IndexPath?
    @Published var selectedGroup: VocabularyGroup?
    @Published var words: [Word] = []
    var currentRoundWords: [Word] = []
    @Published var vocabulary: Vocabulary?
    @Published var correctWord: Word?
    private let wordService = WordService()

    func load() {
        wordService.getGroups { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    self.groups = groups
                case .failure(let error):
                    print("Failed to load groups: \(error)")
                }
            }
        }
    }

    func getWords(completion: @escaping () -> Void) {
        if let selectedGroup = selectedGroup {
            words = wordService.getWords(for: selectedGroup)
            currentRoundWords = wordService.getRandomWords(for: selectedGroup, count: 10)
            completion()
        } else {
            wordService.getRandomWordsForAll(count: 10) { randomWords in
                self.currentRoundWords = randomWords
                self.words = randomWords
                completion()
            }
        }
    }

    func setRandomWord() -> String {
        if let randomWord = currentRoundWords.popLast() {
            correctWord = randomWord
            return randomWord.gr
        } else {
            return ""
        }
    }

    func setRandomValuesForWord() -> [String] {
        guard let correctWord = correctWord?.gr else { return [] }
        var options = words.filter { $0.gr == correctWord }
        let remainingWords = words.filter { $0.gr != correctWord }
        options.append(contentsOf: remainingWords.shuffled().prefix(2))
        options.shuffle()
        return options.map { $0.en }
    }
}
