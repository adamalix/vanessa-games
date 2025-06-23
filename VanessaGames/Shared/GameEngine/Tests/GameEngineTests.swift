@testable import SharedGameEngine
import Testing

@MainActor
struct GameEngineTests {

    @Test func gameEngineInitialization() {
        let engine = GameEngine()
        #expect(engine != nil)
    }

    @Test func gameEngineStartStop() {
        let engine = GameEngine()

        // These should not crash
        engine.start()
        engine.stop()
    }
}
