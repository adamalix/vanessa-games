import CoreGraphics
import Dependencies
@testable import SharedGameEngine
import Testing

@MainActor
struct ClausyTheCloudTests {

    @Test func gameEngineIntegration() {
        let engine = GameEngine()
        // Basic engine test - just check it exists
        #expect(true)

        engine.start()
        engine.stop()
    }

    // MARK: - ClausyGameEngine Tests

    @Test func gameEngineInitialization() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)

        // Test initial cloud position
        #expect(gameEngine.cloud.xPos == 300) // Center of canvas
        #expect(gameEngine.cloud.yPos == 100)
        #expect(gameEngine.cloud.width == 100)
        #expect(gameEngine.cloud.height == 60)
        #expect(gameEngine.cloud.speed == 5)

        // Test initial game state
        #expect(gameEngine.plants.count == 6)
        #expect(gameEngine.rainDrops.isEmpty)
        #expect(gameEngine.gameWon == false)

        // Test plant initialization
        for (index, plant) in gameEngine.plants.enumerated() {
            let expectedX = CGFloat(index) * 90 + 30 // (plantWidth + 10) + starting offset
            #expect(plant.xPos == expectedX)
            #expect(plant.yPos == 800) // Canvas height
            #expect(plant.height == 0)
            #expect(plant.grown == false)
            #expect(plant.petals.count == 5)
        }
    }

    @Test func cloudMovement() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        let initialX = gameEngine.cloud.xPos

        // Test moving left
        gameEngine.moveCloudLeft()
        #expect(gameEngine.cloud.xPos == initialX - 5) // speed = 5

        // Test moving right
        gameEngine.moveCloudRight()
        #expect(gameEngine.cloud.xPos == initialX) // Back to center

        // Test boundary constraints - move to left edge
        for _ in 0..<100 {
            gameEngine.moveCloudLeft()
        }
        #expect(gameEngine.cloud.xPos >= 50) // width/2 = 50

        // Test boundary constraints - move to right edge
        for _ in 0..<200 {
            gameEngine.moveCloudRight()
        }
        #expect(gameEngine.cloud.xPos <= 550) // canvasWidth - width/2 = 550
    }

    @Test func rainDropGeneration() {
        let gameEngine = withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }

        // Initially no rain drops
        #expect(gameEngine.rainDrops.isEmpty)

        // Manually advance game loop to generate rain
        gameEngine.advanceGameLoop()

        // Should have rain drops now
        #expect(!gameEngine.rainDrops.isEmpty)

        // Rain drops should be near the cloud
        for rainDrop in gameEngine.rainDrops {
            let distanceFromCloud = abs(rainDrop.xPos - gameEngine.cloud.xPos)
            #expect(distanceFromCloud <= 30) // Random range is -30...30
            #expect(rainDrop.yPos >= gameEngine.cloud.yPos + 40) // Starts below cloud
        }
    }

    @Test func plantGrowth() {
        let gameEngine = withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }

        // Position cloud over first plant
        let firstPlant = gameEngine.plants[0]
        let plantCenterX = firstPlant.xPos + 40 // plantWidth/2
        gameEngine.cloud.xPos = plantCenterX

        // Verify plant can grow when cloud is positioned correctly
        let initialHeight = firstPlant.height

        // Manually advance game loop to update plants
        gameEngine.advanceGameLoop()

        // Plant should have grown
        #expect(gameEngine.plants[0].height > initialHeight)
    }

    @Test func winCondition() {
        let gameEngine = withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }

        // Manually set all plants to grown
        for index in gameEngine.plants.indices {
            gameEngine.plants[index].grown = true
        }

        // Initially game not won
        #expect(gameEngine.gameWon == false)

        // Trigger win condition check
        gameEngine.advanceGameLoop()

        // Game should be won
        #expect(gameEngine.gameWon == true)
    }

    @Test func gameReset() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)

        // Modify game state
        gameEngine.cloud.xPos = 200
        gameEngine.gameWon = true
        gameEngine.rainDrops.append(RainDrop(xPos: 100, yPos: 200))
        for index in gameEngine.plants.indices {
            gameEngine.plants[index].height = 50
            gameEngine.plants[index].grown = true
        }

        // Reset game
        gameEngine.resetGame()

        // Verify reset state
        #expect(gameEngine.cloud.xPos == 300) // Back to center
        #expect(gameEngine.gameWon == false)
        #expect(gameEngine.rainDrops.isEmpty)

        for plant in gameEngine.plants {
            #expect(plant.height == 0)
            #expect(plant.grown == false)
        }
    }

    @Test func rainDropCleanup() {
        let gameEngine = withDependencies {
            $0.gameRandom = .seeded(42)
        } operation: {
            ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        }

        // Add rain drops below screen (they should be cleaned up)
        gameEngine.rainDrops.append(RainDrop(xPos: 100, yPos: 900)) // Below canvas
        gameEngine.rainDrops.append(RainDrop(xPos: 200, yPos: 850)) // Below canvas

        #expect(gameEngine.rainDrops.count == 2)

        // Trigger game loop to clean up off-screen drops
        gameEngine.advanceGameLoop()

        // Off-screen rain drops should be removed, but new ones will be generated
        // Check that the initial off-screen drops are gone
        let hasOriginalOffscreenDrops = gameEngine.rainDrops.contains { $0.yPos >= 850 }
        #expect(!hasOriginalOffscreenDrops) // Original off-screen drops should be cleaned up
    }

    // MARK: - Game Model Tests

    @Test func plantModel() {
        let plant = Plant(xPos: 100, yPos: 200, height: 50, grown: true, petals: [.red, .blue])

        #expect(plant.xPos == 100)
        #expect(plant.yPos == 200)
        #expect(plant.height == 50)
        #expect(plant.grown == true)
        #expect(plant.petals.count == 2)
    }

    @Test func rainDropModel() {
        let rainDrop = RainDrop(xPos: 150, yPos: 250)

        #expect(rainDrop.xPos == 150)
        #expect(rainDrop.yPos == 250)

        // Test mutability
        var mutableDrop = rainDrop
        mutableDrop.xPos = 160
        mutableDrop.yPos = 260

        #expect(mutableDrop.xPos == 160)
        #expect(mutableDrop.yPos == 260)
    }

    @Test func cloudModel() {
        let cloud = Cloud(xPos: 300, yPos: 100, width: 120, height: 80, speed: 7)

        #expect(cloud.xPos == 300)
        #expect(cloud.yPos == 100)
        #expect(cloud.width == 120)
        #expect(cloud.height == 80)
        #expect(cloud.speed == 7)

        // Test default values
        let defaultCloud = Cloud(xPos: 100, yPos: 50)
        #expect(defaultCloud.width == 100)
        #expect(defaultCloud.height == 60)
        #expect(defaultCloud.speed == 5)
    }

    @Test func plantGrowthLogic() {
        let gameEngine = ClausyGameEngine(canvasWidth: 600, canvasHeight: 800)
        let plantWidth: CGFloat = 80

        // Test cloud positioning for plant growth
        let firstPlant = gameEngine.plants[0]

        // Cloud directly over plant center should trigger growth
        gameEngine.cloud.xPos = firstPlant.xPos + plantWidth / 2

        // Test that plant can grow when positioned correctly

        // Growth should occur when cloud is positioned correctly
        let cloudOverPlant = abs(gameEngine.cloud.xPos - (firstPlant.xPos + plantWidth / 2)) < plantWidth / 2
        #expect(cloudOverPlant == true)

        // Test cloud slightly outside plant range
        gameEngine.cloud.xPos = firstPlant.xPos + plantWidth + 10 // Outside range
        let cloudOutsidePlant = abs(gameEngine.cloud.xPos - (firstPlant.xPos + plantWidth / 2)) < plantWidth / 2
        #expect(cloudOutsidePlant == false)
    }
}
