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
    @State private var isStartingGame = false
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
                            .padding(.bottom, 10)
                    }

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
                            isStartingGame = true
                            audioManager.stopBackgroundMusic()
                            audioManager.playEffect("game-start") {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    showingGame = true
                                    isStartingGame = false
                                }
                            }
                        }) {
                            ZStack {
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
                                    .opacity(isStartingGame ? 0 : 1)
                                
                                if isStartingGame {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .snakeGreen))
                                }
                            }
                        }
                        .disabled(isStartingGame)
                        
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
                        Text("PLAYER")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.7))

                        Text(settings.playerName.isEmpty ? "..." : settings.playerName)
                            .font(.custom("PressStart2P-Regular", size: 13))
                            .foregroundColor(.snakeGreen)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text("HIGH SCORE")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 20)

                        Text("\(highScore)")
                            .font(.custom("PressStart2P-Regular", size: 13))
                            .foregroundColor(Color.snakeGreen)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 20)

                    VStack(spacing: 8) {
                        Text("Snake Game version 1.0")
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.white.opacity(0.5))

                        (
                            Text("by ")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.5))
                            +
                            Text("just_marrty")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.5))
                                .underline()
                        )
                        .onTapGesture {
                            if let url = URL(string: "https://www.moje-webovka.cz/") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showingGame) {
            SnakeGameView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings)
                .presentationBackground(.black)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .presentationBackground(.black)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingFAQ) {
            FAQView()
                .presentationBackground(.black)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
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
    }
}

#Preview {
    DashboardView()
}
