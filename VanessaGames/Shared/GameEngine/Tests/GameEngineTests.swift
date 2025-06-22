import XCTest
@testable import SharedGameEngine

@MainActor
final class GameEngineTests: XCTestCase {

    func testGameEngineInitialization() {
        let engine = GameEngine()
        XCTAssertNotNil(engine)
    }

    func testGameEngineStartStop() {
        let engine = GameEngine()

        // These should not crash
        engine.start()
        engine.stop()
    }
}
