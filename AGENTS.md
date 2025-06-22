# Agents Configuration

This file contains project-specific guidelines for agents (e.g., Codex CLI).

- **Always use `pnpm`** for installing dependencies, running scripts, and managing packages in this repository.
- **Always** prefer `pnpm` versions of commands. For example, use `pnpm exec` instead of `npx` or `npm exec`, and `pnpm run` instead of `npm run`.
- **Always update** this and any other `AGENTS.md` files when there is a relevant change to dependencies, scripts, or project configuration.
- **Linting**: use `pnpm lint` to check code quality and catch errors early, and `pnpm lint:fix` to automatically fix lint issues. Configuration now lives in a flat config file: `eslint.config.js`, including ignore patterns via the `ignores` property (see https://eslint.org/docs/latest/use/configure/migration-guide#ignoring-files). The `.eslintignore` file is no longer supported.
- **Building apps**: use `pnpm build` to compile all games in the `apps` folder. Each app exposes its own `build` script and the root script runs them all.
