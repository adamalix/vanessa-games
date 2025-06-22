import Foundation

/// Shared assets and resources for Vanessa Games
public struct SharedAssets: Sendable {

    public init() {}

    public static var bundle: Bundle {
        Bundle(for: BundleToken.self)
    }
}

private final class BundleToken {}
