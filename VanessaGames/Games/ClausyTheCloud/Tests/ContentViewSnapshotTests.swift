@testable import ClausyTheCloud
import Dependencies
@testable import SharedGameEngine
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
struct ContentViewSnapshotTests {

    // MARK: - Device-Specific Snapshot Tests

    @Test func testContentViewiPhone13() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13Pro))
        )
    }

    @Test func testContentViewiPhone13Pro() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13Pro))
        )
    }

    @Test func testContentViewiPhone13ProMax() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13ProMax))
        )
    }

    @Test func testContentViewiPadPro11() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPadPro11))
        )
    }

    @Test func testContentViewiPadPro12_9() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPadPro12_9))
        )
    }

    @Test func testContentViewiPadMini() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPadMini))
        )
    }

    // MARK: - Game State Snapshot Tests

    @Test func testWinScreeniPhone13() {
        let gameEngine = createWinStateGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func testWinScreeniPadPro11() {
        let gameEngine = createWinStateGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPadPro11))
        )
    }

    @Test func testGameWithRainDropsiPhone13() {
        let gameEngine = createGameEngineWithRain()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func testGameWithGrownPlantsiPhone13() {
        let gameEngine = createGameEngineWithGrownPlants()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    // MARK: - Dark Mode Tests

    @Test func testContentViewDarkModeiPhone13() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)
            .environment(\.colorScheme, .dark)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func testContentViewDarkModeiPadPro11() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)
            .environment(\.colorScheme, .dark)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPadPro11))
        )
    }

    @Test func testWinScreenDarkModeiPhone13() {
        let gameEngine = createWinStateGameEngine()
        let view = ContentView(gameEngine: gameEngine)
            .environment(\.colorScheme, .dark)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func testGameWithRainDarkModeiPhone13() {
        let gameEngine = createGameEngineWithRain()
        let view = ContentView(gameEngine: gameEngine)
            .environment(\.colorScheme, .dark)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    // MARK: - Orientation Tests

    @Test func testContentViewLandscapeiPhone13() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13(.landscape)))
        )
    }

    @Test func testContentViewLandscapeiPadPro11() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPadPro11(.landscape)))
        )
    }

    @Test func testContentViewDarkModeLandscapeiPhone13() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)
            .environment(\.colorScheme, .dark)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13(.landscape)))
        )
    }

    // MARK: - Accessibility Tests

    @Test func testContentViewLargeTextiPhone13() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func testWinScreenLargeTextiPhone13() {
        let gameEngine = createWinStateGameEngine()
        let view = ContentView(gameEngine: gameEngine)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func testContentViewLargeTextDarkModeiPhone13() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            .environment(\.colorScheme, .dark)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func testContentViewFullAccessibilityiPadPro11() {
        let gameEngine = createTestGameEngine()
        let view = ContentView(gameEngine: gameEngine)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            .environment(\.colorScheme, .dark)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPadPro11))
        )
    }

    // MARK: - Helper Methods

    private func createTestGameEngine() -> ClausyGameEngine {
        withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }
    }

    private func createWinStateGameEngine() -> ClausyGameEngine {
        withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            let engine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
            engine.gameWon = true
            return engine
        }
    }

    private func createGameEngineWithRain() -> ClausyGameEngine {
        withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            let engine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
            // Add some rain drops for visual testing
            engine.rainDrops.append(RainDrop(xPos: 100, yPos: 200))
            engine.rainDrops.append(RainDrop(xPos: 200, yPos: 300))
            engine.rainDrops.append(RainDrop(xPos: 300, yPos: 150))
            return engine
        }
    }

    private func createGameEngineWithGrownPlants() -> ClausyGameEngine {
        withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            let engine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
            // Make some plants partially grown
            engine.plants[0].height = 30
            engine.plants[1].height = 50
            engine.plants[2].height = 20
            engine.plants[3].grown = true
            engine.plants[4].height = 40
            return engine
        }
    }
}
