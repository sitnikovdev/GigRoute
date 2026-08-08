# Dependency Injection

## File

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

## Why no DI framework

For four modules and three services, a full DI framework (Swinject,
Needle, etc.) is more complexity than it's worth: their real value shows
up with dozens of services with branching dependencies and different
lifetimes (singleton/transient/scoped), while right now we have a flat
list of three services sharing the same lifetime — the whole app
session.

Instead, it's a plain `final class`, one instance of which is created
once in `SceneDelegate` and passed down to coordinators as an explicit
constructor parameter:

```
SceneDelegate
  → AppCoordinator(dependencies:)
    → TabBarCoordinator(dependencies:)
      → HomeCoordinator(dependencies:)
        → HomeViewModel(userService:, slotStateStore:)
```

## Rule: explicit passing, not `.shared`

Each coordinator receives the **whole** container, but only passes the
ViewModel what it actually needs — `HomeCoordinator` doesn't hand
`HomeViewModel` the entire `AppDependencyContainer`, it pulls out two
specific properties:

```swift
let viewModel = HomeViewModel(
    userService: dependencies.userService,
    slotStateStore: dependencies.slotStateStore
)
```

That way `HomeViewModel`'s initializer signature makes its dependencies
visible immediately — no need to dig into the class body to figure that
out. It also keeps test mocks honest: `HomeViewModelTests` builds
`HomeViewModel(userService: MockUserService(), slotStateStore: SlotStateStore())`
and knows exactly that nothing else will be required by the ViewModel.

For the same reason, services aren't declared as `static let shared` — a
static singleton can't be swapped for a mock in a test, because it can
be referenced from anywhere in the code, and all of those references
"see" the same instance regardless of the initializer.

## The exception: `SlotStateStore`

`SlotStateStore` is the only service where shared state is the whole
point (see `docs/state-management.md`, coming in M6): both
`HomeViewModel` and the future `OrdersViewModel` need to see the same
slot status. This is achieved not through a `.shared` singleton, but by
`AppDependencyContainer` creating **one** instance of `SlotStateStore`
and handing that same reference to everyone who needs it — sharing comes
from the container's lifetime, not from static access.

## Extension point

Once there are more than a dozen services and some start needing
different lifetimes (e.g. something per-screen rather than per-session)
— that's the signal to revisit this approach and possibly introduce
factory closures (`() -> SomeService`) instead of ready-made instances,
or a lightweight DI setup. Until then, the flat container keeps the code
readable without extra magic.
