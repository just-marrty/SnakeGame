import SwiftUI
import AVFoundation

extension Notification.Name {
    static let highScoreReset = Notification.Name("highScoreReset")
}

struct DashboardView: View {
    @State private var showingGame = false
    @State private var showingSettings = false
    @State private var showingLeaderboard = false
    @State private var showingFAQ = false
    @AppStorage("SnakeHighScore") private var highScore = 0
    @StateObject private var settings = SettingsManager()
    @StateObject private var audioManager = AudioManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 50/255, green: 35/255, blue: 20/255).ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    VStack(spacing: 20) {
                        Image("snake")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .shadow(color: .green.opacity(0.5), radius: 10)

                        Text("SNAKE GAME")
                            .font(.custom("PressStart2P-Regular", size: 22))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(spacing: 20) {
                        Button(action: {
                            audioManager.playEffect("forward") {
                                showingLeaderboard = true
                            }
                        }) {
                            Text("LEADERBOARD")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        
                        Button(action: {
                            audioManager.stopBackgroundMusic()
                            audioManager.playEffect("game-start") {
                                showingGame = true
                            }
                        }) {
                            Text("START GAME")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.snakeGreen)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.snakeGreen, lineWidth: 2)
                                )
                        }
                        
                        Button(action: {
                            audioManager.playEffect("forward") {
                                showingSettings = true
                            }
                        }) {
                            Text("SETTINGS")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        
                        Button(action: {
                            audioManager.playEffect("forward") {
                                showingFAQ = true
                            }
                        }) {
                            Text("FAQ")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }

                    }
                    .padding(.horizontal, 40)

                    VStack(spacing: 10) {
                        Text("HIGH SCORE")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.7))

                        Text("\(highScore)")
                            .font(.custom("PressStart2P-Regular", size: 18))
                            .foregroundColor(Color.snakeGreen)
                    }
                    .padding(.top, 20)

                    Spacer()

                    Text("Swipe to control the snake")
                        .font(.custom("PressStart2P-Regular", size: 10))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 20)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showingGame) {
            SnakeGameView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings)
        }
        .onAppear {
            if settings.soundEnabled && !audioManager.isBackgroundMusicPlaying {
                audioManager.playBackgroundMusic("main-menu")
            }
        }
        .onChange(of: settings.soundEnabled) { _, newValue in
            if newValue {
                if !audioManager.isBackgroundMusicPlaying {
                    audioManager.playBackgroundMusic("main-menu")
                }
            } else {
                audioManager.stopAllSounds()
            }
        }
        .onChange(of: showingGame) { _, isShowing in
            if !isShowing && settings.soundEnabled && !audioManager.isBackgroundMusicPlaying {
                audioManager.playBackgroundMusic("main-menu")
            }
        }
        .onChange(of: showingSettings) { _, isShowing in
            if !isShowing && settings.soundEnabled && !audioManager.isBackgroundMusicPlaying {
                audioManager.playBackgroundMusic("main-menu")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .highScoreReset)) { _ in
            // highScore se aktualizuje automaticky díky @AppStorage
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardView()
        }
        .sheet(isPresented: $showingFAQ) {
            FAQView()
        }
    }
}

#Preview {
    DashboardView()
}
