import Foundation
import AVFoundation

final class SoundPlayer {
    static let shared = SoundPlayer()
    private var players: [String: AVAudioPlayer] = [:]
    private var backgroundPlayer: AVAudioPlayer?

    func play(name: String) {
        if let player = players[name] {
            player.currentTime = 0
            player.play()
            return
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: "sounds")
            ?? Bundle.main.url(forResource: name, withExtension: nil) else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            players[name] = player
            player.play()
        } catch {
            return
        }
    }

    func setBackground(enabled: Bool, name: String) {
        if enabled {
            if let player = backgroundPlayer {
                player.play()
                return
            }
            guard let url = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: "sounds")
                ?? Bundle.main.url(forResource: name, withExtension: nil) else { return }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                player.volume = 0.6
                backgroundPlayer = player
                player.play()
            } catch {
                return
            }
        } else {
            backgroundPlayer?.stop()
            backgroundPlayer = nil
        }
    }
}
