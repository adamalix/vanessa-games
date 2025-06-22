# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Management and Commands

**Always use `pnpm`** for all package management operations in this repository:

- Install dependencies: `pnpm install`
- Run scripts: `pnpm run <script>` or `pnpm <script>`
- Execute commands: `pnpm exec` (instead of `npx`)

## Development Commands

- **Start development server for specific app**: `pnpm --filter <app-name> dev`
  - Example: `pnpm --filter clausy-the-cloud dev`
- **Lint code**: `pnpm lint` (check) or `pnpm lint:fix` (auto-fix)
- **Format code**: `pnpm format` (fix) or `pnpm format:check` (check)
- **Build all games**: `pnpm build` (builds all apps in parallel)
- **Build specific app**: `pnpm --filter <app-name> build`

## Architecture Overview

This is a **pnpm workspace monorepo** for browser-based games:

- **Root**: Shared tooling (ESLint, Prettier, TypeScript configs)
- **Individual games**: Located in `apps/<game-name>/` folders
- **Tech stack**: React + TypeScript + Vite for each game
- **Canvas-based games**: Games use HTML5 Canvas with React for UI overlay

## Current Games

- **Clausy the Cloud** (`apps/clausy-the-cloud/`): A 2D canvas game where players control a cloud to water plants. Features touch controls, keyboard input, and canvas animation with React state management.

## Key Patterns

- Each game is a self-contained Vite + React + TypeScript app
- Canvas games use `useRef` for canvas access and `useEffect` for game loops
- Touch and keyboard controls are implemented for mobile compatibility
- Games use absolute positioning for UI overlays on canvas elements

## GitHub Pages Deployment

When deploying to GitHub Pages, set the `base` option in `vite.config.ts`:
```typescript
base: '/vanessa-games/<app-folder>/'
```

## Linting Configuration

- Uses flat config in `eslint.config.js` (ESLint 9+)
- Ignores patterns defined in the `ignores` property
- `.eslintignore` file is not supported
- Includes React, TypeScript, and Prettier integration