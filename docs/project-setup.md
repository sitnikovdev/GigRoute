# Project Setup (XcodeGen)

## Why

`.xcodeproj` is an XML file that's about as merge-conflict-prone as it
gets: two developers add a file each on different branches, and
resolving the conflict in that binary-looking XML by hand is no fun.
Plus nothing lints or CI-checks it for correctness on its own.

The fix — don't store `.xcodeproj` in git at all. Instead it's
**generated** from a declarative `project.yml` via
[XcodeGen](https://github.com/yonaskolb/XcodeGen) right before building —
locally or in CI. A conflict in `project.yml` is a conflict in plain
YAML, resolved like any other text file.

## The `project.yml` file

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

What's happening here:

- **`options.deploymentTarget`** — minimum iOS 15. Chosen as a reasonable
  balance between device coverage and access to modern APIs
  (`UIButton.Configuration`, `async/await`, etc.), which we already use
  in `NetworkService` and `HomeViewModel`.
- **`packages.SnapKit`** — an SPM dependency. XcodeGen writes it into the
  generated project itself; nothing needs to be added manually via Xcode
  → Package Dependencies, and it won't get lost on regeneration.
- **`targets.GigRoute.sources`** — the single source root,
  `Sources/GigRoute`. XcodeGen builds Xcode's group structure 1:1 with
  the folder structure on disk — meaning the folders under
  `Sources/GigRoute` are the real source of truth for code organization,
  not something that can be "dragged around" in Xcode and forgotten on
  disk.
- **A separate `GigRouteTests` target** — unit tests, depending on the
  main `GigRoute` target (for `@testable import GigRoute`).

## Why no Storyboard/XIB

Every screen is assembled in code (`UIViewController` + `SnapKit`).
Reasons:

1. **Merge conflicts.** A Storyboard is the same kind of XML as
   `.xcodeproj`, just longer, with auto-generated IDs on every element.
   Two people touching the same screen on different branches is close to
   a guaranteed manual XML resolution.
2. **PR review.** A diff in a Swift file reads line by line. A diff in a
   Storyboard doesn't.
3. **Reusability.** A component written in code (see `BaseViewController`,
   the future `StatCardView` etc. from M5) is trivial to reuse across
   screens. XIB works for this too, but integrates worse with Auto
   Layout defined entirely in code via SnapKit.

## Running locally

```bash
brew install xcodegen
xcodegen generate   # creates GigRoute.xcodeproj from project.yml
open GigRoute.xcodeproj
```

Any change to `project.yml` (a new dependency, a new target) requires
running `xcodegen generate` again. `.xcodeproj` itself is in
`.gitignore` — so after a `git pull` that touches `project.yml`, the
project needs to be regenerated.

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

Everything ignored here is either generated (`.xcodeproj`), a local
build cache (`DerivedData`, `.build`), or specific to a particular
developer's machine (`xcuserdata` — window layout, breakpoints, etc. in
Xcode).
