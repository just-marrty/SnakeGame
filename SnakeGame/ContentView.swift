//
//  ContentView.swift
//  SnakeGame
//

import SwiftUI
import CoreData
import CloudKit

struct SnakeGameView: View {
    @StateObject private var settings = SettingsManager()
    @StateObject private var game: SnakeGame
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingNameInput = false
    @State private var showingExitConfirmation = false
    @State private var showHighScoreAlert = false
    @State private var newHighScoreValue: Int?
    @State private var playerEnteredTop10 = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    init() {
        let settingsManager = SettingsManager()
        _settings = StateObject(wrappedValue: settingsManager)
        _game = StateObject(wrappedValue: SnakeGame(settings: settingsManager))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 50/255, green: 35/255, blue: 20/255)
                    .ignoresSafeArea()

                // HRA
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SCORE")
                                .font(.custom("Press Start 2P", size: 15))
                                .foregroundColor(.green.opacity(0.6))
                            Text("\(game.score)")
                                .font(.custom("Press Start 2P", size: 18))
                                .foregroundColor(Color.snakeGreen)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("HIGH")
                                .font(.custom("Press Start 2P", size: 15))
                                .foregroundColor(.gray)
                            Text("\(game.highScore)")
                                .font(.custom("Press Start 2P", size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .background(Color.black.opacity(0.3))

                    GeometryReader { geo in
                        let width = max(geo.size.width - 40, 1)
                        let cellSize = max(floor(width / CGFloat(SnakeGame.columns)), 1)
                        let playableWidth = cellSize * CGFloat(SnakeGame.columns)
                        let playableHeight = cellSize * CGFloat(SnakeGame.rows)

                        ZStack {
                            Color.black.opacity(0.3).ignoresSafeArea(edges: .bottom)
                            VStack(spacing: 0) {
                                ForEach(0..<SnakeGame.rows, id: \.self) { y in
                                    HStack(spacing: 0) {
                                        ForEach(0..<SnakeGame.columns, id: \.self) { x in
                                            let lightBrown = Color(red: 70/255, green: 50/255, blue: 30/255)
                                            let darkBrown = Color(red: 75/255, green: 55/255, blue: 33/255)
                                            let position = Position(x: x, y: y)

                                            ZStack {
                                                Rectangle()
                                                    .fill((x + y) % 2 == 0 ? lightBrown : darkBrown)

                                                if game.foods.contains(position) {
                                                    Rectangle().fill(Color.red)
                                                } else if game.snake.first == position {
                                                    Rectangle().fill(Color.snakeGreen)
                                                } else if game.snake.contains(position) {
                                                    Rectangle().fill(Color.green.opacity(0.5))
                                                }
                                            }
                                            .frame(width: cellSize, height: cellSize)
                                        }
                                    }
                                }
                            }
                            .frame(width: playableWidth, height: playableHeight)

                            Rectangle()
                                .stroke(Color.snakeGreen, lineWidth: 4)
                                .frame(width: playableWidth, height: playableHeight)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    Spacer().frame(height: 69)
                }

                // BOTTOM BAR
                VStack {
                    Spacer()
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea(edges: .bottom)
                        HStack(spacing: 20) {
                            Button(action: {
                                if settings.soundEnabled { audioManager.playEffect("check") }
                                if game.gameState == .playing {
                                    game.pauseGame()
                                } else if game.gameState == .paused {
                                    game.resumeGame()
                                }
                            }) {
                                Image(game.gameState == .playing ? "pause" : "play")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .padding(12)
                                    .background(Color.snakeGreen)
                            }
                            .disabled(game.gameState == .gameOver)

                            Button(action: {
                                if settings.soundEnabled { audioManager.playEffect("backward") }
                                game.pauseGame()
                                showingExitConfirmation = true
                            }) {
                                Image("close")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .padding(12)
                                    .background(Color.red)
                            }
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 20)
                    }
                    .frame(maxWidth: .infinity, minHeight: 70, maxHeight: 103)
                }
                .ignoresSafeArea(edges: .bottom)

                // GAME OVER SCREEN
                if game.gameState == .gameOver && !showHighScoreAlert {
                    Color.black.opacity(0.9).ignoresSafeArea()
                    VStack(spacing: 20) {
                        Text("GAME OVER")
                            .font(.custom("Press Start 2P", size: 20))
                            .foregroundColor(.red)
                        Text("Final Score: \(game.score)")
                            .font(.custom("Press Start 2P", size: 14))
                            .foregroundColor(.white)
                        VStack(spacing: 12) {
                            Button(action: {
                                audioManager.playEffect("game-start")
                                game.resetGame()
                            }) {
                                Text("PLAY AGAIN")
                                    .font(.custom("Press Start 2P", size: 12))
                                    .padding(12)
                                    .background(Color.snakeGreen)
                                    .foregroundColor(.black)
                            }
                            Button(action: {
                                if settings.soundEnabled {
                                    audioManager.playEffect("backward")
                                } else if settings.vibrationEnabled {
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                }
                                dismiss()
                            }) {
                                Text("MENU")
                                    .font(.custom("Press Start 2P", size: 12))
                                    .padding(12)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }

                // EXIT MODAL
                if showingExitConfirmation {
                    Color.black.opacity(0.8).ignoresSafeArea().zIndex(2)
                    VStack(spacing: 20) {
                        Text("Are you sure?")
                            .font(.custom("Press Start 2P", size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Your game progress will be lost.")
                            .font(.custom("Press Start 2P", size: 10))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        HStack(spacing: 20) {
                            Button(action: {
                                if settings.soundEnabled { audioManager.playEffect("backward") }
                                dismiss()
                            }) {
                                Text("EXIT")
                                    .font(.custom("Press Start 2P", size: 10))
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                            }
                            Button(action: {
                                withAnimation {
                                    if settings.soundEnabled { audioManager.playEffect("forward") }
                                    showingExitConfirmation = false
                                }
                            }) {
                                Text("CONTINUE")
                                    .font(.custom("Press Start 2P", size: 10))
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.snakeGreen)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    .zIndex(3)
                }

                // FULLSCREEN MODAL ALERT
                if showHighScoreAlert, let score = newHighScoreValue {
                    Color.black.opacity(0.95)
                        .ignoresSafeArea()
                        .zIndex(4)

                    VStack(spacing: 24) {
                        Text("NEW HIGH SCORE!")
                            .font(.custom("Press Start 2P", size: 20))
                            .foregroundColor(.yellow)
                            .multilineTextAlignment(.center)

                        Text("You scored with \(score) points in the TOP 10!")
                            .font(.custom("Press Start 2P", size: 12))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        Text("KEEP GOING!")
                            .font(.custom("Press Start 2P", size: 12))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        Button(action: {
                            withAnimation {
                                if settings.soundEnabled {
                                    audioManager.playEffect("forward")
                                }
                                showHighScoreAlert = false
                                game.gameState = .gameOver 
                            }
                        }) {
                            Text("OK")
                                .font(.custom("Press Start 2P", size: 14))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 32)
                                .background(Color.snakeGreen)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                    .zIndex(5)
                }
            }

            // GESTURE
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        let dx = value.translation.width
                        let dy = value.translation.height
                        if abs(dx) > abs(dy) {
                            game.changeDirection(dx > 0 ? .right : .left)
                        } else {
                            game.changeDirection(dy > 0 ? .down : .up)
                        }
                    }
            )
            .sheet(isPresented: $showingNameInput) {
                NameInputView(score: game.score)
            }
        }
        .onChange(of: game.gameState) { _, newState in
            if newState == .gameOver {
                if game.score > 0 {
                    if settings.playerName.isEmpty {
                        showingNameInput = true
                    } else {
                        checkIfInTop10()
                    }
                }
            }
        }
    }

    private func checkIfInTop10() {
        guard game.score > 0 else { return }

        CloudKitManager.fetchTopScores { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let topScores):
                    let sortedScores = topScores.sorted { $0.score > $1.score }
                    let top10 = Array(sortedScores.prefix(10))
                    let playerName = settings.playerName

                    if !playerName.isEmpty {
                        let existing = top10.first(where: { $0.player == playerName })

                        let qualifies = top10.count < 10 || game.score > (top10.last?.score ?? 0)

                        if existing != nil {
                            // Je v top10, zlepšil si pozici?
                            if let current = existing, game.score > current.score {
                                newHighScoreValue = game.score
                                showHighScoreAlert = true
                            }
                        } else if qualifies {
                            // Nový vstup do TOP10
                            newHighScoreValue = game.score
                            showHighScoreAlert = true
                        }
                    }

                    updateScore(for: playerName, newScore: game.score)

                case .failure(let error):
                    print("Chyba při načítání z CloudKit: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateScore(for name: String, newScore scoreValue: Int) {
        let fetchRequest: NSFetchRequest<HighScore> = HighScore.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerName == %@", name)

        do {
            let results = try viewContext.fetch(fetchRequest)

            if let existing = results.first {
                if scoreValue > existing.score {
                    existing.score = Int16(scoreValue)
                    existing.date = Date()
                }
            } else {
                let newHighScore = HighScore(context: viewContext)
                newHighScore.id = UUID()
                newHighScore.playerName = name
                newHighScore.score = Int16(scoreValue)
                newHighScore.date = Date()
            }

            try viewContext.save()

            // ✅ Uložit do CloudKit (pouze touto metodou)
            CloudKitManager.saveHighScore(playerName: name, score: scoreValue) { result in
                switch result {
                case .success:
                    print("Skóre uloženo do CloudKit.")
                case .failure(let error):
                    print("Chyba při ukládání skóre: \(error.localizedDescription)")
                }
            }

        } catch {
            print("Chyba při ukládání skóre: \(error)")
        }
    }
}

#Preview {
    SnakeGameView()
}
