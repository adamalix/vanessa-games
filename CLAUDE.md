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
- **Tuist** 4.59.2 - Xcode project generation
- **Periphery** 3.2.0 - unused code detection

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

## iOS Testing Guidelines

### Testing Philosophy

The iOS apps follow a comprehensive testing strategy to ensure reliability and maintainability. All game logic, views, and integrations should be thoroughly tested.

### Test Types and Coverage

#### Unit Tests (Required)

- **Game Logic**: All business rules, calculations, and state transitions
- **Models**: Data structures and their behaviors
- **Edge Cases**: Boundary conditions, error states, and invalid inputs
- **Performance**: Critical path benchmarks for game loops and rendering

#### Integration Tests (Required)

- **View + Engine Integration**: SwiftUI views working with game engines
- **End-to-End Scenarios**: Complete game flows from start to finish
- **Component Interactions**: Communication between different system layers

#### Snapshot Tests (Required)

- **Visual Regression**: Ensure UI changes are intentional
- **Device Variations**: Test across iPhone and iPad layouts
- **Accessibility States**: High contrast, large text, VoiceOver
- **Game States**: All major visual states of the game

### Testing Best Practices

#### When Writing Tests

1. **Use dependency injection** - Inject all external dependencies (time, randomization, timers)
2. **Make tests deterministic** - Use controlled dependencies to avoid flaky tests
3. **Test behavior, not implementation** - Focus on what the code does, not how
4. **Use descriptive test names** - Names should clearly describe the scenario being tested
5. **Keep tests focused** - One behavior per test function

#### Test Structure Pattern

```swift
@Test func testSpecificBehavior() {
    // Arrange: Set up test conditions
    let engine = createTestEngine()

    // Act: Perform the action being tested
    engine.performAction()

    // Assert: Verify expected outcomes
    #expect(engine.state == expectedState)
}
```

#### Snapshot Testing Pattern

```swift
@Test func testViewState() {
    let engine = createTestEngineWithState()
    let view = ContentView(gameEngine: engine)

    assertSnapshot(
        of: view,
        as: .image(layout: .device(config: .iPhone15))
    )
}
```

### Dependency Injection for Testing

Use `swift-dependencies` for all external dependencies to enable deterministic testing:

#### Common Dependencies to Inject

- **Time/Clocks**: Use `ImmediateClock` for instant time progression
- **Random Numbers**: Use seeded generators for predictable randomness
- **Timers**: Use controllable timer services instead of `Timer`
- **System Services**: Mock network, file system, and device interactions

#### Example Dependency Usage

```swift
@MainActor
@Observable
final class GameEngine {
    @Dependency(\.gameClock) var clock
    @Dependency(\.gameRandom) var random

    // Use injected dependencies instead of direct system calls
    private func generateRandomPosition() -> CGPoint {
        CGPoint(
            x: random.double(in: 0...screenWidth),
            y: random.double(in: 0...screenHeight)
        )
    }
}

// In tests - control the dependencies
@Test func testRandomPositionGeneration() {
    let engine = withDependencies {
        $0.gameRandom = SeededRandom(seed: 42)
    } operation: {
        GameEngine()
    }

    let position = engine.generateRandomPosition()
    // Position will be deterministic based on seed
    #expect(position.x == expectedX)
    #expect(position.y == expectedY)
}
```

### Testing Commands

#### Generate/Update Snapshots

```bash
# From repository root - regenerate all snapshots
./scripts/generate_snapshots.sh

# Run tests normally to verify snapshots
mise exec -- tuist test --path VanessaGames
```

#### Run Specific Test Suites

```bash
# Test specific target
mise exec -- tuist test --path VanessaGames ClausyTheCloud

# Test shared components
mise exec -- tuist test --path VanessaGames SharedGameEngine
```

### Test Organization

#### File Structure

```
Games/ClausyTheCloud/Tests/
├── ClausyTheCloudTests.swift       # Game logic unit tests
├── ContentViewSnapshotTests.swift  # View snapshot tests
└── __Snapshots__/                  # Generated snapshot images
```

#### Test Categories

- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test component interactions
- **Snapshot Tests**: Test visual rendering and layout
- **Performance Tests**: Test critical path performance

### Test Maintenance

#### When Adding New Features

1. **Write tests first** - Define expected behavior before implementation
2. **Update related tests** - Ensure existing tests still pass
3. **Add snapshot tests** - For any new visual components
4. **Test edge cases** - Consider boundary conditions and error states

#### When Modifying Existing Code

1. **Run tests before changes** - Establish baseline
2. **Keep tests green during refactoring** - Fix tests as you refactor
3. **Update test names if needed** - Keep test descriptions accurate
4. **Review snapshot changes** - Verify visual changes are intentional

#### When Tests Fail

1. **Check dependencies** - Ensure injected dependencies match expectations
2. **Verify test data** - Confirm test setup creates expected initial state
3. **Run tests individually** - Isolate failing tests to identify root cause
4. **Look for non-determinism** - Check for uncontrolled randomness or timing

### Performance Testing

#### Critical Metrics to Monitor

- **Frame Rate**: Game loop should maintain 60 FPS
- **Memory Usage**: No memory leaks during gameplay
- **Launch Time**: App startup should be under 2 seconds
- **Battery Impact**: Minimize power consumption during gameplay

#### Performance Test Pattern

```swift
@Test func testGameLoopPerformance() {
    let engine = createTestEngine()

    measure {
        // Run multiple game loop iterations
        for _ in 0..<1000 {
            engine.gameLoop()
        }
    }
}
```

### Common Testing Patterns

See `AGENTS_TESTING.md` for detailed implementation examples and the complete testing strategy.

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

- Use the @scripts/generate_snapshots.sh script to generate snapshots
