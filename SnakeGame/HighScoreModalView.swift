import SwiftUI
import CoreData 

struct HighScoreModalView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var settings = SettingsManager()
    @StateObject private var audioManager = AudioManager.shared
    @ObservedObject var game: SnakeGame
    @State private var isInTop10 = false
    @State private var isLoading = true
    
    let score: Int
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(2.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .snakeGreen))
                    Text("Checking Score...")
                        .font(.custom("Press Start 2P", size: 14))
                        .foregroundColor(.snakeGreen)
                }
            } else if isInTop10 {
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
                            dismiss()
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
            } else {
                // Není v TOP 10, zavři modal a zobraz GAME OVER
                Color.black.ignoresSafeArea()
                    .onAppear {
                        dismiss()
                        game.gameState = .gameOver
                    }
            }
        }
        .task {
            checkIfInTop10()
        }
    }
    
    private func checkIfInTop10() {
        CloudKitManager.fetchTopScores { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let topScores):
                    let sortedScores = topScores.sorted { $0.score > $1.score }
                    let top10 = Array(sortedScores.prefix(10))
                    let playerName = settings.playerName
                    
                    if !playerName.isEmpty {
                        let existing = top10.first(where: { $0.player == playerName })
                        let qualifies = top10.count < 10 || score > (top10.last?.score ?? 0)
                        
                        if (existing != nil && score > (existing?.score ?? 0)) || (existing == nil && qualifies) {
                            isInTop10 = true
                            // ULOŽ SKÓRE DO CLOUDKITU!
                            updateScoreInCloudKit(playerName: playerName, score: score)
                        } else {
                            isInTop10 = false
                            // I tak ulož skóre (pokud je lepší než předchozí)
                            updateScoreInCloudKit(playerName: playerName, score: score)
                        }
                    } else {
                        isInTop10 = false
                    }
                    
                    // Přidání zpoždění
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isLoading = false
                    }
                case .failure:
                    isInTop10 = false
                    // I při chybě zpoždění
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isLoading = false
                    }
                }
            }
        }
    }
    
    private func updateScoreInCloudKit(playerName: String, score: Int) {
        // Ulož do CoreData
        let fetchRequest: NSFetchRequest<HighScore> = HighScore.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerName == %@", playerName)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            
            if let existing = results.first {
                if score > existing.score {
                    existing.score = Int16(score)
                    existing.date = Date()
                }
            } else {
                let newHighScore = HighScore(context: viewContext)
                newHighScore.id = UUID()
                newHighScore.playerName = playerName
                newHighScore.score = Int16(score)
                newHighScore.date = Date()
            }
            
            try viewContext.save()
            
            // Ulož do CloudKit
            CloudKitManager.saveHighScore(playerName: playerName, score: score) { result in
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
    HighScoreModalView(
        game: SnakeGame(settings: SettingsManager()),
        score: 1500,
    )
    .environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
}
