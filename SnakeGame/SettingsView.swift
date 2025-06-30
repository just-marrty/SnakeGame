import SwiftUI
import AVFoundation
import UIKit
import CoreData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var settings: SettingsManager
    @AppStorage("SnakeHighScore") private var storedHighScore = 0
    @StateObject private var audioManager = AudioManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("SETTINGS")
                        .font(.custom("PressStart2P-Regular", size: 18))
                        .foregroundColor(.snakeGreen)
                        .padding(.top, 20)

                    VStack(spacing: 20) {
                        retroToggle(label: "Sound Effects", icon: "speaker.wave.2.fill", isOn: $settings.soundEnabled) {
                            if settings.soundEnabled {
                                audioManager.playEffect("check")
                            } else {
                                audioManager.stopAllSounds()
                            }
                        }

                        retroToggle(label: "Vibration", icon: "iphone.radiowaves.left.and.right", isOn: $settings.vibrationEnabled) {
                            if settings.vibrationEnabled {
                                playHaptic()
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationBarItems(trailing:
                Button("DONE") {
                    audioManager.playEffect("backward") {
                        dismiss()
                    }
                }
                .font(.custom("PressStart2P-Regular", size: 10))
                .foregroundColor(.snakeGreen)
            )
        }
    }

    @ViewBuilder
    private func retroToggle(label: String, icon: String, isOn: Binding<Bool>, onToggle: @escaping () -> Void) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.snakeGreen)
                .font(.title2)

            Text(label)
                .foregroundColor(.white)
                .font(.custom("PressStart2P-Regular", size: 10))

            Spacer()

            Button(action: {
                isOn.wrappedValue.toggle()
                onToggle()
            }) {
                Text(isOn.wrappedValue ? "ON" : "OFF")
                    .font(.custom("PressStart2P-Regular", size: 10))
                    .foregroundColor(.black)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(isOn.wrappedValue ? Color.snakeGreen : Color.gray)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(6)
    }

    private func playHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    SettingsView(settings: SettingsManager())
}
