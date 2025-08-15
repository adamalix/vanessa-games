# iOS Game Testing Templates

This directory contains comprehensive testing templates for creating new iOS games in the VanessaGames project. These templates follow the established testing patterns and architecture documented in `AGENTS_TESTING.md`.

## Available Templates

### 1. GameEngineTestTemplate.swift

**Purpose**: Comprehensive testing for game engine logic and mechanics

**Features**:

- Dependency injection patterns for deterministic testing
- Core game mechanics testing (movement, scoring, win/lose conditions)
- Edge case testing (extreme values, rapid inputs, boundary conditions)
- Performance benchmarking for critical operations
- State consistency verification
- Memory management testing

**Usage**: Copy to your game's `Tests/` directory and customize for your game engine.

### 2. ViewTestTemplate.swift

**Purpose**: Snapshot and visual testing for SwiftUI game views

**Features**:

- Device-specific snapshot testing (iPhone, iPad variations)
- Dark mode testing across all major view states
- Accessibility testing (large text, high contrast)
- Orientation testing (portrait/landscape)
- Game state visual verification
- Deterministic snapshot generation

**Usage**: Copy to your game's `Tests/` directory and customize for your view structure.

### 3. IntegrationTestTemplate.swift

**Purpose**: End-to-end and component interaction testing

**Features**:

- View-Engine integration testing
- Complete gameplay scenario testing
- User input flow verification
- Performance integration testing
- Accessibility integration testing
- Error handling and recovery testing
- Data flow verification

**Usage**: Copy to your game's `Tests/` directory and customize for your game's workflows.

## Quick Start Guide

### Setting Up Tests for a New Game

1. **Create your game structure** following the existing pattern:

   ```
   VanessaGames/Games/YourGameName/
   ├── Sources/
   │   ├── YourGameNameApp.swift
   │   ├── ContentView.swift
   │   └── YourGameEngine.swift
   └── Tests/
       ├── YourGameNameTests.swift
       ├── ContentViewSnapshotTests.swift
       └── YourGameNameIntegrationTests.swift
   ```

2. **Copy the templates**:

   ```bash
   cp VanessaGames/TestingTemplates/GameEngineTestTemplate.swift \
      VanessaGames/Games/YourGameName/Tests/YourGameNameTests.swift

   cp VanessaGames/TestingTemplates/ViewTestTemplate.swift \
      VanessaGames/Games/YourGameName/Tests/ContentViewSnapshotTests.swift

   cp VanessaGames/TestingTemplates/IntegrationTestTemplate.swift \
      VanessaGames/Games/YourGameName/Tests/YourGameNameIntegrationTests.swift
   ```

3. **Customize the templates**:
   - Replace `[GameName]` with your game name (e.g., `SpaceShooter`)
   - Replace `[GameEngineClass]` with your engine class name (e.g., `SpaceShooterGameEngine`)
   - Replace `[ContentView]` with your view class name
   - Fill in the TODO sections with your game-specific logic

4. **Add your game to Project.swift** with test targets

5. **Generate the Xcode workspace**:
   ```bash
   mise exec -- tuist generate --path VanessaGames
   ```

### Customization Steps

#### For GameEngineTestTemplate.swift:

1. **Update imports** to match your modules:

   ```swift
   @testable import YourGameName
   @testable import SharedGameEngine
   ```

2. **Customize the helper method**:

   ```swift
   private func createTestGameEngine() -> YourGameEngine {
       return withDependencies {
           $0.gameClock = .preview
           $0.gameRandom = .seeded(42)
           $0.timerService = .test
       } operation: {
           YourGameEngine(canvasWidth: 600, canvasHeight: 800)
       }
   }
   ```

3. **Fill in test assertions** based on your game's properties and methods

#### For ViewTestTemplate.swift:

1. **Update the GameState enum** for your game's states:

   ```swift
   private enum GameState {
       case menu
       case playing
       case paused
       case gameOver
       case levelComplete
       // Add your game-specific states
   }
   ```

2. **Implement createGameEngineWithState()** for each state

3. **Customize device configurations** if needed

#### For IntegrationTestTemplate.swift:

1. **Update the GameAction enum** for your game's actions:

   ```swift
   private enum GameAction {
       case moveLeft, moveRight, jump, shoot, useItem
       case pause, resume, restart
       // Add your game-specific actions
   }
   ```

2. **Implement simulateGameplaySession()** to map actions to engine calls

3. **Add game-specific integration scenarios**

### Running Tests

#### Run all tests:

```bash
mise exec -- tuist test --path VanessaGames YourGameName
```

#### Generate snapshots:

```bash
./scripts/generate_snapshots.sh
```

#### Run specific test suites:

```bash
# Unit tests only
mise exec -- tuist test --path VanessaGames YourGameName --filter YourGameNameTests

# Snapshot tests only
mise exec -- tuist test --path VanessaGames YourGameName --filter ContentViewSnapshotTests

# Integration tests only
mise exec -- tuist test --path VanessaGames YourGameName --filter YourGameNameIntegrationTests
```

## Testing Architecture

### Dependency Injection Pattern

All templates use the swift-dependencies pattern for testable, deterministic code:

```swift
// In your game engine
@MainActor
@Observable
final class YourGameEngine {
    @Dependency(\.gameClock) var clock
    @Dependency(\.gameRandom) var random
    @Dependency(\.timerService) var timer

    // Your game logic using injected dependencies
}

// In tests
let engine = withDependencies {
    $0.gameClock = .preview      // Fixed time
    $0.gameRandom = .seeded(42)  // Deterministic randomness
    $0.timerService = .test      // Controllable timers
} operation: {
    YourGameEngine()
}
```

### Test Categories

1. **Unit Tests** (GameEngineTestTemplate):
   - Test individual game mechanics in isolation
   - Verify edge cases and boundary conditions
   - Benchmark performance of critical operations

2. **Snapshot Tests** (ViewTestTemplate):
   - Capture visual regression testing
   - Test across device variations
   - Verify accessibility compliance

3. **Integration Tests** (IntegrationTestTemplate):
   - Test component interactions
   - Verify complete user workflows
   - Test real-world scenarios

### Best Practices

1. **Use descriptive test names** that explain what behavior is being tested
2. **Keep tests focused** - one behavior per test method
3. **Use dependency injection** for all external dependencies
4. **Test edge cases** and boundary conditions
5. **Include performance benchmarks** for critical operations
6. **Group related tests** with MARK comments
7. **Generate snapshots carefully** and review changes before committing

## Template Maintenance

When updating these templates:

1. **Keep them synchronized** with the latest testing patterns in existing games
2. **Update documentation** when adding new testing capabilities
3. **Test the templates** by creating a sample game using them
4. **Follow the established patterns** documented in `AGENTS_TESTING.md`

## Support

For questions about using these templates or testing patterns:

1. Review the comprehensive examples in `VanessaGames/Games/ClausyTheCloud/Tests/`
2. Check the testing guidelines in `AGENTS_TESTING.md`
3. Look at the dependency patterns in `VanessaGames/Shared/GameEngine/Sources/Dependencies/`

These templates provide a comprehensive foundation for testing any new iOS game while following the established VanessaGames architecture and testing philosophy.
