import Foundation

final class NetworkService {
    private enum NetworkError: Error {
        case generalError
    }

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    handler(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300).contains(httpResponse.statusCode),
                      let data = data else {
                    handler(.failure(NetworkError.generalError))
                    return
                }
                handler(.success(data))
            }
        }
        task.resume()
    }
}
