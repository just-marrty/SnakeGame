import Foundation

class SettingsManager: ObservableObject {
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
        }
    }

    @Published var vibrationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(vibrationEnabled, forKey: "VibrationEnabled")
        }
    }

    init() {
        self.soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
        self.vibrationEnabled = UserDefaults.standard.bool(forKey: "VibrationEnabled")
    }
}
