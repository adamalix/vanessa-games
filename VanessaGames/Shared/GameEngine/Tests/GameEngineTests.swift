import Testing
@testable import SharedGameEngine

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
