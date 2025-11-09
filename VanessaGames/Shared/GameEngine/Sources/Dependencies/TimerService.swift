import Dependencies
import Foundation

/// A protocol representing a controllable timer
public protocol GameTimer: Sendable {
    func invalidate() async
}

/// Service for creating and managing timers in games
public struct TimerService: Sendable {
    /// Create a repeating timer with a given interval and action
    public var repeatingTimer:
        @Sendable (
            _ interval: TimeInterval,
            _ action: @escaping @Sendable () async -> Void
        ) async -> any GameTimer

    public init(
        repeatingTimer:
            @escaping @Sendable (
                _ interval: TimeInterval,
                _ action: @escaping @Sendable () async -> Void
            ) async -> any GameTimer = { _, _ in NoOpTimer() }
    ) {
        self.repeatingTimer = repeatingTimer
    }
}

extension TimerService: DependencyKey {
    public static let liveValue = Self.live
    public static let testValue = Self()
}

extension DependencyValues {
    public var timerService: TimerService {
        get { self[TimerService.self] }
        set { self[TimerService.self] = newValue }
    }
}

// MARK: - Timer Implementations

/// A no-op timer for testing
public struct NoOpTimer: GameTimer {
    public init() {}
    public func invalidate() async {}
}

/// A clock-based timer using swift-dependencies built-in clock
public final class ClockTimer: GameTimer, @unchecked Sendable {
    private let task: Task<Void, Never>

    init(interval: TimeInterval, action: @escaping @Sendable () async -> Void) {
        self.task = Task {
            @Dependency(\.continuousClock) var clock
            let duration = Duration.seconds(interval)
            while !Task.isCancelled {
                try? await clock.sleep(for: duration)
                guard !Task.isCancelled else { break }
                await action()
            }
        }
    }

    public func invalidate() async {
        task.cancel()
    }
}

// MARK: - Service Implementations

extension TimerService {
    /// Live implementation using continuousClock
    public static let live = Self(
        repeatingTimer: { interval, action in
            ClockTimer(interval: interval, action: action)
        }
    )

    /// Test implementation with immediate execution
    public static let immediate = Self(
        repeatingTimer: { _, action in
            await action()
            return NoOpTimer()
        }
    )
}
