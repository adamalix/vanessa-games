import Foundation
import OSLog

/// Core game engine for Vanessa Games
@MainActor
public final class GameEngine {

    static let logger = Logger(subsystem: "com.adamalix.vanessagames.sharedgameengine", category: "GameEngine")
    public init() {}

    public func start() {
        Self.logger.debug("Game Engine Started")
    }

    public func stop() {
        Self.logger.debug("Game Engine Stopped")
    }
}
