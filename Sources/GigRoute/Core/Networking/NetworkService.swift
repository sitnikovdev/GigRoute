import Foundation

protocol NetworkService {
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async -> Result<T, NetworkError>
}

/// URLSession-backed implementation. Modules depend on `NetworkService`
/// (the protocol), never on this type directly, so unit tests can inject
/// `MockNetworkService` instead.
final class URLSessionNetworkService: NetworkService {

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async -> Result<T, NetworkError> {
        guard let urlRequest = endpoint.makeRequest(baseURL: baseURL) else {
            return .failure(.invalidRequest)
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                return .failure(.httpStatus(httpResponse.statusCode))
            }

            do {
                let decoded = try decoder.decode(T.self, from: data)
                return .success(decoded)
            } catch {
                return .failure(.decoding(error.localizedDescription))
            }
        } catch {
            return .failure(.transport(error.localizedDescription))
        }
    }
}
