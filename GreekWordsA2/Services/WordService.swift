import Foundation

enum WordServiceError: Error {
    case invalidURL
    case decodingError(Error)
    case networkError(Error)
}

final class WordService {
    private let service: NetworkService
    private var vocabulary: Vocabulary?
    private(set) var dictionaryUrl = "https://azonaz.github.io/words-gr-a2.json"
    private(set) var wordsDayUrl = "https://azonaz.github.io/word-day-a2.json"

    init(service: NetworkService = NetworkService()) {
        self.service = service
    }

    func loadVocabulary(url: URL, handler: @escaping (Result<Vocabulary, WordServiceError>) -> Void) {
        service.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let vocabulary = try JSONDecoder().decode(Vocabulary.self, from: data)
                    handler(.success(vocabulary))
                } catch {
                    handler(.failure(.decodingError(error)))
                }
            case .failure(let error):
                handler(.failure(.networkError(error)))
            }
        }
    }

    func loadWordDay(handler: @escaping (Result<VocabularyWordDay, WordServiceError>) -> Void) {
        guard let url = URL(string: wordsDayUrl) else {
            handler(.failure(.invalidURL))
            return
        }
        service.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let vocabularyWordDay = try JSONDecoder().decode(VocabularyWordDay.self, from: data)
                    handler(.success(vocabularyWordDay))
                } catch {
                    handler(.failure(.decodingError(error)))
                }
            case .failure(let error):
                handler(.failure(.networkError(error)))
            }
        }
    }

    func getGroups(handler: @escaping (Result<[VocabularyGroup], WordServiceError>) -> Void) {
        guard let url = URL(string: dictionaryUrl) else {
            handler(.failure(.invalidURL))
            return
        }
        loadVocabulary(url: url) { result in
            switch result {
            case .success(let vocabulary):
                handler(.success(vocabulary.vocabulary.groups))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    func getRandomWordsForAll(count: Int, completion: @escaping ([Word]) -> Void) {
        guard let url = URL(string: dictionaryUrl) else {
            completion([])
            return
        }
        loadVocabulary(url: url) { result in
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
