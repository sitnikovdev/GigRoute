# Networking

## Contents

`Sources/GigRoute/Core/Networking/`
- `Endpoint.swift` — describes a single request
- `NetworkError.swift` — typed errors
- `NetworkService.swift` — protocol + `URLSession`-based implementation

## Why a protocol instead of `URLSession` directly

ViewModels depend on the `NetworkService` protocol, not on the concrete
`URLSessionNetworkService`. That gives two practical benefits:

1. **Testability.** `Tests/GigRouteTests/MockNetworkService.swift` holds
   a test double that returns a pre-set `Result` instead of hitting the
   network — ViewModel tests are fast, deterministic, and need no
   internet/backend.
2. **Swapping the implementation without touching callers.** If, say,
   request logging or a different transport is needed later, only
   `URLSessionNetworkService` changes — ViewModels aren't touched at all.

## `Endpoint`

Describes a single request declaratively — path, method, query
parameters, body, headers — and can assemble a `URLRequest` from that:

```swift
struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let body: Data?
    let headers: [String: String]

    func makeRequest(baseURL: URL) -> URLRequest? { ... }
}
```

Concrete API endpoints get added as static factories on top of this type
once a real backend exists, e.g.:

```swift
extension Endpoint {
    static var currentUser: Endpoint {
        Endpoint(path: "/v1/me")
    }
}
```

As of M0 there are deliberately no such factories yet — `Endpoint` is
typed and ready, but the actual API paths haven't been agreed on yet.

## `NetworkError`

```swift
enum NetworkError: Error, Equatable {
    case invalidRequest
    case transport(String)
    case invalidResponse
    case httpStatus(Int)
    case decoding(String)
}
```

Splitting into five cases instead of one message string lets calling
code react differently: e.g. `httpStatus(401)` could later be caught
separately to log the user out, while `transport` (no network) could
show a "no connection" banner instead of a generic "something went
wrong" for every error alike.

## `NetworkService`

```swift
protocol NetworkService {
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async -> Result<T, NetworkError>
}
```

One universal generic method instead of a method per response type. A
call looks like this:

```swift
let result = await networkService.request(.currentUser, as: User.self)
switch result {
case .success(let user): ...
case .failure(let error): ...
}
```

The `URLSessionNetworkService` implementation:

- builds a `URLRequest` via `Endpoint.makeRequest`;
- makes the request through `URLSession.data(for:)` (async/await, no
  completion handlers and no third-party libraries like Alamofire —
  since iOS 15, `URLSession` supports `async` natively);
- checks the HTTP status (200..<300 — success, otherwise `.httpStatus`);
- decodes the body into `T` via `JSONDecoder`, wrapping decoding errors
  into `.decoding` with the original error text — this speeds up
  debugging a lot when models drift out of sync with the real API
  response.

## Mocking in tests

```swift
final class MockNetworkService: NetworkService {
    var result: Result<Any, NetworkError> = .failure(.invalidResponse)
    private(set) var requestedEndpoints: [Endpoint] = []

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async -> Result<T, NetworkError> {
        requestedEndpoints.append(endpoint)
        ...
    }
}
```

`requestedEndpoints` lets a test verify not just "what the service
returned" but also "which request the ViewModel actually made" — useful
when the ViewModel's own logic decides which `Endpoint` to hit (e.g.
different pagination depending on state).

## Where it's used right now

As of M0/M1 there's no real backend — `HomeViewModel` gets user data not
through `NetworkService` but through `UserService` (see `docs/mvvm.md`
and the `LocalUserService` code), which will switch to using
`NetworkService` internally in the future without changing its contract
for the ViewModel. `NetworkService` itself is already wired up in
`AppDependencyContainer` and ready to use as soon as the first real
endpoint exists.
