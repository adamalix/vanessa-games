# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Management and Commands

**Always use `pnpm`** for all package management operations in this repository:

- Install dependencies: `pnpm install`
- Run scripts: `pnpm run <script>` or `pnpm <script>`
- Execute commands: `pnpm exec` (instead of `npx`)

## Development Commands

### Web Apps

- **Start development server for specific app**: `pnpm --filter <app-name> dev`
  - Example: `pnpm --filter clausy-the-cloud dev`
- **Lint code**: `pnpm lint` (check) or `pnpm lint:fix` (auto-fix)
- **Format code**: `pnpm format` (fix) or `pnpm format:check` (check)
- **Build all games**: `pnpm build` (builds all apps in parallel)
- **Build specific app**: `pnpm --filter <app-name> build`

### iOS Apps

- **Build iOS apps**: `mise exec -- tuist build` (from VanessaGames/ directory)
  - Or from repository root: `mise exec -- tuist build --path VanessaGames`
  - Build specific target: `mise exec -- tuist build --path VanessaGames ClausyTheCloud`
- **Test iOS apps**: `mise exec -- tuist test` (from VanessaGames/ directory)
  - Or from repository root: `mise exec -- tuist test --path VanessaGames`
  - Test specific target: `mise exec -- tuist test --path VanessaGames ClausyTheCloud`
- **Generate Xcode workspace**: `mise exec -- tuist generate --path VanessaGames` (from repository root)

## Architecture Overview

This is a **hybrid monorepo** supporting both web and iOS apps:

### Web Apps (pnpm workspace)

- **Root**: Shared tooling (ESLint, Prettier, TypeScript configs)
- **Individual games**: Located in `apps/<game-name>/` folders
- **Tech stack**: React + TypeScript + Vite for each game
- **Canvas-based games**: Games use HTML5 Canvas with React for UI overlay

### iOS Apps (Tuist workspace)

- **Workspace**: `VanessaGames/VanessaGames.xcworkspace`
- **Games**: Individual iOS app targets (e.g., `ClausyTheCloud`)
- **Shared frameworks**: `SharedGameEngine`, `SharedAssets`
- **Tech stack**: SwiftUI + Swift 6.1 with strict concurrency
- **Data persistence**: Swift Data for local storage and data modeling
- **Testing**: Swift Testing framework (not XCTest)
- **Platform support**: iOS 18.0+ (minimum deployment target) with iPad optimization

## Current Games

### Web Versions

- **Clausy the Cloud** (`apps/clausy-the-cloud/`): A 2D canvas game where players control a cloud to water plants. Features touch controls, keyboard input, and canvas animation with React state management.

### iOS Versions

- **Clausy the Cloud** (`VanessaGames/Games/ClausyTheCloud/`): Native iOS/iPadOS app built with SwiftUI, using shared game engine and assets.

## Key Patterns

### Web Development

- Each game is a self-contained Vite + React + TypeScript app
- Canvas games use `useRef` for canvas access and `useEffect` for game loops
- Touch and keyboard controls are implemented for mobile compatibility
- Games use absolute positioning for UI overlays on canvas elements

### iOS Development

- Each game is a separate iOS app target within the Tuist workspace
- Shared functionality is extracted into reusable frameworks
- SwiftUI for modern declarative UI development
- Swift 6.1 with strict concurrency for safe async/await patterns
- Swift Data for all data persistence and modeling needs
- Target iOS 18.0+ for all apps and frameworks
- Support for both iPhone and iPad with adaptive layouts

## GitHub Pages Deployment

When deploying to GitHub Pages, set the `base` option in `vite.config.ts`:

```typescript
base: '/vanessa-games/<app-folder>/';
```

## Tool Management

**Use `mise`** for managing development tool versions:

- **Quick setup**: Run `./scripts/setup.sh` to initialize everything
- Manual setup:
  - Install tools: `mise install` (installs from `.mise.toml`)
  - Install dependencies: `pnpm install`
  - Setup pre-commit hooks: `pre-commit install`

### iOS Development Tools

- **SwiftLint** 0.59.1 - Swift code linting
- **Tuist** 4.54.3 - Xcode project generation
- **Periphery** 3.1.0 - unused code detection

### Code Quality Tools

- **pre-commit** - Git hooks for code formatting and linting
  - Automatically fixes trailing whitespace and missing newlines
  - Runs Prettier on JS/TS/JSON/CSS/MD files
  - Validates YAML, TOML, and JSON syntax

## iOS Development Workflow

### Getting Started

1. Run `./scripts/setup.sh` to install all tools
2. Navigate to `VanessaGames/` directory
3. Generate Xcode workspace: `mise exec -- tuist generate`
4. Open `VanessaGames.xcworkspace` in Xcode
5. Select "ClausyTheCloud" scheme to build and run

### Adding New Games

1. Add new target to `VanessaGames/Project.swift`
2. Create directory structure: `Games/<GameName>/Sources/`
3. Add scheme configuration for build/test actions
4. Regenerate workspace: `mise exec -- tuist generate`

### Project Structure

```
VanessaGames/
├── Project.swift           # Tuist project configuration
├── Tuist.swift            # Tuist settings
├── Games/
│   └── ClausyTheCloud/    # Individual game sources
├── Shared/
│   ├── GameEngine/        # Common game logic framework
│   └── Assets/            # Shared resources framework
└── VanessaGames.xcworkspace  # Generated Xcode workspace
```

## Linting Configuration

### Web Projects

- Uses flat config in `eslint.config.js` (ESLint 9+)
- Ignores patterns defined in the `ignores` property
- `.eslintignore` file is not supported
- Includes React, TypeScript, and Prettier integration

### iOS Projects

- SwiftLint configuration with strict rules
- Automated via Xcode build phases
- Periphery for unused code detection
