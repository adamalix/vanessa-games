import Dependencies
import Foundation

/// A protocol representing a controllable timer
public protocol GameTimer: Sendable {
    func invalidate() async
}

/// Service for creating and managing timers in games
public struct TimerService: Sendable {
    /// Create a repeating timer with a given interval and action
    public var repeatingTimer: @Sendable (
        _ interval: TimeInterval,
        _ action: @escaping @Sendable () async -> Void
    ) async -> any GameTimer

    /// Create a one-shot timer with a given delay and action
    public var delayedAction: @Sendable (
        _ delay: TimeInterval,
        _ action: @escaping @Sendable () async -> Void
    ) async -> any GameTimer

    public init(
        repeatingTimer: @escaping @Sendable (
            _ interval: TimeInterval,
            _ action: @escaping @Sendable () async -> Void
        ) async -> any GameTimer = { _, _ in NoOpTimer() },
        delayedAction: @escaping @Sendable (
            _ delay: TimeInterval,
            _ action: @escaping @Sendable () async -> Void
        ) async -> any GameTimer = { _, _ in NoOpTimer() }
    ) {
        self.repeatingTimer = repeatingTimer
        self.delayedAction = delayedAction
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

/// A real timer wrapper for production use
public actor RealTimer: GameTimer {
    private var timer: Timer?
    private let action: @Sendable () async -> Void

    init(interval: TimeInterval, repeats: Bool, action: @escaping @Sendable () async -> Void) {
        self.action = action

        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { _ in
            Task { await action() }
        }
    }

    public func invalidate() async {
        timer?.invalidate()
        timer = nil
    }
}

/// A controllable timer for testing
public actor TestTimer: GameTimer {
    private let action: @Sendable () async -> Void
    private let interval: TimeInterval
    private let repeats: Bool
    private var isValid = true

    init(interval: TimeInterval, repeats: Bool, action: @escaping @Sendable () async -> Void) {
        self.action = action
        self.interval = interval
        self.repeats = repeats
    }

    public func invalidate() async {
        isValid = false
    }

    /// Manually fire the timer (for testing)
    public func fire() async {
        guard isValid else { return }
        await action()
        if !repeats {
            isValid = false
        }
    }

    /// Check if timer is still valid
    public func isValidTimer() async -> Bool {
        isValid
    }

    public var timerInterval: TimeInterval { interval }
    public var isRepeating: Bool { repeats }
}

// MARK: - Service Implementations

extension TimerService {
    /// Live implementation using real Foundation timers
    public static let live = Self(
        repeatingTimer: { interval, action in
            RealTimer(interval: interval, repeats: true, action: action)
        },
        delayedAction: { delay, action in
            RealTimer(interval: delay, repeats: false, action: action)
        }
    )

    /// Preview implementation with no-op timers
    public static let preview = Self(
        repeatingTimer: { _, _ in NoOpTimer() },
        delayedAction: { _, _ in NoOpTimer() }
    )

    /// Test implementation with controllable timers
    public static func controlled(
        onTimerCreated: @escaping @Sendable (TestTimer) async -> Void = { _ in }
    ) -> Self {
        Self(
            repeatingTimer: { interval, action in
                let timer = TestTimer(interval: interval, repeats: true, action: action)
                await onTimerCreated(timer)
                return timer
            },
            delayedAction: { delay, action in
                let timer = TestTimer(interval: delay, repeats: false, action: action)
                await onTimerCreated(timer)
                return timer
            }
        )
    }

    /// Immediate execution implementation for fast tests
    public static let immediate = Self(
        repeatingTimer: { _, action in
            await action()
            return NoOpTimer()
        },
        delayedAction: { _, action in
            await action()
            return NoOpTimer()
        }
    )
}
