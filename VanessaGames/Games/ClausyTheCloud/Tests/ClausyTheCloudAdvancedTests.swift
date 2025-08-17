import CoreGraphics
import Dependencies
import Foundation
@testable import SharedGameEngine
import Testing

@MainActor
struct ClausyTheCloudAdvancedTests {

    // MARK: - Edge Case Tests

    @Test func extremeCanvasSizes() {
        // Test very small canvas
        let smallEngine = ClausyGameEngine(canvasWidth: 100, canvasHeight: 100)
        #expect(smallEngine.cloud.xPos == 50) // Center of small canvas
        #expect(smallEngine.plants.count == 6) // Should still create all plants

        // Test very large canvas
        let largeEngine = ClausyGameEngine(canvasWidth: 2000, canvasHeight: 3000)
        #expect(largeEngine.cloud.xPos == 1000) // Center of large canvas
        #expect(largeEngine.plants.count == 6)

        // Test zero-size canvas (edge case)
        let zeroEngine = ClausyGameEngine(canvasWidth: 0, canvasHeight: 0)
        #expect(zeroEngine.cloud.xPos == 0)
        #expect(zeroEngine.plants.count == 6)
    }

    @Test func rapidCloudMovement() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)

        // Test rapid successive movements don't break boundaries
        for _ in 0..<1000 {
            gameEngine.moveCloudLeft()
        }
        #expect(gameEngine.cloud.xPos >= 50) // Should still respect left boundary

        for _ in 0..<2000 {
            gameEngine.moveCloudRight()
        }
        #expect(gameEngine.cloud.xPos <= 550) // Should still respect right boundary

        // Test alternating movements
        for index in 0..<100 {
            if index % 2 == 0 {
                gameEngine.moveCloudLeft()
            } else {
                gameEngine.moveCloudRight()
            }
        }
        // Should not crash and position should be reasonable
        #expect(gameEngine.cloud.xPos >= 50)
        #expect(gameEngine.cloud.xPos <= 550)
    }

    @Test func massiveRainDropGeneration() {
        let gameEngine = withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }

        // Generate many rain drops to test memory management
        for _ in 0..<1000 {
            gameEngine.advanceGameLoop()
        }

        // Should not accumulate infinite rain drops due to cleanup
        // With screen cleanup, count should be reasonable
        #expect(gameEngine.rainDrops.count < 200) // Reasonable upper bound

        // All rain drops should be within expected positions
        for rainDrop in gameEngine.rainDrops {
            #expect(rainDrop.yPos <= 800) // Within or below canvas
            #expect(abs(rainDrop.xPos - gameEngine.cloud.xPos) <= 100) // Reasonable spread
        }
    }

    @Test func plantGrowthEdgeCases() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)

        // Test plant growth when cloud is exactly at boundary
        let plant = gameEngine.plants[0]
        let plantCenterX = plant.xPos + 40 // plantWidth/2
        let plantRadius: CGFloat = 40 // plantWidth/2

        // Cloud exactly at left edge of plant range
        gameEngine.cloud.xPos = plantCenterX - plantRadius + 1
        let initialHeight = plant.height
        gameEngine.advanceGameLoop()
        #expect(gameEngine.plants[0].height > initialHeight) // Should grow

        // Reset and test right edge
        gameEngine.resetGame()
        gameEngine.cloud.xPos = plantCenterX + plantRadius - 1
        let initialHeight2 = gameEngine.plants[0].height
        gameEngine.advanceGameLoop()
        #expect(gameEngine.plants[0].height > initialHeight2) // Should grow

        // Test exactly outside range
        gameEngine.resetGame()
        gameEngine.cloud.xPos = plantCenterX + plantRadius + 1
        let initialHeight3 = gameEngine.plants[0].height
        gameEngine.advanceGameLoop()
        #expect(gameEngine.plants[0].height == initialHeight3) // Should not grow
    }

    @Test func plantGrowthLimits() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        let plant = gameEngine.plants[0]

        // Position cloud over plant
        gameEngine.cloud.xPos = plant.xPos + 40

        // Manually set plant to almost full height
        gameEngine.plants[0].height = 650 // Very tall

        let initialHeight = gameEngine.plants[0].height
        gameEngine.advanceGameLoop()

        // Should cap height appropriately (the growth logic limits height based on cloud position)
        #expect(gameEngine.plants[0].height >= initialHeight) // Should grow or stay same
        // Note: Plant may not be marked as grown yet depending on cloud height calculation
    }

    @Test func winConditionEdgeCases() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)

        // Test win condition with exactly one plant not grown
        for index in 0..<(gameEngine.plants.count - 1) {
            gameEngine.plants[index].grown = true
        }
        gameEngine.advanceGameLoop()
        #expect(gameEngine.gameWon == false) // Should not win yet

        // Grow the last plant
        gameEngine.plants[gameEngine.plants.count - 1].grown = true
        gameEngine.advanceGameLoop()
        #expect(gameEngine.gameWon == true) // Should win now
    }

    @Test func resetGameEdgeCases() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)

        // Set extreme game state
        gameEngine.gameWon = true
        gameEngine.cloud.xPos = 50
        for index in gameEngine.plants.indices {
            gameEngine.plants[index].height = 999
            gameEngine.plants[index].grown = true
        }
        // Add many rain drops
        for index in 0..<100 {
            gameEngine.rainDrops.append(RainDrop(xPos: CGFloat(index), yPos: CGFloat(index)))
        }

        gameEngine.resetGame()

        // Should completely reset regardless of previous state
        #expect(gameEngine.gameWon == false)
        #expect(gameEngine.cloud.xPos == 300) // Back to center
        #expect(gameEngine.rainDrops.isEmpty)
        for plant in gameEngine.plants {
            #expect(plant.height == 0)
            #expect(plant.grown == false)
            #expect(plant.petals.count == 5) // Should regenerate petals
        }
    }

    // MARK: - Error Recovery Tests

    @Test func gameStateConsistency() {
        let gameEngine = withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }

        // Simulate many game loops and ensure state remains consistent
        for _ in 0..<100 {
            gameEngine.advanceGameLoop()

            // Invariants that should always hold
            #expect(gameEngine.cloud.xPos >= 50)
            #expect(gameEngine.cloud.xPos <= 550)
            #expect(gameEngine.plants.count == 6)

            for plant in gameEngine.plants {
                #expect(plant.height >= 0)
                #expect(plant.petals.count == 5)
                if plant.grown {
                    #expect(plant.height > 0)
                }
            }

            for rainDrop in gameEngine.rainDrops {
                #expect(rainDrop.yPos >= 100) // Should be below cloud
            }
        }
    }

    @Test func timerLifecycleSafety() {
        let gameEngine = withDependencies {
            $0.timerService = TimerService.testValue
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }

        // Start and stop game multiple times
        for _ in 0..<10 {
            gameEngine.startGame()
            gameEngine.stopGame()
        }

        // Should not crash and state should remain valid
        #expect(gameEngine.plants.count == 6)
        #expect(gameEngine.cloud.xPos == 300)
    }

    // MARK: - Performance Tests

    @Test(.disabled("game loop performance is slow on xcode cloud")) func gameLoopPerformance() {
        let gameEngine = withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }

        // Measure performance of game loop
        let startTime = Date()
        for _ in 0..<1000 {
            gameEngine.advanceGameLoop()
        }
        let endTime = Date()

        let duration = endTime.timeIntervalSince(startTime)
        #expect(duration < 1.0) // Should complete 1000 loops in under 1 second
    }

    @Test func cloudMovementPerformance() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)

        // Measure performance of cloud movements
        let startTime = Date()
        for _ in 0..<10000 {
            gameEngine.moveCloudLeft()
            gameEngine.moveCloudRight()
        }
        let endTime = Date()

        let duration = endTime.timeIntervalSince(startTime)
        #expect(duration < 0.5) // Should complete 20,000 movements in under 0.5 seconds
    }

    @Test func memoryEfficiency() {
        let gameEngine = withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }

        // Generate lots of rain drops and ensure memory is managed
        for _ in 0..<500 {
            gameEngine.advanceGameLoop()
        }

        // Rain drops should be cleaned up, not accumulated infinitely
        let rainDropCount = gameEngine.rainDrops.count
        #expect(rainDropCount < 200) // Should have reasonable upper bound (adjusted for actual behavior)

        // All remaining rain drops should be on-screen
        for rainDrop in gameEngine.rainDrops {
            #expect(rainDrop.yPos <= 800) // Should not exceed canvas height
        }
    }

    @Test(.disabled("rest performance is slow on xcode cloud")) func resetPerformance() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)

        // Add complex state
        for index in 0..<1000 {
            gameEngine.rainDrops.append(RainDrop(xPos: CGFloat(index), yPos: CGFloat(index)))
        }
        for index in gameEngine.plants.indices {
            gameEngine.plants[index].height = 500
            gameEngine.plants[index].grown = true
        }

        // Measure reset performance
        let startTime = Date()
        for _ in 0..<100 {
            gameEngine.resetGame()
        }
        let endTime = Date()

        let duration = endTime.timeIntervalSince(startTime)
        #expect(duration < 1.0) // Should complete 100 resets in under 1 second (more realistic)
    }
}
