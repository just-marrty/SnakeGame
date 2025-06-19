//
//  ContentView.swift
//  SnakeGame
//
//  Created by Martin Hrbáček on 19.06.2025.
//

import SwiftUI

struct SnakeGameView: View {
    @StateObject private var settings = SettingsManager()
    @StateObject private var game: SnakeGame
    @StateObject private var audioManager = AudioManager.shared

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
                                .font(.custom("PressStart2P-Regular", size: 15))
                                .foregroundColor(.green.opacity(0.6))
                            Text("\(game.score)")
                                .font(.custom("PressStart2P-Regular", size: 18))
                                .foregroundColor(.green)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("HIGH")
                                .font(.custom("PressStart2P-Regular", size: 15))
                                .foregroundColor(.gray)
                            Text("\(game.highScore)")
                                .font(.custom("PressStart2P-Regular", size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .background(Color.black.opacity(0.5))

                    GeometryReader { geo in
                        let width = geo.size.width - 40
                        let cellSize = floor(width / CGFloat(SnakeGame.columns))
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
                }

                if game.gameState == .gameOver {
                    Color.black.opacity(0.9)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Text("GAME OVER")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .foregroundColor(.red)

                        Text("Final Score: \(game.score)")
                            .font(.custom("PressStart2P-Regular", size: 14))
                            .foregroundColor(.white)

                        VStack(spacing: 12) {
                            Button(action: {
                                audioManager.playEffect("game-start")
                                game.resetGame()
                            }) {
                                Text("PLAY AGAIN")
                                    .font(.custom("PressStart2P-Regular", size: 12))
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
                                    .font(.custom("PressStart2P-Regular", size: 12))
                                    .padding(12)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        let dx = value.translation.width
                        let dy = value.translation.height

                        if abs(dx) > abs(dy) {
                            game.changeDirection(dx > 0 ? Direction.right : Direction.left)
                        } else {
                            game.changeDirection(dy > 0 ? Direction.down : Direction.up)
                        }
                    }
            )
        }
    }
}

#Preview {
    SnakeGameView()
}
