import SwiftUI

struct NameInputView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let score: Int
    @State private var playerName = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("YOU'RE IN TOP 10!")
                        .font(.custom("Press Start 2P", size: 16))
                        .foregroundColor(.green)
                        .padding(.top, 20)
                    
                    Text("Score: \(score)")
                        .font(.custom("Press Start 2P", size: 14))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 15) {
                        Text("Enter your name:")
                            .font(.custom("Press Start 2P", size: 12))
                            .foregroundColor(.white.opacity(0.8))
                        
                        TextField("Player Name", text: $playerName)
                            .font(.custom("Press Start 2P", size: 12))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .textFieldStyle(PlainTextFieldStyle())
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
                            saveScore()
                        }
                        .font(.custom("Press Start 2P", size: 10))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.green)
                        .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Invalid Name", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text("Please enter a valid name.")
        }
    }
    
    private func saveScore() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            showingAlert = true
            return
        }
        
        // Limit name length to prevent issues
        let finalName = String(trimmedName.prefix(20))
        
        // Vytvoř nový HighScore
        let newScore = HighScore(context: viewContext)
        newScore.id = UUID()
        newScore.playerName = finalName
        newScore.score = Int16(max(score, 0)) // Ensure positive score
        newScore.date = Date()
        
        // Ulož do Core Data
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving score: \(error)")
            // Could show an error alert here if needed
        }
    }
}

#Preview {
    NameInputView(score: 150)
        .environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
}
