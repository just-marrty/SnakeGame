import SwiftUI
import AVFoundation
import UIKit
import AudioToolbox

// MARK: - Game Models
struct Position: Equatable, Hashable {
    let x: Int
    let y: Int
}

enum Direction {
    case up, down, left, right
}

enum GameState {
    case playing, paused, gameOver
}

// MARK: - Snake Game Logic
class SnakeGame: ObservableObject {
    static let columns = 20
    static let rows = 35

    @Published var snake: [Position] = [
        Position(x: 10, y: 10), // hlava
        Position(x: 9, y: 10),  // tělo
        Position(x: 8, y: 10)   // ocas
    ]
    @Published var foods: [Position] = []
    @Published var direction: Direction = .right
    @Published var gameState: GameState = .playing
    @Published var score: Int = 0
    @AppStorage("SnakeHighScore") var highScore: Int = 0

    var settings: SettingsManager
    private let audioManager = AudioManager.shared

    private var timer: Timer?
    private var gameSpeed: TimeInterval = 0.20
    private var elapsedTime: TimeInterval = 0
    private var nextSpeedIncreaseTime: TimeInterval = 20
    private var speedSteps: [TimeInterval] = [0.15, 0.12, 0.10, 0.08]
    private var currentSpeedStep = 0

    init(settings: SettingsManager) {
        self.settings = settings
        generateFood()
        startGame()
    }

    func startGame() {
        gameState = .playing
        elapsedTime = 0
        scheduleTimer()
    }

    private func scheduleTimer() {
        timer?.invalidate()
        let safeGameSpeed = max(gameSpeed, 0.01) // Ensure minimum safe interval
        timer = Timer.scheduledTimer(withTimeInterval: safeGameSpeed, repeats: true) { _ in
            self.elapsedTime += self.gameSpeed
            self.moveSnake()
            self.checkForSpeedIncrease()
        }
    }

    private func checkForSpeedIncrease() {
        if elapsedTime >= nextSpeedIncreaseTime,
           currentSpeedStep < speedSteps.count {
            gameSpeed = max(speedSteps[currentSpeedStep], 0.01) // Ensure minimum safe speed
            currentSpeedStep += 1
            nextSpeedIncreaseTime += currentSpeedStep == 1 ? 40 : 50
            scheduleTimer()
        }
    }

    func pauseGame() {
        gameState = .paused
        timer?.invalidate()
        timer = nil
    }

    func resumeGame() {
        if gameState == .paused {
            gameState = .playing
            scheduleTimer()
        }
    }

    func resetGame() {
        elapsedTime = 0
        snake = [
            Position(x: 10, y: 10), // hlava
            Position(x: 9, y: 10),  // tělo
            Position(x: 8, y: 10)   // ocas
        ]
        direction = .right
        score = 0
        foods = []
        generateFood()
        gameState = .playing
        gameSpeed = 0.2
        currentSpeedStep = 0
        nextSpeedIncreaseTime = 20
        scheduleTimer()
    }

    func changeDirection(_ newDirection: Direction) {
        switch (direction, newDirection) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            return
        default:
            direction = newDirection
        }
    }

    private func triggerVibration(_ type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        if settings.vibrationEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        }
    }

    private func feedback(_ sound: String, type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        if settings.soundEnabled {
            audioManager.playEffect(sound)
        }
        if settings.vibrationEnabled {
            triggerVibration(type)
        }
    }

    private func gameOver() {
        gameState = .gameOver
        timer?.invalidate()
        timer = nil
        feedback("game-over", type: .error)
    }

    private func moveSnake() {
        guard gameState == .playing else { return }

        if foods.isEmpty {
            generateFood()
            return
        }

        let head = snake.first!
        var newHead: Position

        switch direction {
        case .up: newHead = Position(x: head.x, y: head.y - 1)
        case .down: newHead = Position(x: head.x, y: head.y + 1)
        case .left: newHead = Position(x: head.x - 1, y: head.y)
        case .right: newHead = Position(x: head.x + 1, y: head.y)
        }

        if newHead.x < 0 || newHead.x >= SnakeGame.columns ||
            newHead.y < 0 || newHead.y >= SnakeGame.rows ||
            snake.contains(newHead) {
            gameOver()
            return
        }

        snake.insert(newHead, at: 0)

        if let eatenIndex = foods.firstIndex(of: newHead) {
            score += 10
            foods.remove(at: eatenIndex)
            feedback("eaten", type: .success)

            if score > highScore {
                highScore = score
            }

            if foods.isEmpty {
                generateFood()
            }
        } else {
            snake.removeLast()
        }
    }

    private func generateFood() {
        let foodCount: Int
        if elapsedTime >= 80 {
            foodCount = 3
        } else if elapsedTime >= 40 {
            foodCount = 2
        } else {
            foodCount = 1
        }

        var newFoods: [Position] = []
        var attempts = 0

        while newFoods.count < foodCount && attempts < 100 {
            let newFood = Position(
                x: Int.random(in: 0..<SnakeGame.columns),
                y: Int.random(in: 0..<SnakeGame.rows)
            )
            if !snake.contains(newFood) && !newFoods.contains(newFood) {
                newFoods.append(newFood)
            }
            attempts += 1
        }

        self.foods = newFoods
    }
}

// Funkce pro přehrávání zvuků v ContentView
func playSound(_ sound: String) {
    AudioManager.shared.playEffect(sound)
}
