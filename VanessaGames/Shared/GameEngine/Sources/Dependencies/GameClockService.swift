import Dependencies
import Foundation

/// Service for time-related operations in games
public struct GameClockService: Sendable {
    /// Get the current date/time
    public var now: @Sendable () -> Date

    /// Sleep for a specified duration
    public var sleep: @Sendable (Duration) async throws -> Void

    public init(
        now: @escaping @Sendable () -> Date = { Date() },
        sleep: @escaping @Sendable (Duration) async throws -> Void = { _ in }
    ) {
        self.now = now
        self.sleep = sleep
    }
}

extension GameClockService: DependencyKey {
    public static let liveValue = Self.live
    public static let testValue = Self()
}

extension DependencyValues {
    public var gameClock: GameClockService {
        get { self[GameClockService.self] }
        set { self[GameClockService.self] = newValue }
    }
}

// MARK: - Implementations

extension GameClockService {
    /// Live implementation using real system time
    public static let live = Self(
        now: { Date() },
        sleep: { duration in
            try await Task.sleep(for: duration)
        }
    )

    /// Preview implementation with predictable behavior
    public static let preview = Self(
        now: { Date(timeIntervalSince1970: 1640995200) }, // Fixed date: 2022-01-01
        sleep: { _ in
            // No-op for previews
        }
    )

    /// Test implementation with controlled time
    public static func controlled(startTime: Date = Date()) -> Self {
        let currentTime = LockIsolated(startTime)

        return Self(
            now: { currentTime.value },
            sleep: { duration in
                // Immediately advance time by the sleep duration
                currentTime.withValue {
                    $0 = $0.addingTimeInterval(duration.timeInterval)
                }
            }
        )
    }

    /// Test implementation that tracks time advancement
    public static func tracked() -> TrackedClockService {
        let currentTime = LockIsolated(Date(timeIntervalSince1970: 0))

        let service = Self(
            now: { currentTime.value },
            sleep: { duration in
                currentTime.withValue {
                    $0 = $0.addingTimeInterval(duration.timeInterval)
                }
            }
        )

        let getCurrentTime = { currentTime.value }
        let advance = { interval in
            currentTime.withValue {
                $0 = $0.addingTimeInterval(interval)
            }
        }

        return TrackedClockService(
            service: service,
            getCurrentTime: getCurrentTime,
            advance: advance
        )
    }
}

/// Result type for tracked clock service to avoid large tuple violation
public struct TrackedClockService {
    public let service: GameClockService
    public let getCurrentTime: () -> Date
    public let advance: (TimeInterval) -> Void
}

extension Duration {
    fileprivate var timeInterval: TimeInterval {
        Double(components.seconds) + (Double(components.attoseconds) / 1e18)
    }
}
