# Base MVVM: Observable, BaseViewModel, BaseViewController

## Why a custom Observable instead of Combine/RxSwift

`Observable<T>` is a minimal bindable wrapper, ~15 lines, no external
dependencies. At the project's current stage, with four simple screens,
a full Combine/Rx setup is an extra layer of abstraction and an extra
learning curve. `Observable`'s interface is deliberately narrow (`value`
+ `bind`), so it's trivial to swap for a `@Published` wrapper over
Combine if screen complexity grows — ViewModel/ViewController code
barely needs to change.

## `Observable<T>`

`Sources/GigRoute/Core/Base/Observable.swift`

```swift
final class Observable<Value> {
    private var observer: ((Value) -> Void)?

    var value: Value {
        didSet { observer?(value) }
    }

    init(_ value: Value) {
        self.value = value
    }

    func bind(_ observer: @escaping (Value) -> Void) {
        self.observer = observer
        observer(value)  // fires immediately with the current value
    }
}
```

Important detail: `bind` calls the passed closure **immediately**, with
whatever value already exists. This eliminates a whole class of "the
screen showed an empty state until the first update arrived" bugs — the
UI always sees the current state right after subscribing, not just the
next change.

Limitation (deliberate, room to grow): one `Observable` supports one
subscriber. That's enough for our ViewModels (each field has exactly one
`ViewController` subscriber). If multicast is ever needed, that's the
signal to move to Combine rather than growing `Observable` by hand.

## `BaseViewModel`

`Sources/GigRoute/Core/Base/BaseViewModel.swift`

```swift
protocol BaseViewModel: AnyObject {
    func onViewDidLoad()
}
```

The only requirement is an entry point the `ViewController` calls on
load. Inside `onViewDidLoad()`, a concrete ViewModel typically subscribes
to the stores/services it needs and kicks off data loading (see
`HomeViewModel.onViewDidLoad()` — subscribing to `SlotStateStore` +
loading the user asynchronously).

A helper enum for screen state is declared alongside it:

```swift
enum ViewState<Content> {
    case idle
    case loading
    case loaded(Content)
    case error(String)
}
```

Using it isn't mandatory — a ViewModel is free to declare its own
`Observable` fields instead of one shared `state` (that's actually how
`HomeViewModel` is built: `greeting`, `slotButtonTitle`, `isOnSlot` — three
separate fields instead of one `ViewState`, because the screen has
several independent pieces of state). `ViewState` earns its keep where a
screen has a single, meaningful "loading status" as a whole — like the
current Orders/Messages/Profile stubs.

## `BaseViewController`

`Sources/GigRoute/Core/Base/BaseViewController.swift`

```swift
class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupViews()
        setupConstraints()
        bindViewModel()
    }

    func setupViews() {}
    func setupConstraints() {}
    func bindViewModel() {}
}
```

Three override points — deliberately kept separate rather than merged
into one `viewDidLoad()`:

1. **`setupViews()`** — `addSubview`, appearance configuration
   (`textColor`, `font`, `cornerRadius`, etc.).
2. **`setupConstraints()`** — SnapKit constraints only. Separating "what
   got added" from "how it's laid out" speeds up reading the file
   top-to-bottom: first you see the set of elements on screen, then their
   geometry.
3. **`bindViewModel()`** — subscriptions to the ViewModel's `Observable`
   fields.

A concrete `ViewController` overrides the methods it needs and doesn't
touch `viewDidLoad()` at all (except for the one place that calls
`viewModel.onViewDidLoad()` — see the example below), or calls
`super.viewDidLoad()` first if something needs to happen earlier.

## How it all fits together — the `HomeViewController` example

```swift
final class HomeViewController: BaseViewController {
    private let viewModel: HomeViewModel

    override func viewDidLoad() {
        super.viewDidLoad()          // 1. setupViews / setupConstraints / bindViewModel
        viewModel.onViewDidLoad()    // 2. ViewModel starts working — loads the user, subscribes to the slot
    }

    override func setupViews() {
        view.addSubview(greetingLabel)
        view.addSubview(slotButton)
    }

    override func setupConstraints() {
        greetingLabel.snp.makeConstraints { ... }
        slotButton.snp.makeConstraints { ... }
    }

    override func bindViewModel() {
        viewModel.greeting.bind { [weak self] text in
            self?.greetingLabel.text = text
        }
        viewModel.slotButtonTitle.bind { [weak self] title in
            self?.slotButton.configuration?.title = title
        }
    }
}
```

The order matters: `bindViewModel()` is called from `super.viewDidLoad()`
**before** `viewModel.onViewDidLoad()` — meaning subscriptions are
already in place by the time the ViewModel starts publishing values. If
the order were swapped, the first updates (e.g. the initial
`"Loading..."`) would have no one to catch them.

## Testability

Since a ViewModel knows nothing about `UIKit` (no `import UIKit` in
`HomeViewModel.swift`), its logic can be tested without launching the
simulator — plain `XCTest` plus subscribing to an `Observable` directly
is enough, as in `HomeViewModelTests`:

```swift
var titles: [String] = []
sut.slotButtonTitle.bind { titles.append($0) }

sut.onViewDidLoad()
sut.slotButtonTapped()

XCTAssertEqual(titles, ["Выйти на слот", "Уйти со слота"])
```
