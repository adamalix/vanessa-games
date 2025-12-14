# Repository Guidelines

## Project Structure & Module Organization

- `apps/` contains each web game as a standalone React + TypeScript workspace (e.g., `apps/clausy-the-cloud/src/`).
- `VanessaGames/` holds the Tuist-driven Swift workspace; `Games/` stores individual game targets and `Shared/` provides reusable SwiftUI components.
- `scripts/` houses automation such as `setup.sh`, `swiftlint.sh`, and deployment helpers.
- Root config lives in `eslint.config.js`, `pnpm-workspace.yaml`, and `pnpm-lock.yaml`; treat these as source of truth for tooling versions.

## Build, Test, and Development Commands

- Run `./scripts/setup.sh` or `pnpm install` to bootstrap dependencies via pnpm workspaces.
- Start a web game locally with `pnpm --filter clausy-the-cloud dev`.
- Build every web app using `pnpm build`; target a single game with `pnpm --filter <game> build` (outputs to `apps/<game>/dist/`).
- Generate the iOS workspace by `mise exec -- tuist generate --path VanessaGames`, then build with `mise exec -- tuist build --path VanessaGames`.
- Use `pnpm lint`, `pnpm lint:fix`, `pnpm format`, and `pnpm format:check` to enforce JS/TS style.

## Coding Style & Naming Conventions

- TypeScript/React files use functional components, PascalCase for components, camelCase for variables, and 2-space indentation (enforced by Prettier).
- Swift targets conform to SwiftLint rules in `VanessaGames/.swiftlint.yml`; keep Swift files under 200 lines and prefer struct-based SwiftUI views.
- Keep assets alongside features (e.g., `apps/<game>/src/CloudCanvas.tsx` with `style.css`).
- Prefer pnpm commands (`pnpm exec <tool>`) over npm/npx equivalents.

## Testing Guidelines

- iOS tests run through Tuist: `mise exec -- tuist test --path VanessaGames` (required before merging platform changes).
- Web testing harness is not yet scaffolded; when adding tests, colocate them in `apps/<game>/src/__tests__/` and wire scripts through pnpm.
- Aim for smoke coverage on critical gameplay flows before release and document new test commands in this file.

## Commit & Pull Request Guidelines

- Follow imperative, descriptive commit messages and reference issues (e.g., `Increase Clausy's movement speed (#20)`).
- Squash noisy work-in-progress commits before pushing.
- PRs should link the relevant issue, describe gameplay/UI changes, list validation steps (`pnpm build`, `tuist test`), and include screenshots or recordings for visual updates.
- Run linting and the applicable platform build/test commands locally before requesting review.

## Agent-Specific Notes

- Always prefer pnpm-based workflows and update this guide when scripts, tools, or project layout change.
- Use `gh` CLI for GitHub issue and PR operations to match repository automation.

# Work Planning & Execution

Use beads `bd` for new work planning and execution.

# Apple documentation

You can use `sosumi` to look up the latest Apple documentation.

# Working with Apple Simulators

Use `axe` to interact with Apple Simulators for testing and debugging iOS games.
