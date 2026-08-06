# Dependency Injection

## Файл

`Sources/GigRoute/Core/DI/AppDependencyContainer.swift`

```swift
final class AppDependencyContainer {
    let networkService: NetworkService
    let userService: UserService
    let slotStateStore: SlotStateStore

    init() {
        let baseURL = URL(string: "https://api.gigroute.example.com")!
        self.networkService = URLSessionNetworkService(baseURL: baseURL)
        self.userService = LocalUserService()
        self.slotStateStore = SlotStateStore()
    }
}
```

## Почему без DI-фреймворка

На четыре модуля и три сервиса полноценный DI-фреймворк (Swinject,
Needle и т.п.) — избыточная сложность: их основная ценность раскрывается
на десятках сервисов с ветвящимися зависимостями и разными жизненными
циклами (singleton/transient/scoped), а сейчас у нас плоский список из
трёх сервисов с одним и тем же временем жизни — весь сеанс работы
приложения.

Вместо этого — обычный `final class`, один экземпляр которого создаётся
единожды в `SceneDelegate` и передаётся координаторам сверху вниз явным
параметром конструктора:

```
SceneDelegate
  → AppCoordinator(dependencies:)
    → TabBarCoordinator(dependencies:)
      → HomeCoordinator(dependencies:)
        → HomeViewModel(userService:, slotStateStore:)
```

## Правило: явная передача, а не `.shared`

Каждый координатор получает **весь** контейнер, но передаёт во ViewModel
только то, что ей реально нужно — `HomeCoordinator` не отдаёт
`HomeViewModel` весь `AppDependencyContainer`, а достаёт из него два
конкретных свойства:

```swift
let viewModel = HomeViewModel(
    userService: dependencies.userService,
    slotStateStore: dependencies.slotStateStore
)
```

Так у `HomeViewModel` в сигнатуре инициализатора сразу видно, от чего она
зависит — не нужно лезть внутрь тела класса, чтобы понять это. Это же
делает моки в тестах honest: `HomeViewModelTests` собирает
`HomeViewModel(userService: MockUserService(), slotStateStore: SlotStateStore())`
и точно знает, что больше ViewModel ничего не потребуется.

По той же причине сервисы не объявлены как `static let shared` —
статический синглтон нельзя подменить в тесте на мок, потому что на него
может быть множество ссылок по всему коду, и все они "видят" один и тот
же экземпляр в обход инициализатора.

## Исключение: `SlotStateStore`

`SlotStateStore` — единственный сервис, для которого разделяемое
состояние является частью его смысла (см. `docs/state-management.md`,
появится в M6): и `HomeViewModel`, и будущий `OrdersViewModel` должны
видеть один и тот же статус слота. Это достигается не через `.shared`
синглтон, а через то, что `AppDependencyContainer` создаёт **один**
экземпляр `SlotStateStore` и раздаёт эту же ссылку всем, кому она нужна —
разделяемость обеспечена временем жизни контейнера, а не статическим
доступом.

## Точка расширения

Когда сервисов станет больше десятка и начнут появляться сервисы с разным
временем жизни (например, что-то per-screen, а не на весь сеанс) — это
сигнал пересмотреть подход и, возможно, ввести фабричные замыкания
(`() -> SomeService`) вместо готовых экземпляров, либо облегчённый DI. До
этого момента плоский контейнер держит код читаемым без лишней магии.
