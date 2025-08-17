import Dependencies
import SharedGameEngine
import SwiftUI

struct ContentView: View {
    @State private var gameEngine: ClausyGameEngine
    @State private var leftPressed = false
    @State private var rightPressed = false
    @State private var leftTimer: (any GameTimer)?
    @State private var rightTimer: (any GameTimer)?

    @Dependency(\.timerService) var timerService

    // Default initializer for production use
    init() {
        self._gameEngine = State(initialValue: ClausyGameEngine())
    }

    // Test initializer that accepts a custom game engine
    init(gameEngine: ClausyGameEngine) {
        self._gameEngine = State(initialValue: gameEngine)
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Game Canvas
                Canvas { context, size in
                    drawGame(context: context, size: size)
                }
                .background(.cyan.opacity(0.3))
                .onAppear {
                    gameEngine.startGame()
                }
                .onDisappear {
                    gameEngine.stopGame()
                }

                // Win Screen Overlay
                if gameEngine.gameWon {
                    VStack {
                        Text("🌈")
                            .font(.system(size: 100))
                        Text("You Win!")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.yellow)
                        Button("Play Again") {
                            gameEngine.resetGame()
                        }
                        .font(.title2)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.7))
                }

                // Control Buttons
                VStack {
                    Spacer()
                    HStack {
                        Button(
                            action: {},
                            label: {
                                Image(systemName: "arrow.left")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        )
                        .frame(width: 60, height: 60)
                        .background(.gray.opacity(0.7))
                        .clipShape(Circle())
                        .scaleEffect(leftPressed ? 1.2 : 1.0)
                        .onLongPressGesture(
                            minimumDuration: 0,
                            maximumDistance: .infinity,
                            perform: {},
                            onPressingChanged: { pressing in
                                leftPressed = pressing
                                if pressing {
                                    startMovingLeft()
                                } else {
                                    stopMovingLeft()
                                }
                            }
                        )

                        Spacer()

                        Button(
                            action: {},
                            label: {
                                Image(systemName: "arrow.right")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        )
                        .frame(width: 60, height: 60)
                        .background(.gray.opacity(0.7))
                        .clipShape(Circle())
                        .scaleEffect(rightPressed ? 1.2 : 1.0)
                        .onLongPressGesture(
                            minimumDuration: 0,
                            maximumDistance: .infinity,
                            perform: {},
                            onPressingChanged: { pressing in
                                rightPressed = pressing
                                if pressing {
                                    startMovingRight()
                                } else {
                                    stopMovingRight()
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden()
    }

    private func drawGame(context: GraphicsContext, size: CGSize) {
        // Draw plants
        for plant in gameEngine.plants {
            drawPlant(context: context, plant: plant, size: size)
        }

        // Draw cloud
        drawCloud(context: context, cloud: gameEngine.cloud, size: size)

        // Draw rain drops
        for rainDrop in gameEngine.rainDrops {
            drawRainDrop(context: context, rainDrop: rainDrop, size: size)
        }
    }

    private func drawPlant(context: GraphicsContext, plant: Plant, size: CGSize) {
        let scaleX = size.width / 600
        let scaleY = size.height / 800

        // Draw stem
        if plant.height > 0 {
            let stemStart = CGPoint(x: (plant.xPos + 40) * scaleX, y: plant.yPos * scaleY)
            let stemEnd = CGPoint(x: (plant.xPos + 40) * scaleX, y: (plant.yPos - plant.height) * scaleY)

            var path = Path()
            path.move(to: stemStart)
            path.addLine(to: stemEnd)

            context.stroke(path, with: .color(.green), lineWidth: 4)

            // Draw flower petals
            let flowerCenter = CGPoint(x: (plant.xPos + 40) * scaleX, y: (plant.yPos - plant.height) * scaleY)

            for (index, gameColor) in plant.petals.enumerated() {
                let angle = Double(index) / Double(plant.petals.count) * 2 * .pi
                let petalX = flowerCenter.x + cos(angle) * 10 * scaleX
                let petalY = flowerCenter.y + sin(angle) * 10 * scaleY

                context.fill(
                    Path(ellipseIn: CGRect(x: petalX - 6, y: petalY - 6, width: 12, height: 12)),
                    with: .color(colorFromGameColor(gameColor))
                )
            }

            // Draw flower center
            context.fill(
                Path(ellipseIn: CGRect(x: flowerCenter.x - 5, y: flowerCenter.y - 5, width: 10, height: 10)),
                with: .color(.yellow)
            )
        }
    }

    private func drawCloud(context: GraphicsContext, cloud: Cloud, size: CGSize) {
        let scaleX = size.width / 600
        let scaleY = size.height / 800

        let cloudCenter = CGPoint(x: cloud.xPos * scaleX, y: cloud.yPos * scaleY)

        // Draw cloud main body (three circles)
        context.fill(
            Path(ellipseIn: CGRect(x: cloudCenter.x - 30, y: cloudCenter.y - 30, width: 60, height: 60)),
            with: .color(.white)
        )
        context.fill(
            Path(ellipseIn: CGRect(x: cloudCenter.x - 60, y: cloudCenter.y - 20, width: 60, height: 60)),
            with: .color(.white)
        )
        context.fill(
            Path(ellipseIn: CGRect(x: cloudCenter.x, y: cloudCenter.y - 20, width: 60, height: 60)),
            with: .color(.white)
        )

        // Draw cloud eyes
        context.fill(
            Path(ellipseIn: CGRect(x: cloudCenter.x - 20, y: cloudCenter.y - 5, width: 10, height: 10)),
            with: .color(.black)
        )
        context.fill(
            Path(ellipseIn: CGRect(x: cloudCenter.x + 10, y: cloudCenter.y - 5, width: 10, height: 10)),
            with: .color(.black)
        )

        // Draw cloud smile
        var smilePath = Path()
        smilePath.addArc(center: CGPoint(x: cloudCenter.x, y: cloudCenter.y + 5),
                        radius: 10,
                        startAngle: .degrees(0),
                        endAngle: .degrees(180),
                        clockwise: false)
        context.stroke(smilePath, with: .color(.black), lineWidth: 2)
    }

    private func drawRainDrop(context: GraphicsContext, rainDrop: RainDrop, size: CGSize) {
        let scaleX = size.width / 600
        let scaleY = size.height / 800

        context.fill(
            Path(ellipseIn: CGRect(x: rainDrop.xPos * scaleX - 3, y: rainDrop.yPos * scaleY - 3, width: 6, height: 6)),
            with: .color(.cyan)
        )
    }

    private func startMovingLeft() {
        gameEngine.moveCloudLeft()
        Task {
            leftTimer = await timerService.repeatingTimer(0.1) { @MainActor in
                gameEngine.moveCloudLeft()
            }
        }
    }

    private func stopMovingLeft() {
        Task {
            await leftTimer?.invalidate()
            leftTimer = nil
        }
    }

    private func startMovingRight() {
        gameEngine.moveCloudRight()
        Task {
            rightTimer = await timerService.repeatingTimer(0.1) { @MainActor in
                gameEngine.moveCloudRight()
            }
        }
    }

    private func stopMovingRight() {
        Task {
            await rightTimer?.invalidate()
            rightTimer = nil
        }
    }

    private func colorFromGameColor(_ gameColor: GameColor) -> Color {
        switch gameColor {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        }
    }
}

#Preview {
    ContentView()
}
