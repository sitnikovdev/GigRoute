# CI and Code Quality

## SwiftLint — `.swiftlint.yml`

The rules are split into three groups:

```yaml
opt_in_rules:
  - closure_spacing
  - empty_count
  - explicit_init
  - fatal_error_message
  - force_unwrapping
  - redundant_nil_coalescing
  - unneeded_parentheses_in_closure_argument
  - vertical_whitespace_closing_braces
```
Rules SwiftLint doesn't enable by default but we explicitly want — the
most important of these in practice is **`force_unwrapping`**: it bans
`!` without an explicit justification. One current exception is
`URL(string: "...")!` in `AppDependencyContainer` for the hardcoded
placeholder URL; once that gets real configuration from
`.xcconfig`/environment, the force-unwrap will go away along with the
hardcoding.

```yaml
disabled_rules:
  - todo
```
`// TODO:` isn't treated as a warning — during active development
they're inevitable and useful as markers, and linter spam about them
just gets in the way.

```yaml
line_length:
  warning: 120
  error: 160

function_body_length:
  warning: 60
  error: 100

type_body_length:
  warning: 300
  error: 400
```
"Soft warning / hard error" thresholds — going over the error threshold
fails `swiftlint lint --strict` and, in turn, CI. The numbers aren't
dogma — if a specific case genuinely needs to exceed the limit, we
discuss it and move the threshold in a PR, rather than disabling the
rule locally via `// swiftlint:disable` without a comment explaining why.

## GitHub Actions — `.github/workflows/ci.yml`

```yaml
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
```
Runs on every PR into `main` and on every push to `main` (i.e. on the PR
itself, and again after merge — so `main` is also guaranteed to stay
green).

```yaml
runs-on: macos-26
```
A GitHub-hosted macOS runner — building iOS is only possible on macOS in
the first place (an Xcode toolchain is required). `macos-26` is the
current image as of now; GitHub periodically updates and deprecates
runner labels (case in point: `macos-14` started deprecating in July
2026) — if CI ever starts failing with a "runner image not found" error,
the first thing to check is the
[list of current images](https://github.com/actions/runner-images).

```yaml
- name: Select Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: latest-stable
```
Explicitly selecting the Xcode version through a ready-made action,
rather than hardcoding a path like `/Applications/Xcode_15.4.app` — that
path breaks on every runner image update (the default Xcode version
changes more often than the runner label itself). `latest-stable` is a
deliberate choice to "float" along with the image; if the project ever
needs to pin a specific Xcode version (e.g. because of a regression in a
newer one), a concrete value (`'16.4'`) goes here instead.

The remaining steps form a sequential pipeline on the same machine:

| Step | Command | What it checks / prepares |
|---|---|---|
| Install XcodeGen | `brew install xcodegen` | needed since `.xcodeproj` isn't in git — see `docs/project-setup.md` |
| Install SwiftLint | `brew install swiftlint` | the linter isn't pre-installed at the needed version on the runner by default |
| Lint | `swiftlint lint --strict` | fails on any warning, not just errors — this is the quality gate |
| Generate Xcode project | `xcodegen generate` | turns `project.yml` into `GigRoute.xcodeproj` |
| Resolve Swift packages | `xcodebuild -resolvePackageDependencies` | fetches SnapKit ahead of time — as a separate step so network timing doesn't get mixed up with build time |
| Build | `xcodebuild build ... CODE_SIGNING_ALLOWED=NO` | compiles for the simulator; no signing needed since we're not building a distributable archive |
| Test | `xcodebuild test ...` | runs `Tests/GigRouteTests` (XCTest) on the simulator |

Any non-zero exit code on any step turns the whole job red. Per the
convention in `CONTRIBUTING.md`, a PR can't be merged until CI is green.

## What's deliberately not in CI yet

- **Caching** SPM packages and `DerivedData` (`actions/cache`) — with a
  single dependency (SnapKit), the build-time savings don't yet justify
  the added cache-configuration complexity;
- A **matrix** across multiple iOS/Xcode versions — there's only one
  target, nothing to test a matrix against yet;
- **Secrets and code signing** for TestFlight/App Store — will come with
  the release workflow in M7;
- A **status badge** in the README — can be added at any point, as a
  separate `chore` commit.
