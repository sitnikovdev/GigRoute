# Настройка проекта (XcodeGen)

## Зачем

`.xcodeproj` — это XML-файл, который проще всего в мире конфликтует при
мёрже: два разработчика добавили по файлу в разные ветки — и вручную
разруливать конфликт в бинарном на вид XML то ещё удовольствие. Плюс он
никак не проверяется линтером/CI на корректность сам по себе.

Решение — не хранить `.xcodeproj` в git вообще. Вместо этого он
**генерируется** из декларативного `project.yml` через
[XcodeGen](https://github.com/yonaskolb/XcodeGen) прямо перед сборкой —
локально или на CI. Конфликт в `project.yml` — это конфликт в обычном YAML,
который разруливается как любой другой текстовый файл.

## Файл: `project.yml`

```yaml
name: GigRoute
options:
  bundleIdPrefix: com.gigroute
  deploymentTarget:
    iOS: "15.0"

packages:
  SnapKit:
    url: https://github.com/SnapKit/SnapKit
    from: 5.7.0

targets:
  GigRoute:
    type: application
    platform: iOS
    sources:
      - path: Sources/GigRoute
    dependencies:
      - package: SnapKit
    ...
```

Что тут происходит:

- **`options.deploymentTarget`** — минимальная iOS 15. Выбрана как разумный
  баланс между охватом устройств и доступом к современным API
  (`UIButton.Configuration`, `async/await` и т.д.), которые мы уже
  используем в `NetworkService` и `HomeViewModel`.
- **`packages.SnapKit`** — SPM-зависимость. XcodeGen сам пропишет её в
  сгенерированный проект; вручную через Xcode → Package Dependencies
  ничего добавлять не нужно, и она не потеряется при регенерации.
- **`targets.GigRoute.sources`** — единственный source root,
  `Sources/GigRoute`. XcodeGen сам построит структуру групп в Xcode 1:1 с
  структурой папок на диске — значит, папки в `Sources/GigRoute` и есть
  реальный источник правды об организации кода, а не что-то, что можно
  "переташить" в Xcode и забыть поправить на диске.
- **Отдельный таргет `GigRouteTests`** — юнит-тесты, с зависимостью на
  основной таргет `GigRoute` (для `@testable import GigRoute`).

## Почему без Storyboard/XIB

Все экраны собираются кодом (`UIViewController` + `SnapKit`). Причины:

1. **Мёрж-конфликты.** Storyboard — тот же XML, что и `.xcodeproj`, только
   ещё длиннее и с автогенерируемыми ID у каждого элемента. Два человека,
   тронувшие один экран в разных ветках — почти гарантированный ручной
   разбор XML.
2. **Ревью в PR.** Диff в Swift-файле читаем построчно. Диff в Storyboard —
   нет.
3. **Переиспользуемость.** Компонент, написанный кодом (см. `BaseViewController`,
   будущие `StatCardView` и т.д. из M5), тривиально переиспользовать между
   экранами. XIB для этого тоже подходит, но хуже интегрируется с
   Auto Layout, заданным целиком в коде через SnapKit.

## Как запустить локально

```bash
brew install xcodegen
xcodegen generate   # создаёт GigRoute.xcodeproj из project.yml
open GigRoute.xcodeproj
```

Любое изменение `project.yml` (новая зависимость, новый таргет) требует
повторного `xcodegen generate`. Сам `.xcodeproj` в `.gitignore` — то есть
после `git pull` с изменениями в `project.yml` нужно перегенерировать
проект заново.

## `.gitignore`

```
*.xcodeproj
*.xcworkspace
build/
DerivedData/
.build/
.swiftpm/
xcuserdata/
```

Игнорируется всё, что либо генерируется (`.xcodeproj`), либо является
локальным кэшем сборки (`DerivedData`, `.build`), либо специфично для
конкретной машины разработчика (`xcuserdata` — раскладка окон, breakpoints
и т.п. в Xcode).
