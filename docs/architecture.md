# Архитектура

Проект генерируется через [XcodeGen](https://github.com/yonaskolb/XcodeGen)
из `project.yml` — `.xcodeproj` не хранится в git, только исходники.
UI строится полностью кодом с помощью SnapKit — Storyboard и XIB не
используются.

Этот файл — обзор верхнего уровня и указатель на подробную документацию
по каждому компоненту. Детали и обоснования решений — в связанных файлах.

## Подробная документация по компонентам

| Документ | О чём |
|---|---|
| [project-setup.md](project-setup.md) | XcodeGen, `project.yml`, SPM-зависимости, почему без Storyboard/XIB, `.gitignore` |
| [coordinator.md](coordinator.md) | Coordinator-паттерн: протокол, иерархия `AppCoordinator → TabBarCoordinator → *Coordinator`, правила навигации |
| [mvvm.md](mvvm.md) | `Observable<T>`, `BaseViewModel`, `BaseViewController` — как связаны, зачем разделены `setupViews`/`setupConstraints`/`bindViewModel` |
| [networking.md](networking.md) | `Endpoint`, `NetworkError`, `NetworkService` — контракт, реализация на `URLSession`, мокирование в тестах |
| [dependency-injection.md](dependency-injection.md) | `AppDependencyContainer` — почему без DI-фреймворка, как зависимости передаются сверху вниз |
| [theme.md](theme.md) | `AppColors` — статус "временное решение до M5" |
| [ci-and-quality.md](ci-and-quality.md) | `.swiftlint.yml` и `.github/workflows/ci.yml` — что и почему проверяется на каждый PR |

## Структура папок

```
Sources/GigRoute/
├── App/                 — AppDelegate, SceneDelegate, Info.plist
├── Core/
│   ├── Coordinator/     — Coordinator-протокол, AppCoordinator, TabBarCoordinator
│   ├── Base/            — BaseViewController, BaseViewModel, Observable<T>
│   ├── Networking/      — NetworkService, Endpoint, NetworkError
│   ├── DI/              — AppDependencyContainer
│   ├── Theme/           — дизайн-токены (цвета) — расширяется в M5
│   ├── Models/          — модели данных, общие для нескольких модулей (добавлено в M1)
│   ├── Services/        — сервисы уровня приложения, напр. UserService (добавлено в M1)
│   └── State/           — общее состояние между табами, напр. SlotStateStore (добавлено в M1, расширится в M6)
├── Modules/
│   ├── Home/            — Coordinator + ViewModel + ViewController таба "Главная"
│   ├── Orders/          — таб "Заказы"
│   ├── Messages/        — таб "Сообщения"
│   └── Profile/         — таб "Профиль"
└── Common/               — переиспользуемые UI-компоненты (заполняется в M5)

Tests/GigRouteTests/     — unit-тесты (XCTest)
```

## Слои и правила

- **View (UIViewController)** — только UI и биндинг. Никакой бизнес-логики,
  никаких прямых обращений к `NetworkService`.
- **ViewModel** — вся логика экрана. Экспонирует состояние через
  `Observable<T>`, ничего не знает про `UIKit` (это специально проверяется
  отсутствием `import UIKit` в файлах ViewModel — если он там появился,
  вероятно, логика не туда закралась).
- **Coordinator** — вся навигация. ViewController не создаёт другие
  ViewController и не пушит их напрямую — только вызывает замыкание/делегат,
  который слушает Coordinator.
- **Core/DI** — `AppDependencyContainer` создаётся один раз в
  `SceneDelegate` и передаётся координаторам сверху вниз. Никаких синглтонов
  уровня `.shared` для сервисов с состоянием (кроме `SlotStateStore` — он
  про общее состояние по назначению, см. `dependency-injection.md`).

## Каждый модуль (таб) состоит из

```
Modules/<Name>/
├── <Name>Coordinator.swift
├── <Name>ViewModel.swift
└── <Name>ViewController.swift
```

По мере роста модуля (M1–M4) сюда добавляются `Models/`, `Views/` (кастомные
`UIView`-компоненты конкретного экрана) и `Cells/` при необходимости.
