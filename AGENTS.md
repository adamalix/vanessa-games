# Repository Guidelines

## Project Structure & Module Organization

- `apps/` contains each web game as a standalone React + TypeScript workspace (e.g., `apps/clausy-the-cloud/src/`).
- `VanessaGames/` holds the Tuist-driven Swift workspace; `Games/` stores individual game targets and `Shared/` provides reusable SwiftUI components.
- `scripts/` houses automation such as `setup.sh`, `swiftlint.sh`, and deployment helpers.
- Root config lives in `.oxlintrc.json`, `pnpm-workspace.yaml`, and `pnpm-lock.yaml`; treat these as source of truth for tooling versions.

## Build, Test, and Development Commands

- Run `./scripts/setup.sh` or `pnpm install` to bootstrap dependencies via pnpm workspaces.
- Start a web game locally with `pnpm --filter clausy-the-cloud dev`.
- Build every web app using `pnpm build`; target a single game with `pnpm --filter <game> build` (outputs to `apps/<game>/dist/`).
- Generate the iOS workspace by `mise exec -- tuist generate --path VanessaGames`, then build with `mise exec -- tuist build --path VanessaGames`.
- Use `pnpm lint`, `pnpm lint:fix`, `pnpm format`, and `pnpm format:check` to enforce JS/TS style with Oxc tooling.

## Testing Guidelines

- iOS tests run through Tuist: `mise exec -- tuist test --path VanessaGames` (required before merging platform changes).
- Web testing harness is not yet scaffolded; when adding tests, colocate them in `apps/<game>/src/__tests__/` and wire scripts through pnpm.
- Aim for smoke coverage on critical gameplay flows before release and document new test commands in this file.

## Agent-Specific Notes

- Always prefer pnpm-based workflows and update this guide when scripts, tools, or project layout change.
