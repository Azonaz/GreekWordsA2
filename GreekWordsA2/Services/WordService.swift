import Foundation

final class WordService {
    private let service = NetworkService()
    private var vocabulary: Vocabulary?
    private (set) var dictionaryUrl = "https://find-friends-team.ru/words-gr-a1.json"
    private (set) var wordsDayUrl = "https://find-friends-team.ru/words-gr-day.json"

    func loadVocabulary(url: URL, handler: @escaping (Result<Vocabulary, Error>) -> Void) {
        service.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let vocabulary = try JSONDecoder().decode(Vocabulary.self, from: data)
                    handler(.success(vocabulary))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    func loadWordDay(handler: @escaping (Result<VocabularyWordDay, Error>) -> Void) {
        guard let url = URL(string: wordsDayUrl) else {
                handler(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }
        service.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let vocabularyWordDay = try JSONDecoder().decode(VocabularyWordDay.self, from: data)
                    handler(.success(vocabularyWordDay))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    func getGroups(handler: @escaping (Result<[VocabularyGroup], Error>) -> Void) {
        loadVocabulary(url: URL(string: dictionaryUrl)!) { result in
            switch result {
            case .success(let vocabulary):
                handler(.success(vocabulary.vocabulary.groups))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    func getRandomWordsForAll(count: Int, completion: @escaping ([Word]) -> Void) {
        loadVocabulary(url: URL(string: dictionaryUrl)!) { result in
            switch result {
            case .success(let vocabulary):
                let allWords = vocabulary.vocabulary.groups.flatMap { $0.words }
                let randomWords = Array(allWords.shuffled().prefix(count))
                completion(randomWords)
            case .failure:
                completion([])
            }
        }
    }

    func getWords(for group: VocabularyGroup) -> [Word] {
        return group.words
    }

    func getRandomWords(for group: VocabularyGroup, count: Int) -> [Word] {
        let allWords = getWords(for: group)
        return Array(allWords.shuffled().prefix(count))
    }
}
