# GigRoute

iOS app for couriers: slots, orders, map, stats.

Stack: Swift, UIKit (UI built entirely in code via SnapKit — no Storyboard/XIB),
MVVM, Coordinator.

## Structure

See [docs/architecture.md](docs/architecture.md).

## Running the project

The project doesn't store `.xcodeproj` in git — it's generated via
[XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`.

```bash
brew install xcodegen
xcodegen generate
open GigRoute.xcodeproj
```

SnapKit is pulled in automatically as an SPM dependency when the project
is generated — nothing to add manually in Xcode.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) — branch, commit, and PR conventions.

## Requirements

- Xcode 15+
- iOS 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [SwiftLint](https://github.com/realm/SwiftLint) (runs locally and in CI)
