//
//  ContentView.swift
//  SnakeGame
//
//  Created by Martin Hrbáček on 19.06.2025.
//

import SwiftUI
import CoreData

struct SnakeGameView: View {
    @StateObject private var settings = SettingsManager()
    @StateObject private var game: SnakeGame
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingNameInput = false
    @Environment(\.managedObjectContext) private var viewContext

    init() {
        let settingsManager = SettingsManager()
        _settings = StateObject(wrappedValue: settingsManager)
        _game = StateObject(wrappedValue: SnakeGame(settings: settingsManager))
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 50/255, green: 35/255, blue: 20/255)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SCORE")
                                .font(.custom("Press Start 2P", size: 15))
                                .foregroundColor(.green.opacity(0.6))
                            Text("\(game.score)")
                                .font(.custom("Press Start 2P", size: 18))
                                .foregroundColor(.green)
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
                    .background(Color.black.opacity(0.5))

                    GeometryReader { geo in
                        let width = max(geo.size.width - 40, 1)
                        let cellSize = max(floor(width / CGFloat(SnakeGame.columns)), 1)
                        let playableWidth = cellSize * CGFloat(SnakeGame.columns)
                        let playableHeight = cellSize * CGFloat(SnakeGame.rows)

                        ZStack {
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.green, lineWidth: 2)
                                .frame(width: playableWidth, height: playableHeight)

                            VStack(spacing: 0) {
                                ForEach(0..<SnakeGame.rows, id: \.self) { y in
                                    HStack(spacing: 0) {
                                        ForEach(0..<SnakeGame.columns, id: \.self) { x in
                                            let position = Position(x: x, y: y)
                                            ZStack {
                                                if game.foods.contains(position) {
                                                    Rectangle().fill(Color.red)
                                                } else if game.snake.first == position {
                                                    Rectangle().fill(Color.green)
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
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    Spacer().frame(height: 70)
                }

                // Spodní panel s tlačítky - absolutně u spodního okraje
                VStack {
                    Spacer()
                    ZStack {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea(edges: .bottom)
                        HStack(spacing: 20) {
                            Button(action: {
                                if game.gameState == .playing {
                                    game.pauseGame()
                                } else if game.gameState == .paused {
                                    game.resumeGame()
                                }
                            }) {
                                Image(systemName: game.gameState == .playing ? "pause.fill" : "play.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .padding(12)
                                    .foregroundColor(.black)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 0))
                            }
                            .disabled(game.gameState == .gameOver)

                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .padding(12)
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 0))
                            }
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 20)
                    }
                    .frame(maxWidth: .infinity, minHeight: 70, maxHeight: 103)
                }
                .ignoresSafeArea(edges: .bottom)

                if game.gameState == .gameOver {
                    Color.black.opacity(0.9)
                        .ignoresSafeArea()

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
                                    .background(Color.green)
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
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        let dx = value.translation.width
                        let dy = value.translation.height

                        if abs(dx) > abs(dy) {
                            game.changeDirection(dx > 0 ? Direction.right : Direction.left)
                        } else {
                            game.changeDirection(dy > 0 ? Direction.down : Direction.up)
                        }
                    }
                    .onEnded { _ in
                        // Clear any pending gesture state
                    }
            )
            // Sheet pro zadání jména - pouze pro TOP 10
            .sheet(isPresented: $showingNameInput) {
                NameInputView(score: game.score)
            }
        }
        .onChange(of: game.gameState) { _, newState in
            if newState == .gameOver {
                checkIfInTop10()
            }
        }
    }
    
    // Funkce pro kontrolu, zda je skóre v TOP 10
    private func checkIfInTop10() {
        guard game.score > 0 else { return } // Don't check for zero scores
        
        let fetchRequest: NSFetchRequest<HighScore> = HighScore.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HighScore.score, ascending: false)]
        fetchRequest.fetchLimit = 10
        
        do {
            let topScores = try viewContext.fetch(fetchRequest)
            
            // Pokud je méně než 10 skóre nebo je aktuální skóre vyšší než 10. nejlepší
            if topScores.count < 10 || game.score > (topScores.last?.score ?? 0) {
                print("Score \(game.score) is in TOP 10! Showing NameInputView")
                showingNameInput = true
            } else {
                print("Score \(game.score) is NOT in TOP 10. Not showing NameInputView")
            }
        } catch {
            print("Error fetching top scores: \(error)")
            // Don't show name input if there's an error
        }
    }
}

#Preview {
    SnakeGameView()
}
