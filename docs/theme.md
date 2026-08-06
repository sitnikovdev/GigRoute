# Тема оформления

## Файл

`Sources/GigRoute/Core/Theme/AppColors.swift`

```swift
enum AppColors {
    static let background = UIColor.black
    static let cardBackground = UIColor(white: 0.11, alpha: 1)
    static let accent = UIColor.systemOrange
    static let primaryText = UIColor.white
    static let secondaryText = UIColor(white: 0.65, alpha: 1)
}
```

## Статус: временное решение, не полноценная дизайн-система

Пять цветовых токенов — ровно то, что понадобилось, чтобы `BaseViewController`
и стабы экранов уже сейчас выглядели в духе тёмной темы из референсных
скриншотов, не блокируя разработку M0/M1 ожиданием полноценной дизайн-
системы.

Осознанно НЕ входит сюда пока:
- шрифты как токены (используются inline `.systemFont(...)` во
  ViewController'ах);
- отступы/spacing-токены;
- варианты цвета для light/dark, если понадобится поддержка светлой темы;
- переиспользуемые компоненты (`StatCardView`, `NavigationRowCell` и т.п.)

Всё перечисленное — предмет **M5 (Design System)**. Когда M5 будет
реализован, `AppColors` либо разрастётся, либо будет поглощён более
широким модулем токенов (`AppTheme` с вложенными `Colors`/`Typography`/
`Spacing`) — в зависимости от того, что покажется читаемее на практике.

## Где используется сейчас

- `BaseViewController.viewDidLoad()` — `view.backgroundColor = AppColors.background`
  для каждого экрана автоматически;
- `TabBarCoordinator` — цвет таб-бара;
- ViewController'ы модулей — `textColor` лейблов.

## Правило на время до M5

Новый цвет, использованный больше одного раза в разных файлах — повод
добавить токен в `AppColors`, а не копировать `UIColor(white: 0.11, alpha: 1)`
по разным экранам. Один раз "по месту" — нормально, если это правда
разовый случай (например, точечная полупрозрачность оверлея).
