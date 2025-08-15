# iOS Testing Strategy & Implementation Plan

## Overview

This document outlines a comprehensive plan to make the iOS games in the VanessaGames project highly testable. The goal is to achieve comprehensive test coverage for both game logic and views while establishing clear design principles that future agents can follow.

## Current State Analysis

### Strengths

- ✅ Swift Testing framework integrated
- ✅ Snapshot testing implemented with good coverage
- ✅ Deterministic testing partially implemented (randomSeed parameter)
- ✅ Clean separation between game engine and views
- ✅ Good basic test coverage for game mechanics

### Areas for Improvement

- ✅ swift-dependencies package integrated into project
- ❌ Drawing logic duplicated between views and tests
- ❌ Limited control over randomization and timing
- ❌ No architecture documentation for testability
- ❌ ContentView tightly coupled to game engine creation

## Design Philosophy for Testable iOS Games

### Core Principles

1. **Dependency Isolation**: All external dependencies (time, randomization, timers) should be injectable
2. **Deterministic Testing**: Tests must be reproducible and fast
3. **Component Separation**: Game logic, rendering, and UI interaction should be separate concerns
4. **View Testability**: Views should be testable in isolation with controlled state
5. **Comprehensive Coverage**: Test both individual components and integration scenarios

### Dependency Design Guidelines

We use `swift-dependencies` as our dependency injection framework, but only add it to targets that actually need dependency injection.

#### Target-Specific Dependency Strategy

1. **Assess each target individually**: Only add swift-dependencies to targets that have external dependencies
2. **Start with game engines**: ClausyGameEngine likely needs timer and randomization dependencies
3. **Add to shared frameworks**: SharedGameEngine probably needs dependencies for reusable game logic
4. **Skip simple targets**: Targets with no external dependencies don't need the package

Following the [Designing Dependencies guide](https://github.com/pointfreeco/swift-dependencies/blob/main/Sources/Dependencies/Documentation.docc/Articles/DesigningDependencies.md) from swift-dependencies, we adopt these patterns:

#### Struct-Based Dependencies (Preferred)

- Use closure-based structs for maximum flexibility
- Leverage `@DependencyClient` macro for automatic implementations
- Design minimal interfaces exposing only necessary functionality
- Enable selective endpoint overriding in tests

```swift
@DependencyClient
struct GameRandomService {
  var double: (_ range: ClosedRange<Double>) -> Double = { _ in 0.0 }
  var element: <T>(_ collection: T) -> T.Element? where T: Collection = { _ in nil }
  var bool: () -> Bool = { false }
}

extension DependencyValues {
  var gameRandom: GameRandomService {
    get { self[GameRandomServiceKey.self] }
    set { self[GameRandomServiceKey.self] = newValue }
  }
}
```

#### Live, Preview, and Test Implementations

Each dependency should provide three implementations:

- **Live**: Production implementation using real system resources
- **Preview**: Simplified implementation for SwiftUI previews
- **Test**: Controllable implementation for unit testing

```swift
extension GameRandomService {
  static let live = Self(
    double: { range in Double.random(in: range) },
    element: { collection in collection.randomElement() },
    bool: { Bool.random() }
  )

  static let preview = Self(
    double: { _ in 0.5 }, // Predictable middle values
    element: { collection in collection.first },
    bool: { true }
  )

  static func seeded(_ seed: UInt64) -> Self {
    var generator = SeededRandomNumberGenerator(seed: seed)
    return Self(
      double: { range in Double.random(in: range, using: &generator) },
      element: { collection in collection.randomElement(using: &generator) },
      bool: { Bool.random(using: &generator) }
    )
  }
}
```

#### Minimal Interface Design

Game features should expose only the endpoints they actually use:

```swift
// Instead of exposing entire audio system
@Dependency(\.audioPlayer.playSound) var playSound
@Dependency(\.audioPlayer.setVolume) var setVolume

// Game only uses what it needs
func waterPlant() {
  playSound("splash.wav")
  // Game logic...
}
```

This approach ensures:

- **Testability**: Easy to verify only required dependencies are used
- **Flexibility**: Can override specific endpoints without full mock implementations
- **Maintainability**: Clear understanding of what external systems each feature depends on

### What Should Be Tested

#### High Priority (Must Test)

- **Game Logic**: Core mechanics, win conditions, state transitions
- **View Rendering**: Visual components render correctly under all states
- **User Interactions**: Button presses, gestures produce expected outcomes
- **Edge Cases**: Boundary conditions, error states, invalid inputs

#### Medium Priority (Should Test)

- **Performance**: Frame rate consistency, memory usage
- **Integration**: Component interactions, data flow
- **Accessibility**: VoiceOver support, dynamic type

#### Low Priority (Nice to Have)

- **Animation Timing**: Smooth transitions, proper durations
- **Device Variations**: Different screen sizes, orientations

### Architecture Pattern

```
View Layer (SwiftUI)
    ↓ (via @Dependency)
Game Engine Layer (@Observable)
    ↓ (via @Dependency)
Service Layer (Clocks, Random, etc.)
```

## Implementation Plan

### Phase 1: Foundation Setup (2 tasks)

#### Task 1.1: Identify Target-Specific Dependency Needs

- **Goal**: Analyze which targets need dependency injection
- **Actions**:
  - Review ClausyGameEngine for external dependencies (timers, randomization)
  - Check SharedGameEngine for potential dependencies
  - Identify which targets are currently hard to test due to external dependencies
  - Document which specific targets need swift-dependencies added

#### Task 1.2: Add swift-dependencies to Required Targets

- **Goal**: Add swift-dependencies package only to targets that need it
- **Actions**:
  - Add swift-dependencies to Tuist/Package.swift
  - Update Project.swift to include dependency only in targets that need injection
  - Create core dependencies (GameClock, GameRandom, TimerService)
  - Leave targets without external dependencies unchanged

#### Task 1.3: Extract Drawing Components (If Needed)

- **Goal**: Eliminate code duplication in rendering only if it exists
- **Actions**:
  - Assess whether drawing logic is actually duplicated
  - If duplication exists: Create reusable `GameRenderer` component
  - If no duplication: Skip this task and focus on other testability improvements

### Phase 2: Game Engine Refactoring (2-3 tasks)

#### Task 2.1: Inject Dependencies into ClausyGameEngine

- **Goal**: Make game engine fully testable with swift-dependencies
- **Actions**:
  - Replace Timer with injected TimerService dependency
  - Replace random number generation with GameRandom dependency
  - Remove randomSeed parameter (replaced by dependency system)
  - Use @Dependency property wrapper for clean dependency access

#### Task 2.2: Refactor ContentView for Testability

- **Goal**: Make main game view testable
- **Actions**:
  - Accept injected ClausyGameEngine instead of creating internally
  - Add initializers for testing with custom engine
  - Separate UI state from game state

#### Task 2.3: Enhanced Game Logic Tests

- **Goal**: Comprehensive coverage of game mechanics
- **Actions**:
  - Add edge case tests (boundary conditions, rapid inputs)
  - Test error recovery scenarios
  - Add performance benchmarks for critical operations

#### Task 2.4: Integration Tests

- **Goal**: Test component interactions
- **Actions**:
  - Test view + engine integration
  - Test full game scenarios end-to-end
  - Add accessibility tests

### Phase 3: Advanced Testing Features (2-3 tasks)

#### Task 3.1: Enhanced Snapshot Testing

- **Goal**: Comprehensive visual testing
- **Actions**:
  - Add device-specific snapshot tests (iPhone, iPad)
  - Test dark mode variations
  - Add accessibility snapshot tests (large text, high contrast)

#### Task 3.2: Performance & Memory Tests

- **Goal**: Ensure games perform well on all devices
- **Actions**:
  - Add memory leak detection tests
  - Add frame rate consistency tests
  - Add battery usage benchmarks

#### Task 3.3: Property-Based Testing

- **Goal**: Discover edge cases automatically
- **Actions**:
  - Add property-based tests for game logic
  - Test with random valid inputs
  - Verify invariants always hold

### Phase 4: Documentation & Templates (2 tasks)

#### Task 4.1: Create Testing Templates

- **Goal**: Make it easy to add tests for new games
- **Actions**:
  - Create game engine test template
  - Create view test template with snapshot examples
  - Create integration test template

#### Task 4.2: Update Documentation

- **Goal**: Guide future development
- **Actions**:
  - Update CLAUDE.md with testing guidelines
  - Add code comments explaining testing patterns
  - Create agent prompts for common testing tasks

## Detailed Implementation Guide

### Dependency Injection Pattern

Following the [Designing Dependencies](https://github.com/pointfreeco/swift-dependencies/blob/main/Sources/Dependencies/Documentation.docc/Articles/DesigningDependencies.md) guide, use struct-based dependencies with the `@DependencyClient` macro:

```swift
// Define dependencies using struct-based approach
@DependencyClient
struct GameClockService {
  var now: () -> Date = { Date() }
  var sleep: (Duration) async throws -> Void
}

@DependencyClient
struct GameRandomService {
  var double: (_ range: ClosedRange<Double>) -> Double = { _ in 0.0 }
  var element: <T>(_ collection: T) -> T.Element? where T: Collection = { _ in nil }
  var bool: () -> Bool = { false }
}

extension DependencyValues {
  var gameClock: GameClockService {
    get { self[GameClockServiceKey.self] }
    set { self[GameClockServiceKey.self] = newValue }
  }

  var gameRandom: GameRandomService {
    get { self[GameRandomServiceKey.self] }
    set { self[GameRandomServiceKey.self] = newValue }
  }
}

// Game Engine with Dependencies
@MainActor
@Observable
public final class ClausyGameEngine {
  @Dependency(\.gameClock) var clock
  @Dependency(\.gameRandom) var random

  // Use minimal interface - only what's needed
  private func generateRainOffset() -> Double {
    random.double(in: -30...30)
  }

  private func getCurrentTime() -> Date {
    clock.now()
  }
}

// Testing with Controlled Dependencies
@Test func testDeterministicGameplay() {
  let gameEngine = withDependencies {
    $0.gameClock = .preview  // Uses fixed time
    $0.gameRandom = .seeded(42)  // Deterministic randomness
  } operation: {
    ClausyGameEngine()
  }

  // Test with predictable behavior
  let offset1 = gameEngine.generateRainOffset()
  let offset2 = gameEngine.generateRainOffset()

  // These will be deterministic based on seed
  #expect(offset1 == expectedValue1)
  #expect(offset2 == expectedValue2)
}
```

### Testable View Pattern

```swift
// ContentView with Dependency Injection
struct ContentView: View {
  @State private var gameEngine: ClausyGameEngine

  init(gameEngine: ClausyGameEngine? = nil) {
    self._gameEngine = State(initialValue: gameEngine ?? ClausyGameEngine())
  }

  // ... rest of implementation
}

// Test-friendly view creation
@Test func testViewWithSpecificGameState() {
  let testEngine = withDependencies {
    $0.gameClock = ImmediateClock()
  } operation: {
    let engine = ClausyGameEngine()
    engine.gameWon = true
    return engine
  }

  let view = ContentView(gameEngine: testEngine)

  assertSnapshot(of: view, as: .image)
}
```

### Random Number Control

```swift
protocol GameRandomizing {
  func double(in range: ClosedRange<Double>) -> Double
  func element<T>(from collection: T) -> T.Element? where T: Collection
}

struct SeededGameRandom: GameRandomizing {
  private var generator: SeededRandomNumberGenerator

  init(seed: UInt64) {
    self.generator = SeededRandomNumberGenerator(seed: seed)
  }

  func double(in range: ClosedRange<Double>) -> Double {
    Double.random(in: range, using: &generator)
  }
}

// Usage in game engine
let rainOffset = random.double(in: -30...30)
let flowerColor = random.element(from: availableColors)
```

## Testing Best Practices for Agents

### When Adding New Features

1. **Write tests first** - Define expected behavior before implementation
2. **Use dependency injection** - Make all external dependencies injectable
3. **Create focused tests** - Test one behavior per test function
4. **Use meaningful names** - Test names should describe the behavior being tested
5. **Update snapshots carefully** - Verify visual changes are intentional

### When Debugging Test Failures

1. **Check dependencies** - Ensure injected dependencies match expectations
2. **Verify test data** - Confirm test setup creates expected initial state
3. **Run tests individually** - Isolate failing tests to identify root cause
4. **Check for non-determinism** - Look for uncontrolled randomness or timing

### When Refactoring Code

1. **Run tests before changes** - Ensure starting point is green
2. **Keep tests green during refactoring** - Fix tests as you refactor
3. **Update test names if behavior changes** - Keep tests descriptive
4. **Add tests for new edge cases** - Refactoring often reveals new scenarios

### Common Testing Patterns

#### Testing Game State Transitions

```swift
@Test func testPlantGrowthProgression() {
  let engine = createTestEngine()
  let plant = engine.plants[0]

  // Test initial state
  #expect(plant.height == 0)
  #expect(plant.grown == false)

  // Trigger growth
  engine.positionCloudOverPlant(0)
  engine.advanceGameLoop(steps: 10)

  // Verify intermediate state
  #expect(plant.height > 0)
  #expect(plant.grown == false)

  // Complete growth
  engine.advanceGameLoop(steps: 100)

  // Verify final state
  #expect(plant.grown == true)
}
```

#### Testing View States

```swift
@Test func testWinScreenDisplay() {
  let engine = createTestEngine()
  engine.gameWon = true

  let view = ContentView(gameEngine: engine)

  // Test that win screen is visible
  assertSnapshot(
    of: view,
    as: .image(layout: .device(config: .iPhone15))
  )
}
```

#### Testing User Interactions

```swift
@Test func testCloudMovementControls() {
  let engine = createTestEngine()
  let initialX = engine.cloud.xPos

  engine.moveCloudLeft()
  #expect(engine.cloud.xPos < initialX)

  engine.moveCloudRight()
  #expect(engine.cloud.xPos == initialX)
}
```

## Progress Tracking

### Completion Criteria for Each Phase

**Phase 1 Complete When:**

- [x] Target-specific dependency needs identified
- [x] swift-dependencies added only to targets that need it
- [x] Drawing component duplication assessed (no duplication found - task skipped)

**Phase 2 Complete When:**

- [x] Core dependencies defined and injectable (GameClock, GameRandom, TimerService)
- [x] ClausyGameEngine fully uses swift-dependencies pattern
- [x] ContentView accepts injected game engine
- [x] All existing tests pass with new architecture
- [x] Enhanced test coverage for game logic

**Phase 3 Complete When:**

- [ ] Snapshot tests cover all major view states
- [ ] Performance tests establish benchmarks
- [ ] Property-based tests verify game invariants

**Phase 4 Complete When:**

- [ ] Testing templates available for new games
- [ ] Documentation updated with testing guidelines
- [ ] All patterns documented with examples

## Future Expansion

### Adding New Games

1. Follow the established dependency injection pattern
2. Create comprehensive test suite using templates
3. Add game-specific dependencies as needed
4. Maintain visual testing coverage

### Advanced Testing Features

- **Continuous Integration**: Automated test runs on PR
- **Performance Regression Detection**: Alert on performance degradation
- **Visual Regression Testing**: Automated snapshot comparison
- **Device Testing Matrix**: Test on multiple device configurations

---

## Implementation Progress

### ✅ Completed Tasks

#### Task 1.1: Identify Target-Specific Dependency Needs (COMPLETED)

**Analysis Results:**

- **SharedGameEngine**: HIGH PRIORITY - Has Timer usage and randomization dependencies
- **ClausyTheCloud**: MEDIUM PRIORITY - Has Timer usage in ContentView and creates ClausyGameEngine internally
- **SharedAssets**: NO DEPENDENCIES - Only provides static bundle access
- **Test targets**: INDIRECT NEED - Need access to dependency system for controlled testing

**External Dependencies Found:**

- `Timer.scheduledTimer` in ClausyGameEngine:106 (game loop)
- `Timer.scheduledTimer` in ContentView:219,233 (button controls)
- `CGFloat.random(in: -30...30)` in ClausyGameEngine:132 (rain positioning)
- `colors.randomElement()` in ClausyGameEngine:102 (flower colors)

#### Task 1.2: Add swift-dependencies to Required Targets (COMPLETED)

**Changes Made:**

- ✅ Added swift-dependencies v1.9.3 to `Tuist/Package.swift`
- ✅ Added Dependencies to SharedGameEngine target
- ✅ Added Dependencies to ClausyTheCloud target
- ✅ Added Dependencies to SharedGameEngineTests target
- ✅ Added Dependencies to ClausyTheCloudTests target
- ✅ Left SharedAssets unchanged (no external dependencies)

#### Task 1.3: Extract Drawing Components (COMPLETED - SKIPPED)

**Assessment Results:**

- ✅ **NO CODE DUPLICATION EXISTS** - All drawing logic contained in ContentView.swift only
- ✅ Tests focus on game logic, not visual rendering - no drawing code in test files
- ✅ No snapshot tests currently implemented that would duplicate drawing logic
- ✅ Clean single source of truth for Canvas rendering methods

**Decision:** Skip creating GameRenderer component - current architecture is well-organized with proper separation.

#### Task 2.1: Inject Dependencies into ClausyGameEngine (COMPLETED)

**Changes Made:**

- ✅ Created GameClockService with live/preview/test implementations
- ✅ Created GameRandomService with seeded generator support
- ✅ Created TimerService with controllable test implementations
- ✅ Replaced Timer usage in ClausyGameEngine with injected TimerService
- ✅ Replaced random number generation with GameRandomService
- ✅ Updated ClausyGameEngine to use @Dependency property wrappers
- ✅ Implemented GameColor enum for type-safe color handling
- ✅ Project builds successfully with new architecture

**Architecture Benefits:**

- Game engine now fully testable with controlled dependencies
- Deterministic testing possible with seeded generators
- Clean separation between game logic and external dependencies
- Type-safe color operations eliminate runtime errors

#### Task 2.2: Refactor ContentView for Testability (COMPLETED)

**Changes Made:**

- ✅ Refactored ContentView to accept injected ClausyGameEngine instead of creating it internally
- ✅ Added dependency injection for TimerService to replace direct Timer usage in button controls
- ✅ Created dual initializers: default for production, test-friendly for custom engine injection
- ✅ Separated UI state from game state for better testability
- ✅ Updated ClausyTheCloudApp.swift to use simplified ContentView initialization
- ✅ Added `advanceGameLoop()` method to ClausyGameEngine for deterministic testing (DEBUG-only)
- ✅ Updated all failing tests to use dependency injection with controlled dependencies
- ✅ All 12 tests now pass with new architecture

**Architecture Benefits:**

- ContentView now fully testable with controlled dependencies
- Clean separation between UI interactions and game logic
- Timer operations use injected dependencies for consistent testing
- Tests run deterministically without real time delays
- DEBUG-only testing methods excluded from production builds

**Next Steps:** Ready for Phase 3 (Enhanced Testing Features) or Task 2.3/2.4 if additional game logic testing needed.

---

_This document serves as the master plan for iOS testing improvements. Each task should be implemented incrementally with proper testing and documentation._
