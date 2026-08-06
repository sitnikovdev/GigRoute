# CI и качество кода

## SwiftLint — `.swiftlint.yml`

Правила разбиты на три группы:

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
Правила, которые SwiftLint по умолчанию не включает, но мы явно хотим —
из них практически важнее всего **`force_unwrapping`**: запрещает `!` без
явного обоснования. Одно текущее исключение — `URL(string: "...")!` в
`AppDependencyContainer` для захардкоженного плейсхолдер-URL; когда там
появится конфигурация из `.xcconfig`/окружения, форс-анврап уйдёт вместе с
хардкодом.

```yaml
disabled_rules:
  - todo
```
`// TODO:` не считается предупреждением — на активной разработке они
неизбежны и полезны как маркеры, спам от линтера по ним только мешает.

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
Пороги "мягкий warning / жёсткий error" — превышение error-порога валит
`swiftlint lint --strict` и, соответственно, CI. Числа не догма — если
конкретный кейс упрётся в лимит по объективной причине, обсуждаем и
двигаем порог в PR, а не отключаем правило точечным `// swiftlint:disable`
без причины в комментарии.

## GitHub Actions — `.github/workflows/ci.yml`

```yaml
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
```
Запуск на каждый PR в `main` и на каждый push в `main` (то есть и на сам
PR, и повторно после merge — чтобы `main` тоже был гарантированно зелёным).

```yaml
runs-on: macos-26
```
GitHub-хостед macOS-раннер — сборка iOS в принципе возможна только на
macOS (нужен Xcode toolchain). `macos-26` — актуальный на данный момент
образ; лейблы раннеров GitHub периодически обновляет и депрекейтит
старые (см. историю: `macos-14` уходит в депрекацию с июля 2026) — если
CI однажды начнёт падать с ошибкой "runner image not found", в первую
очередь стоит проверить [список актуальных образов](https://github.com/actions/runner-images).

```yaml
- name: Select Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: latest-stable
```
Явный выбор версии Xcode через готовый action, а не хардкод пути вида
`/Applications/Xcode_15.4.app` — путь ломается при каждом обновлении
образа раннера (версия Xcode в дефолте меняется чаще, чем сам лейбл
раннера). `latest-stable` — сознательный выбор "плыть по течению" вместе
с образом; если проекту понадобится жёстко зафиксировать конкретную
версию Xcode (например, из-за регрессии в новой версии), сюда подставляется
конкретное значение (`'16.4'`).

Дальнейшие шаги — последовательный pipeline на одной и той же машине:

| Шаг | Команда | Что проверяет / готовит |
|---|---|---|
| Install XcodeGen | `brew install xcodegen` | нужен, т.к. `.xcodeproj` не в git — см. `docs/project-setup.md` |
| Install SwiftLint | `brew install swiftlint` | линтер не предустановлен на раннере в нужной версии по умолчанию |
| Lint | `swiftlint lint --strict` | падает при любом warning, не только error — это и есть gate качества |
| Generate Xcode project | `xcodegen generate` | превращает `project.yml` в `GigRoute.xcodeproj` |
| Resolve Swift packages | `xcodebuild -resolvePackageDependencies` | заранее качает SnapKit — отдельным шагом, чтобы сетевые тайминги не путались с временем сборки |
| Build | `xcodebuild build ... CODE_SIGNING_ALLOWED=NO` | компиляция под симулятор; подпись не нужна — не собираем архив для публикации |
| Test | `xcodebuild test ...` | прогоняет `Tests/GigRouteTests` (XCTest) на симуляторе |

Любой ненулевой код возврата на любом шаге — весь job красный. По
конвенции из `CONTRIBUTING.md` PR нельзя мержить, пока CI не зелёный.

## Чего в CI пока сознательно нет

- **Кеширование** SPM-пакетов и `DerivedData` (`actions/cache`) — при
  единственной зависимости (SnapKit) выигрыш по времени сборки пока не
  оправдывает добавляемую сложность конфигурации кеша;
- **Матрица** по нескольким версиям iOS/Xcode — один таргет, тестировать
  не на чем;
- **Секреты и code signing** для TestFlight/App Store — появится вместе с
  release-workflow в M7;
- **Статус-бейдж** в README — можно добавить в любой момент, отдельным
  `chore`-коммитом.
