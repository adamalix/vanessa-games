import Foundation
import Observation
import OSLog
import SwiftUI

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

// MARK: - Game Models

public struct Plant {
    public let xPos: CGFloat
    public let yPos: CGFloat
    public var height: CGFloat
    public var grown: Bool
    public let petals: [Color]

    public init(xPos: CGFloat, yPos: CGFloat, height: CGFloat = 0, grown: Bool = false, petals: [Color]) {
        self.xPos = xPos
        self.yPos = yPos
        self.height = height
        self.grown = grown
        self.petals = petals
    }
}

public struct RainDrop {
    public var xPos: CGFloat
    public var yPos: CGFloat

    public init(xPos: CGFloat, yPos: CGFloat) {
        self.xPos = xPos
        self.yPos = yPos
    }
}

public struct Cloud {
    public var xPos: CGFloat
    public var yPos: CGFloat
    public let width: CGFloat
    public let height: CGFloat
    public let speed: CGFloat

    public init(xPos: CGFloat, yPos: CGFloat, width: CGFloat = 100, height: CGFloat = 60, speed: CGFloat = 5) {
        self.xPos = xPos
        self.yPos = yPos
        self.width = width
        self.height = height
        self.speed = speed
    }
}

// MARK: - Clausy Game Engine

@MainActor
@Observable
public final class ClausyGameEngine {
    public var cloud: Cloud
    public var plants: [Plant] = []
    public var rainDrops: [RainDrop] = []
    public var gameWon = false

    private var gameTimer: Timer?
    private let canvasWidth: CGFloat
    private let canvasHeight: CGFloat
    private let plantCount = 6
    private let plantWidth: CGFloat = 80

    public init(canvasWidth: CGFloat = 600, canvasHeight: CGFloat = 800) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.cloud = Cloud(xPos: canvasWidth / 2, yPos: 100)

        setupPlants()
    }

    private func setupPlants() {
        plants = (0..<plantCount).map { index in
            Plant(
                xPos: CGFloat(index) * (plantWidth + 10) + 30,
                yPos: canvasHeight,
                petals: (0..<5).map { _ in getRandomRainbowColor() }
            )
        }
    }

    private func getRandomRainbowColor() -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
        return colors.randomElement() ?? .red
    }

    public func startGame() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            Task { @MainActor in
                self.gameLoop()
            }
        }
    }

    public func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    private func gameLoop() {
        updateRain()
        updatePlants()
        checkWinCondition()
    }

    private func updateRain() {
        // Move existing rain drops down
        for index in rainDrops.indices {
            rainDrops[index].yPos += 6
        }

        // Add new rain drop
        let newDrop = RainDrop(
            xPos: cloud.xPos + CGFloat.random(in: -30...30),
            yPos: cloud.yPos + 40
        )
        rainDrops.append(newDrop)

        // Remove rain drops that have fallen off screen
        rainDrops.removeAll { $0.yPos > canvasHeight }
    }

    private func updatePlants() {
        guard !gameWon else { return }

        for index in plants.indices {
            if !plants[index].grown && abs(cloud.xPos - (plants[index].xPos + plantWidth / 2)) < plantWidth / 2 {
                plants[index].height += 1
                if plants[index].yPos - plants[index].height <= cloud.yPos + cloud.height / 2 {
                    plants[index].height = plants[index].yPos - cloud.yPos - cloud.height / 2
                    plants[index].grown = true
                }
            }
        }
    }

    private func checkWinCondition() {
        if plants.allSatisfy(\.grown) {
            gameWon = true
        }
    }

    public func moveCloudLeft() {
        let newX = cloud.xPos - cloud.speed
        cloud.xPos = max(cloud.width / 2, min(canvasWidth - cloud.width / 2, newX))
    }

    public func moveCloudRight() {
        let newX = cloud.xPos + cloud.speed
        cloud.xPos = max(cloud.width / 2, min(canvasWidth - cloud.width / 2, newX))
    }

    public func resetGame() {
        gameWon = false
        rainDrops.removeAll()
        cloud.xPos = canvasWidth / 2
        setupPlants()
    }
}
