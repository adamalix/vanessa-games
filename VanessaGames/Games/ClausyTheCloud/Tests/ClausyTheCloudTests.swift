@testable import SharedGameEngine
import Testing

@MainActor
struct ClausyTheCloudTests {

    @Test func gameEngineIntegration() {
        let engine = GameEngine()
        #expect(engine != nil)

        engine.start()
        engine.stop()
    }
}
