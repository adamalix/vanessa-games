import XCTest
@testable import SharedGameEngine

@MainActor
final class ClausyTheCloudTests: XCTestCase {

    func testGameEngineIntegration() {
        let engine = GameEngine()
        XCTAssertNotNil(engine)

        engine.start()
        engine.stop()
    }
}
