# Base MVVM: Observable, BaseViewModel, BaseViewController

## Зачем свой Observable, а не Combine/RxSwift

`Observable<T>` — минимальная bindable-обёртка на ~15 строк, без внешних
зависимостей. На старте проекта, с четырьмя простыми экранами, полноценный
Combine/Rx — это лишний слой абстракции и лишняя кривая обучения. Интерфейс
у `Observable` предельно узкий (`value` + `bind`), поэтому его тривиально
заменить на `@Published`-обёртку над Combine, если сложность экранов
вырастет — код во ViewModel/ViewController менять почти не придётся.

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
        observer(value)  // файрит сразу текущим значением
    }
}
```

Важный момент: `bind` вызывает переданное замыкание **немедленно**, с уже
имеющимся значением. Это устраняет целый класс багов "экран показал
пустоту, пока не пришло первое обновление" — UI всегда видит актуальное
состояние сразу после подписки, а не только следующее изменение.

Ограничение (осознанное, на вырост): один `Observable` — один подписчик.
Для наших ViewModel этого достаточно (у каждого поля ровно один
`ViewController`-подписчик). Если понадобится multicast — это как раз
повод перейти на Combine, а не наращивать `Observable` вручную.

## `BaseViewModel`

`Sources/GigRoute/Core/Base/BaseViewModel.swift`

```swift
protocol BaseViewModel: AnyObject {
    func onViewDidLoad()
}
```

Единственное обязательство — точка входа, которую вызывает
`ViewController` при загрузке. Внутри `onViewDidLoad()` конкретная
ViewModel обычно подписывается на нужные stores/сервисы и инициирует
загрузку данных (см. `HomeViewModel.onViewDidLoad()` — подписка на
`SlotStateStore` + асинхронная загрузка пользователя).

Здесь же объявлен вспомогательный enum для состояния экрана:

```swift
enum ViewState<Content> {
    case idle
    case loading
    case loaded(Content)
    case error(String)
}
```

Использовать его не обязательно — ViewModel вправе объявлять собственные
`Observable`-поля вместо одного общего `state` (так, кстати, устроен
`HomeViewModel`: `greeting`, `slotButtonTitle`, `isOnSlot` — три отдельных
поля вместо одного `ViewState`, потому что у экрана несколько независимых
кусков состояния). `ViewState` пригождается там, где у экрана один
осмысленный "статус загрузки" целиком — как в текущих стабах Orders/
Messages/Profile.

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

Три override-точки — сознательно разделены, а не слиты в один
`viewDidLoad()`:

1. **`setupViews()`** — `addSubview`, конфигурация внешнего вида
   (`textColor`, `font`, `cornerRadius` и т.п.).
2. **`setupConstraints()`** — только `SnapKit`-констрейнты. Разделение
   "что добавили" и "как расположили" ускоряет чтение файла сверху вниз:
   сначала видно набор элементов экрана, потом — их геометрию.
3. **`bindViewModel()`** — подписки на `Observable`-поля ViewModel.

Конкретный `ViewController` переопределяет нужные методы и не трогает
`viewDidLoad()` вовсе (кроме единственного места, где вызывается
`viewModel.onViewDidLoad()` — см. пример ниже), либо вызывает
`super.viewDidLoad()` первым, если нужно что-то сделать раньше.

## Как это работает вместе — на примере `HomeViewController`

```swift
final class HomeViewController: BaseViewController {
    private let viewModel: HomeViewModel

    override func viewDidLoad() {
        super.viewDidLoad()          // 1. setupViews / setupConstraints / bindViewModel
        viewModel.onViewDidLoad()    // 2. ViewModel начинает работу — грузит юзера, подписывается на слот
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

Порядок важен: `bindViewModel()` вызывается из `super.viewDidLoad()`
**до** `viewModel.onViewDidLoad()` — то есть подписки уже готовы к
моменту, когда ViewModel начнёт публиковать значения. Если поменять
порядок местами, первые обновления (например, начальный `"Загрузка..."`)
будет некому поймать.

## Тестируемость

Так как ViewModel не знает про `UIKit` (никаких импортов `UIKit` в
`HomeViewModel.swift`), её можно тестировать без запуска симулятора —
достаточно `XCTest` + подписка на `Observable` напрямую, как в
`HomeViewModelTests`:

```swift
var titles: [String] = []
sut.slotButtonTitle.bind { titles.append($0) }

sut.onViewDidLoad()
sut.slotButtonTapped()

XCTAssertEqual(titles, ["Выйти на слот", "Уйти со слота"])
```
