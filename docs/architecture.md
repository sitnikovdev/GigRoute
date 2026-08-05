# Архитектура

Проект генерируется через [XcodeGen](https://github.com/yonaskolb/XcodeGen)
из `project.yml` — `.xcodeproj` не хранится в git, только исходники.
UI строится полностью кодом с помощью SnapKit — Storyboard и XIB не
используются.

## Структура папок

```
Sources/GigRoute/
├── App/                 — AppDelegate, SceneDelegate, Info.plist
├── Core/
│   ├── Coordinator/     — Coordinator-протокол, AppCoordinator, TabBarCoordinator
│   ├── Base/            — BaseViewController, BaseViewModel, Observable<T>
│   ├── Networking/      — NetworkService, Endpoint, NetworkError
│   ├── DI/               — AppDependencyContainer
│   └── Theme/           — дизайн-токены (цвета, шрифты) — расширяется в M5
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
  `Observable<T>`, ничего не знает про `UIKit`.
- **Coordinator** — вся навигация. ViewController не создаёт другие
  ViewController и не пушит их напрямую — только вызывает замыкание/делегат,
  который слушает Coordinator.
- **Core/DI** — `AppDependencyContainer` создаётся один раз в
  `SceneDelegate` и передаётся координаторам сверху вниз. Никаких синглтонов
  уровня `.shared` для сервисов с состоянием (кроме будущего
  `SlotStateStore` из M6 — он про общее состояние по назначению).

## Каждый модуль (таб) состоит из

```
Modules/<Name>/
├── <Name>Coordinator.swift
├── <Name>ViewModel.swift
└── <Name>ViewController.swift
```

По мере роста модуля (M1–M4) сюда добавляются `Models/`, `Views/` (кастомные
`UIView`-компоненты конкретного экрана) и `Cells/` при необходимости.
