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
        let firstLaunchKey = "HasLaunchedBefore"
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: firstLaunchKey)

        if !hasLaunchedBefore {
            // Nastavení výchozích hodnot pouze při prvním spuštění
            UserDefaults.standard.set(true, forKey: "SoundEnabled")
            UserDefaults.standard.set(true, forKey: "VibrationEnabled")
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }

        // Načti aktuální stav nastavení
        self.soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
        self.vibrationEnabled = UserDefaults.standard.bool(forKey: "VibrationEnabled")
    }
}
