import Foundation

/// Core game engine for Vanessa Games
@MainActor
public final class GameEngine: Sendable {

    public init() {}

    public func start() {
        print("Game Engine Started")
    }

    public func stop() {
        print("Game Engine Stopped")
    }
}
