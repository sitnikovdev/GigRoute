# Networking

## Состав

`Sources/GigRoute/Core/Networking/`
- `Endpoint.swift` — описание одного запроса
- `NetworkError.swift` — типизированные ошибки
- `NetworkService.swift` — протокол + `URLSession`-реализация

## Зачем протокол, а не сразу `URLSession`

ViewModel зависят от протокола `NetworkService`, а не от конкретного
`URLSessionNetworkService`. Это открывает два практических следствия:

1. **Тестируемость.** В `Tests/GigRouteTests/MockNetworkService.swift`
   лежит тестовый дубль, который отдаёт заранее заданный `Result` вместо
   похода в сеть — тесты ViewModel быстрые, детерминированные, не требуют
   интернета/бэкенда.
2. **Замена реализации без изменения вызывающего кода.** Если позже
   понадобится, например, добавить логирование запросов или переключиться
   на другой транспорт — меняется только `URLSessionNetworkService`,
   ViewModel не трогаются вообще.

## `Endpoint`

Описывает один запрос декларативно — путь, метод, query-параметры, тело,
заголовки — и умеет собрать из этого `URLRequest`:

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

Конкретные эндпоинты API оформляются как статические фабрики поверх этого
типа, когда появится реальный бэкенд, например:

```swift
extension Endpoint {
    static var currentUser: Endpoint {
        Endpoint(path: "/v1/me")
    }
}
```

На момент M0 таких фабрик нет намеренно — `Endpoint` типизирован и готов,
но конкретные пути API ещё не согласованы.

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

Разделение на пять кейсов вместо одной строки-сообщения даёт вызывающему
коду возможность реагировать по-разному: например, `httpStatus(401)` в
будущем можно поймать отдельно и разлогинить пользователя, а `transport`
(нет сети) — показать баннер "нет соединения" вместо общего "что-то пошло
не так".

## `NetworkService`

```swift
protocol NetworkService {
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async -> Result<T, NetworkError>
}
```

Один универсальный дженерик-метод вместо метода на каждый тип ответа.
Вызов выглядит так:

```swift
let result = await networkService.request(.currentUser, as: User.self)
switch result {
case .success(let user): ...
case .failure(let error): ...
}
```

Реализация `URLSessionNetworkService`:

- собирает `URLRequest` через `Endpoint.makeRequest`;
- делает запрос через `URLSession.data(for:)` (async/await, без
  completion-хендлеров и без сторонних библиотек вроде Alamofire — начиная
  с iOS 15 `URLSession` умеет `async` нативно);
- проверяет HTTP-статус (200..<300 — успех, иначе `.httpStatus`);
- декодирует тело в `T` через `JSONDecoder`, ошибку декодирования
  заворачивает в `.decoding` с исходным текстом ошибки — это сильно
  ускоряет отладку рассинхрона моделей с реальным ответом API.

## Мокирование в тестах

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

`requestedEndpoints` позволяет в тесте проверить не только "что вернул
сервис", но и "какой именно запрос сделала ViewModel" — полезно, когда
логика ViewModel сама решает, какой `Endpoint` дёрнуть (например, разная
пагинация в зависимости от состояния).

## Где сейчас используется

На момент M0/M1 реального бэкенда нет — `HomeViewModel` получает данные
пользователя не через `NetworkService`, а через `UserService`
(см. `docs/mvvm.md` и код `LocalUserService`), который в будущем
переключится на `NetworkService` внутри, ничего не меняя в контракте для
ViewModel. Сам `NetworkService` уже подключён в `AppDependencyContainer`
и готов к использованию, как только появится первый реальный эндпоинт.
