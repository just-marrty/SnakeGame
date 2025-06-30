import SwiftUI

struct LoadingView: View {
    @State private var progress: CGFloat = 0
    @State private var isActive = false
    @State private var blink = true
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {
                // Logo (obrázek nebo stylizovaný text)
                Image("snake") // nahraď názvem svého assetu
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(color: .green.opacity(0.5), radius: 10)

                // "Loading" text
                Text("LOADING...")
                    .font(.custom("Press Start 2P", size: 14))
                    .foregroundColor(.white)

                // Loading bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 14)
                        .foregroundColor(.gray.opacity(0.3))

                    RoundedRectangle(cornerRadius: 0)
                        .frame(width: progress, height: 14)
                        .foregroundColor(.snakeGreen)
                        .animation(.linear(duration: 0.3), value: progress)
                }
                .frame(width: 220)
            }
        }
        .onAppear {
            startProgress()
        }
        .fullScreenCover(isPresented: $isActive) {
            DashboardView()
        }
    }

    private func startProgress() {
        progress = 0
        var current: CGFloat = 0
        let maxProgress: CGFloat = 220
        let steps: [CGFloat] = [5, 10, 15, 7, 12, 8, 10]  // různé skoky pro „trhání“

        var stepIndex = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { t in
            let step = steps[stepIndex % steps.count]
            stepIndex += 1

            current += step

            if current >= maxProgress {
                t.invalidate()
                isActive = true
            } else {
                withAnimation(.easeInOut(duration: 0.1)) {
                    progress = current
                    blink.toggle()
                }
            }
        }
    }
}
