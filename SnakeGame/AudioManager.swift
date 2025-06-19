import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var backgroundPlayer: AVAudioPlayer?
    private var effectPlayer: AVAudioPlayer?
    private var backgroundDelegate: AVAudioPlayerDelegate?
    private var effectDelegate: AVAudioPlayerDelegate?
    
    private init() {}
    
    // Přehraj background zvuk (main-menu)
    func playBackgroundMusic(_ name: String) {
        // Kontrola, zda jsou zvuky povolené
        guard UserDefaults.standard.bool(forKey: "SoundEnabled") else {
            return
        }
        
        stopBackgroundMusic()
        
        let extensions = ["wav", "mp3"]
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                do {
                    backgroundPlayer = try AVAudioPlayer(contentsOf: url)
                    backgroundPlayer?.numberOfLoops = -1 // Loop forever
                    backgroundPlayer?.volume = 0.7
                    backgroundPlayer?.play()
                    return
                } catch {
                    print("Error playing background music \(name).\(ext): \(error.localizedDescription)")
                }
            }
        }
        print("Background music file \(name) not found.")
    }
    
    // Zastav background zvuk
    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
        backgroundDelegate = nil
    }
    
    // Přehraj efekt zvuk (jednorázově)
    func playEffect(_ name: String, onComplete: (() -> Void)? = nil) {
        // Kontrola, zda jsou zvuky povolené
        guard UserDefaults.standard.bool(forKey: "SoundEnabled") else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onComplete?()
            }
            return
        }
        
        let extensions = ["wav", "mp3"]
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                do {
                    effectPlayer = try AVAudioPlayer(contentsOf: url)
                    effectPlayer?.numberOfLoops = 0
                    effectPlayer?.volume = 1.0
                    
                    if let completion = onComplete {
                        let delegate = AudioDelegate(onFinish: completion)
                        effectDelegate = delegate
                        effectPlayer?.delegate = delegate
                    } else {
                        effectPlayer?.delegate = nil
                        effectDelegate = nil
                    }
                    
                    effectPlayer?.play()
                    return
                } catch {
                    print("Error playing effect \(name).\(ext): \(error.localizedDescription)")
                }
            }
        }
        
        print("Effect file \(name) not found.")
        // Pokud se zvuk nepodařilo přehrát, zavolej completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onComplete?()
        }
    }
    
    // Zastav všechny zvuky
    func stopAllSounds() {
        stopBackgroundMusic()
        effectPlayer?.stop()
        effectPlayer = nil
        effectDelegate = nil
    }
    
    // Kontrola, zda je background zvuk aktivní
    var isBackgroundMusicPlaying: Bool {
        return backgroundPlayer?.isPlaying == true
    }
} 