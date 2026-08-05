# Contributing to GigRoute

This project follows a structured engineering workflow: changes move from
planning to implementation through documented and reviewable steps.

## Workflow

1. **Issues** describe user value and expected outcomes (see
   `.github/ISSUE_TEMPLATE`). No work starts without an issue.
2. **Feature branches** isolate development. Branch from `main`.
3. **Conventional commits** describe intent.
4. **Pull requests** are the unit of review and integration.
5. **CI checks** (build, lint, tests) must pass before merge.

## Branch naming

| Type      | Pattern                        | Example                          |
|-----------|---------------------------------|-----------------------------------|
| Feature   | `feature/<milestone>-<name>`   | `feature/home-slot-toggle`        |
| Fix       | `fix/<name>`                   | `fix/orders-pin-rotation`         |
| Chore     | `chore/<name>`                 | `chore/ci-swiftlint`              |
| Docs      | `docs/<name>`                  | `docs/engineering-manifesto`      |

## Commit messages (Conventional Commits)

```
<type>(<scope>): <short summary>

[optional body]

[optional footer, e.g. Closes #12]
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`

Examples:
```
feat(home): add slot toggle button
fix(orders): correct pin rotation on heading change
docs(engineering): document branching conventions
test(profile): cover ProfileViewModel stats mapping
```

## Pull requests

- One PR per issue where possible; link it with `Closes #<issue>`.
- PR description restates the expected outcomes from the issue as a checklist.
- CI must be green before requesting review.
- At least one approving review required before merge.
- Prefer squash-merge so `main` history reads as one commit per unit of work.

## Definition of done (applies to every issue)

- [ ] Implemented on the correct branch type
- [ ] Commits follow Conventional Commits
- [ ] Unit tests added/updated where applicable
- [ ] PR linked to its issue and merged via review
- [ ] CI green (build + SwiftLint + tests)
