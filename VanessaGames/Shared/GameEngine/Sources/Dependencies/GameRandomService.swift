import Dependencies
import Foundation

// Forward declaration for GameColor to avoid circular import
public enum GameColor: String, CaseIterable, Sendable {
    case red
    case orange
    case yellow
    case green
    case blue
    case indigo
    case purple
}

/// Service for random number generation in games
public struct GameRandomService: Sendable {
    /// Generate a random double within a range
    public var double: @Sendable (_ range: ClosedRange<Double>) -> Double

    /// Generate a random CGFloat within a range
    public var cgFloat: @Sendable (_ range: ClosedRange<CGFloat>) -> CGFloat

    /// Pick a random element from a string array (for enum-like values)
    public var stringElement: @Sendable ([String]) -> String?

    /// Pick a random GameColor from available colors
    public var gameColorElement: @Sendable ([GameColor]) -> GameColor?

    /// Generate a random boolean
    public var bool: @Sendable () -> Bool

    /// Generate a random integer within a range
    public var int: @Sendable (_ range: ClosedRange<Int>) -> Int

    public init(
        double: @escaping @Sendable (_ range: ClosedRange<Double>) -> Double = { _ in 0.0 },
        cgFloat: @escaping @Sendable (_ range: ClosedRange<CGFloat>) -> CGFloat = { _ in 0.0 },
        stringElement: @escaping @Sendable ([String]) -> String? = { _ in nil },
        gameColorElement: @escaping @Sendable ([GameColor]) -> GameColor? = { _ in nil },
        bool: @escaping @Sendable () -> Bool = { false },
        int: @escaping @Sendable (_ range: ClosedRange<Int>) -> Int = { _ in 0 }
    ) {
        self.double = double
        self.cgFloat = cgFloat
        self.stringElement = stringElement
        self.gameColorElement = gameColorElement
        self.bool = bool
        self.int = int
    }
}

extension GameRandomService: DependencyKey {
    public static let liveValue = Self.live
    public static let testValue = Self()
}

extension DependencyValues {
    public var gameRandom: GameRandomService {
        get { self[GameRandomService.self] }
        set { self[GameRandomService.self] = newValue }
    }
}

// MARK: - Implementations

extension GameRandomService {
    /// Live implementation using system random number generator
    public static let live = Self(
        double: { range in Double.random(in: range) },
        cgFloat: { range in CGFloat.random(in: range) },
        stringElement: { strings in strings.randomElement() },
        gameColorElement: { colors in colors.randomElement() },
        bool: { Bool.random() },
        int: { range in Int.random(in: range) }
    )

    /// Preview implementation with predictable values for SwiftUI previews
    public static let preview = Self(
        double: { range in (range.lowerBound + range.upperBound) / 2 }, // Middle value
        cgFloat: { range in (range.lowerBound + range.upperBound) / 2 }, // Middle value
        stringElement: { strings in strings.first },
        gameColorElement: { colors in colors.first },
        bool: { true },
        int: { range in (range.lowerBound + range.upperBound) / 2 }
    )

    /// Seeded implementation for deterministic testing
    public static func seeded(_ seed: UInt64) -> Self {
        let generator = LockIsolated(SeededRandomNumberGenerator(seed: seed))

        return Self(
            double: { range in
                generator.withValue { Double.random(in: range, using: &$0) }
            },
            cgFloat: { range in
                generator.withValue { CGFloat.random(in: range, using: &$0) }
            },
            stringElement: { strings in
                generator.withValue { strings.randomElement(using: &$0) }
            },
            gameColorElement: { colors in
                generator.withValue { colors.randomElement(using: &$0) }
            },
            bool: {
                generator.withValue { Bool.random(using: &$0) }
            },
            int: { range in
                generator.withValue { Int.random(in: range, using: &$0) }
            }
        )
    }

    /// Predictable implementation that returns specific values for testing
    public static func predictable(
        doubleValue: Double = 0.5,
        cgFloatValue: CGFloat = 0.5,
        elementIndex: Int = 0,
        boolValue: Bool = true,
        intValue: Int = 0
    ) -> Self {
        Self(
            double: { _ in doubleValue },
            cgFloat: { _ in cgFloatValue },
            stringElement: { strings in
                elementIndex < strings.count ? strings[elementIndex] : strings.first
            },
            gameColorElement: { colors in
                elementIndex < colors.count ? colors[elementIndex] : colors.first
            },
            bool: { boolValue },
            int: { _ in intValue }
        )
    }
}

/// A seeded random number generator for deterministic testing
public struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func next() -> UInt64 {
        // Linear congruential generator
        state = state &* 1103515245 &+ 12345
        return state
    }
}
