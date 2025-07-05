import SwiftUI
import CoreData

struct NameInputView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    let score: Int
    @State private var playerName = ""
    @State private var alertMessage = "Please enter a valid name."
    @State private var isTop10 = false
    @State private var isLoaded = false
    @State private var isSaving = false
    @FocusState private var nameFieldFocused: Bool
    @StateObject private var settings = SettingsManager()

    @State private var showCustomAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if isLoaded {
                    VStack(spacing: 30) {
                        Text(isTop10 ? "YOU'RE IN TOP 10!" : "KEEP GOING!")
                            .font(.custom("Press Start 2P", size: 16))
                            .foregroundColor(isTop10 ? .yellow : .white)
                            .padding(.top, 20)

                        if isTop10 {
                            Text("Score: \(score)")
                                .font(.custom("Press Start 2P", size: 14))
                                .foregroundColor(.white)
                        } else {
                            Text("Enter your name to compete with others!")
                                .font(.custom("Press Start 2P", size: 12))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }

                        VStack(spacing: 15) {
                            Text("You cannot edit your name later. Choose wisely!")
                                .font(.custom("Press Start 2P", size: 12))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                                .lineSpacing(4)

                            Text("Enter your name:")
                                .font(.custom("Press Start 2P", size: 12))
                                .foregroundColor(.white.opacity(0.8))

                            TextField("Player name...", text: $playerName)
                                .font(.custom("Press Start 2P", size: 12))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(6)
                                .textFieldStyle(PlainTextFieldStyle())
                                .focused($nameFieldFocused)
                                .onSubmit {
                                    saveScore()
                                }
                        }
                        .padding(.horizontal, 40)

                        Spacer()

                        HStack(spacing: 20) {
                            Button("SKIP") {
                                dismiss()
                            }
                            .font(.custom("Press Start 2P", size: 10))
                            .foregroundColor(.gray)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.gray, lineWidth: 1)
                            )

                            Button("SAVE") {
                                isSaving = true
                                saveScore()
                            }
                            .font(.custom("Press Start 2P", size: 10))
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.snakeGreen)
                            .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.bottom, 20)
                    }
                } else {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(2.0)
                            .progressViewStyle(CircularProgressViewStyle(tint: .snakeGreen))

                        Text("Checking Score...")
                            .font(.custom("Press Start 2P", size: 14))
                            .foregroundColor(.snakeGreen)
                    }
                }

                // MARK: - Custom Alert
                if showCustomAlert {
                    VStack(spacing: 20) {
                        Text("Oops!")
                            .font(.custom("Press Start 2P", size: 16))
                            .foregroundColor(.yellow)

                        Text(alertMessage)
                            .font(.custom("Press Start 2P", size: 12))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineSpacing(4)

                        Button("OK") {
                            withAnimation {
                                showCustomAlert = false
                            }
                        }
                        .font(.custom("Press Start 2P", size: 12))
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.snakeGreen)
                        .cornerRadius(0)
                    }
                    .padding()
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.snakeGreen, lineWidth: 2)
                    )
                    .padding(.horizontal, 40)
                    .zIndex(10)
                }
                
                // Loading overlay uprostřed
                if isSaving {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(2.0)
                            .progressViewStyle(CircularProgressViewStyle(tint: .snakeGreen))
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            nameFieldFocused = true

            CloudKitManager.fetchTopScores { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let cloudScores):
                        let minTopScore = cloudScores.map { $0.score }.min() ?? 0
                        self.isTop10 = self.score > minTopScore
                    case .failure(let error):
                        print("Error checking TOP10 eligibility: \(error)")
                        self.isTop10 = false
                    }
                    // Přidání 1.5 sekundového zpoždění (stejně jako v HighScoreModalView)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.isLoaded = true
                    }
                }
            }
        }
    }

    private func saveScore() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            alertMessage = "Please enter a name."
            showCustomAlert = true
            isSaving = false  // ← Zastaví loading při chybě
            return
        }

        CloudKitManager.isPlayerNameTaken(trimmedName) { exists in
            DispatchQueue.main.async {
                if exists {
                    alertMessage = "This name already exists. Please choose a different one."
                    showCustomAlert = true
                    isSaving = false  // ← Zastaví loading při chybě
                    return
                }

                let finalName = String(trimmedName.prefix(20))
                settings.playerName = finalName

                let fetchRequest: NSFetchRequest<HighScore> = HighScore.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "playerName == %@", finalName)

                do {
                    let existingScores = try viewContext.fetch(fetchRequest)

                    if let existing = existingScores.first {
                        if score > existing.score {
                            existing.score = Int16(score)
                            existing.date = Date()
                            try viewContext.save()
                            UserDefaults.standard.set(finalName, forKey: "LastEnteredPlayerName")
                        }
                        isSaving = false  // ← Zastaví loading před zavřením
                        dismiss()
                        return
                    }

                    let topFetch: NSFetchRequest<HighScore> = HighScore.fetchRequest()
                    topFetch.sortDescriptors = [NSSortDescriptor(keyPath: \HighScore.score, ascending: false)]
                    topFetch.fetchLimit = 10
                    let topScores = try viewContext.fetch(topFetch)

                    let minTopScore = topScores.map { Int($0.score) }.min() ?? 0

                    if score > minTopScore {
                        let newScore = HighScore(context: viewContext)
                        newScore.id = UUID()
                        newScore.playerName = finalName
                        newScore.score = Int16(score)
                        newScore.date = Date()
                        try viewContext.save()

                        CloudKitManager.saveHighScore(playerName: finalName, score: score) { result in
                            DispatchQueue.main.async {
                                isSaving = false  // ← Zastaví loading před zavřením
                                dismiss()
                            }
                        }
                    } else {
                        isSaving = false  // ← Zastaví loading před zavřením
                        dismiss()
                    }

                } catch {
                    alertMessage = "Unexpected error while saving score."
                    showCustomAlert = true
                    isSaving = false  // ← Zastaví loading při chybě
                }
            }
        }
    }
}

#Preview {
    NameInputView(score: 150)
        .environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
}
