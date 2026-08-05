# GigRoute

iOS-приложение для курьеров: слоты, заказы, карта, статистика.

Стек: Swift, UIKit (UI только кодом, через SnapKit — без Storyboard/XIB),
MVVM, Coordinator.

## Структура

См. [docs/architecture.md](docs/architecture.md).

## Запуск проекта

Проект не хранит `.xcodeproj` в git — он генерируется через
[XcodeGen](https://github.com/yonaskolb/XcodeGen) из `project.yml`.

```bash
brew install xcodegen
xcodegen generate
open GigRoute.xcodeproj
```

SnapKit подключается автоматически как SPM-зависимость при генерации
проекта — руками в Xcode ничего добавлять не нужно.

## Разработка

См. [CONTRIBUTING.md](CONTRIBUTING.md) — конвенции веток, коммитов и PR.

## Требования

- Xcode 15+
- iOS 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [SwiftLint](https://github.com/realm/SwiftLint) (запускается локально и в CI)
