import SwiftUI

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedItem: UUID?

    private let faqItems: [FAQItem] = [
        FAQItem(question: "How do I control the snake?", answer: "Swipe in the direction you want the snake to move: up, down, left, or right."),
        FAQItem(question: "What happens if the snake hits a wall?", answer: "The game ends immediately. Be careful and stay within the grid!"),
        FAQItem(question: "Can I pause the game?", answer: "Yes. Tap the pause button at the bottom of the screen to pause or resume the game."),
        FAQItem(question: "Does the game save my high score?", answer: "Yes. Your highest score is saved locally on your device."),
        FAQItem(question: "Is internet connection required to play?", answer: "No. The game works completely offline."),
        FAQItem(question: "Can I play with a keyboard or game controller?", answer: "No. The game is designed for touch input only."),
        FAQItem(question: "Will the snake wrap around the screen?", answer: "No. If the snake hits a wall, the game is over.")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("FAQ")
                        .font(.custom("Press Start 2P", size: 18))
                        .foregroundColor(.green)
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Text("EXIT")
                            .font(.custom("Press Start 2P", size: 10))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.red)
                            .cornerRadius(0)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)
                .padding(.bottom, 10)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(faqItems) { item in
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedItem == item.id },
                                    set: { expandedItem = $0 ? item.id : nil }
                                )
                            ) {
                                Text(item.answer)
                                    .font(.custom("Press Start 2P", size: 10))
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineSpacing(6) // větší mezera mezi řádky otázky
                            } label: {
                                HStack(alignment: .top) {
                                    Text(item.question)
                                        .font(.custom("Press Start 2P", size: 11))
                                        .foregroundColor(.green)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineSpacing(6) // větší mezera mezi řádky otázky
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.3)) // šedivý background
                            .cornerRadius(0)
                            .tint(.green)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

#Preview {
    FAQView()
}
