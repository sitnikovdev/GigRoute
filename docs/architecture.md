# Architecture

The project is generated via [XcodeGen](https://github.com/yonaskolb/XcodeGen)
from `project.yml` — `.xcodeproj` isn't stored in git, only the sources are.
The UI is built entirely in code with SnapKit — no Storyboard or XIB is used.

This file is a top-level overview and an index into the detailed
documentation for each component. Details and the reasoning behind
decisions live in the linked files.

## Detailed component documentation

| Document | What it covers |
|---|---|
| [project-setup.md](project-setup.md) | XcodeGen, `project.yml`, SPM dependencies, why no Storyboard/XIB, `.gitignore` |
| [coordinator.md](coordinator.md) | The Coordinator pattern: protocol, the `AppCoordinator → TabBarCoordinator → *Coordinator` hierarchy, navigation rules |
| [mvvm.md](mvvm.md) | `Observable<T>`, `BaseViewModel`, `BaseViewController` — how they connect, why `setupViews`/`setupConstraints`/`bindViewModel` are separated |
| [networking.md](networking.md) | `Endpoint`, `NetworkError`, `NetworkService` — the contract, the `URLSession`-based implementation, mocking in tests |
| [dependency-injection.md](dependency-injection.md) | `AppDependencyContainer` — why no DI framework, how dependencies flow top-down |
| [theme.md](theme.md) | `AppColors` — flagged as a "temporary solution until M5" |
| [ci-and-quality.md](ci-and-quality.md) | `.swiftlint.yml` and `.github/workflows/ci.yml` — what's checked on every PR and why |

## Folder structure

```
Sources/GigRoute/
├── App/                 — AppDelegate, SceneDelegate, Info.plist
├── Core/
│   ├── Coordinator/     — Coordinator protocol, AppCoordinator, TabBarCoordinator
│   ├── Base/            — BaseViewController, BaseViewModel, Observable<T>
│   ├── Networking/      — NetworkService, Endpoint, NetworkError
│   ├── DI/              — AppDependencyContainer
│   ├── Theme/           — design tokens (colors) — expands in M5
│   ├── Models/          — data models shared across multiple modules (added in M1)
│   ├── Services/        — app-level services, e.g. UserService (added in M1)
│   └── State/           — state shared across tabs, e.g. SlotStateStore (added in M1, expands in M6)
├── Modules/
│   ├── Home/            — Coordinator + ViewModel + ViewController for the "Home" tab
│   ├── Orders/          — the "Orders" tab
│   ├── Messages/        — the "Messages" tab
│   └── Profile/         — the "Profile" tab
└── Common/               — reusable UI components (filled in during M5)

Tests/GigRouteTests/     — unit tests (XCTest)
```

## Layers and rules

- **View (UIViewController)** — UI and binding only. No business logic,
  no direct calls to `NetworkService`.
- **ViewModel** — all screen logic. Exposes state through `Observable<T>`,
  knows nothing about `UIKit` (this is specifically checked by the absence
  of `import UIKit` in ViewModel files — if it shows up there, logic has
  probably leaked into the wrong place).
- **Coordinator** — all navigation. A ViewController never creates another
  ViewController or pushes it directly — it only calls a closure/delegate
  that the Coordinator listens to.
- **Core/DI** — `AppDependencyContainer` is created once in `SceneDelegate`
  and passed down to coordinators top-down. No `.shared`-style singletons
  for stateful services (except `SlotStateStore` — it's meant to be shared
  state by design, see `dependency-injection.md`).

## Every module (tab) consists of

```
Modules/<Name>/
├── <Name>Coordinator.swift
├── <Name>ViewModel.swift
└── <Name>ViewController.swift
```

As a module grows (M1–M4), `Models/`, `Views/` (screen-specific custom
`UIView` components), and `Cells/` get added here as needed.
