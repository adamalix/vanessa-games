import Testing
@testable import SharedGameEngine

@MainActor
struct ClausyTheCloudTests {

    @Test func gameEngineIntegration() {
        let engine = GameEngine()
        #expect(engine != nil)

        engine.start()
        engine.stop()
    }
}
