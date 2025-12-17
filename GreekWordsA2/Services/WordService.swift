import Foundation

enum WordServiceError: Error {
    case invalidURL
    case decodingError(Error)
    case networkError(Error)
}

final class WordService {
    private let service: NetworkService
    private(set) var dictionaryUrl = "https://azonaz.github.io/words-gr-a2new.json"
    private(set) var wordsDayUrl = "https://azonaz.github.io/word-day-a2.json"

    init(service: NetworkService = NetworkService()) {
        self.service = service
    }

    private func fetchData(from url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { cont in
            service.fetch(url: url) { result in
                cont.resume(with: result)
            }
        }
    }

    func fetchGroups() async throws -> [WordGroup] {
        guard let url = URL(string: dictionaryUrl) else { throw WordServiceError.invalidURL }
        do {
            let data = try await fetchData(from: url)
            let file = try JSONDecoder().decode(VocabularyFile.self, from: data)
            return file.vocabulary.groups
        } catch let error as WordServiceError {
            throw error
        } catch let decoding as DecodingError {
            throw WordServiceError.decodingError(decoding)
        } catch {
            throw WordServiceError.networkError(error)
        }
    }

    func loadWordDay() async throws -> VocabularyWordDay {
        guard let url = URL(string: wordsDayUrl) else { throw WordServiceError.invalidURL }
        do {
            let data = try await fetchData(from: url)
            return try JSONDecoder().decode(VocabularyWordDay.self, from: data)
        } catch let decoding as DecodingError {
            throw WordServiceError.decodingError(decoding)
        } catch {
            throw WordServiceError.networkError(error)
        }
    }
}
