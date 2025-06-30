import SwiftUI

struct LeaderboardView: View {
    @State private var leaderboard: [CloudHighScore] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("TOP 10 LEADERBOARD")
                        .font(.custom("Press Start 2P", size: 18))
                        .foregroundColor(.snakeGreen)
                        .padding(.top)

                    if isLoading {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else if leaderboard.isEmpty {
                        Text("There is no score yet.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(Array(leaderboard.prefix(10).enumerated()), id: \.1.id) { index, score in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("#\(index + 1)")
                                            .font(.custom("Press Start 2P", size: 12))
                                            .foregroundColor(.yellow)
                                            .frame(width: 40, alignment: .leading)

                                        Text(score.player)
                                            .font(.custom("Press Start 2P", size: 12))
                                            .foregroundColor(.black)

                                        Spacer()

                                        Text("\(score.score)")
                                            .font(.custom("Press Start 2P", size: 14))
                                            .foregroundColor(.snakeGreen)
                                    }

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
                    }

                    Button(action: {
                        fetchLeaderboard()
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .font(.custom("Press Start 2P", size: 10))
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.snakeGreen)
                            .cornerRadius(8)
                    }

                    Spacer()

                    Text("Swipe down to go back to menu")
                        .font(.custom("Press Start 2P", size: 10))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            fetchLeaderboard()
        }
    }

    private func fetchLeaderboard() {
        isLoading = true

        CloudKitManager.fetchTopScores { result in
            switch result {
            case .success(let scores):
                leaderboard = scores
            case .failure(let error):
                print("Chyba při načítání leaderboardu: \(error.localizedDescription)")
                leaderboard = []
            }
            isLoading = false
        }
    }
}
