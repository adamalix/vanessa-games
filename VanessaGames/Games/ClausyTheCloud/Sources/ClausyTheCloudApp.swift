import SwiftUI
import SharedGameEngine

@main
struct ClausyTheCloudApp: App {
    let gameEngine = GameEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    gameEngine.start()
                }
                .onDisappear {
                    gameEngine.stop()
                }
        }
    }
}
