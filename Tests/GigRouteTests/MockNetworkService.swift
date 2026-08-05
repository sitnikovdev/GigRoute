import Foundation
@testable import GigRoute

/// Test double for `NetworkService`. Configure `result` before calling the
/// method under test.
final class MockNetworkService: NetworkService {
    var result: Result<Any, NetworkError> = .failure(.invalidResponse)
    private(set) var requestedEndpoints: [Endpoint] = []

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async -> Result<T, NetworkError> {
        requestedEndpoints.append(endpoint)
        switch result {
        case .success(let value):
            guard let typed = value as? T else { return .failure(.decoding("Type mismatch in mock")) }
            return .success(typed)
        case .failure(let error):
            return .failure(error)
        }
    }
}
