# Theme

## File

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

## Status: a temporary solution, not a full design system

Five color tokens — exactly what was needed so `BaseViewController` and
the screen stubs already look in the spirit of the dark theme from the
reference screenshots, without blocking M0/M1 development on waiting for
a full design system.

Deliberately NOT included here yet:
- fonts as tokens (used inline via `.systemFont(...)` in ViewControllers);
- padding/spacing tokens;
- color variants for light/dark, if light theme support is ever needed;
- reusable components (`StatCardView`, `NavigationRowCell`, etc.)

All of that is the subject of **M5 (Design System)**. Once M5 lands,
`AppColors` will either grow or get absorbed into a broader token module
(`AppTheme` with nested `Colors`/`Typography`/`Spacing`) — whichever
turns out more readable in practice.

## Where it's used right now

- `BaseViewController.viewDidLoad()` — `view.backgroundColor = AppColors.background`
  automatically for every screen;
- `TabBarCoordinator` — the tab bar's color;
- module ViewControllers — label `textColor`.

## The rule until M5

A new color used more than once across different files is a reason to
add a token to `AppColors`, rather than copy-pasting
`UIColor(white: 0.11, alpha: 1)` across screens. Using a color inline
once is fine if it's genuinely a one-off (e.g. a one-time overlay
opacity).
