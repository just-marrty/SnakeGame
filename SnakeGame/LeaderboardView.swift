import SwiftUI
import CoreData

struct LeaderboardView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: HighScore.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \HighScore.score, ascending: false)],
        animation: .default
    )
    private var scores: FetchedResults<HighScore>

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("TOP 10 LEADERBOARD")
                        .font(.custom("Press Start 2P", size: 18))
                        .foregroundColor(.green)
                        .padding(.top)

                    List {
                        ForEach(Array(scores.prefix(10).enumerated()), id: \.element.id) { index, score in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    // Pozice
                                    Text("#\(index + 1)")
                                        .font(.custom("Press Start 2P", size: 12))
                                        .foregroundColor(.yellow)
                                        .frame(width: 40, alignment: .leading)
                                    
                                    // Jméno hráče
                                    Text(score.playerName ?? "Unknown")
                                        .font(.custom("Press Start 2P", size: 12))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    // Skóre
                                    Text("\(score.score)")
                                        .font(.custom("Press Start 2P", size: 14))
                                        .foregroundColor(.green)
                                }
                                
                                // Datum na druhém řádku
                                if let date = score.date {
                                    HStack {
                                        Text("")
                                            .frame(width: 40, alignment: .leading)
                                        Text(date, style: .date)
                                            .font(.custom("Press Start 2P", size: 8))
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                    .listStyle(PlainListStyle())
                    
                    Spacer()
                    
                    Text("Swipe down to go back to menu")
                        .font(.custom("Press Start 2P", size: 10))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LeaderboardView()
        .environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
}




