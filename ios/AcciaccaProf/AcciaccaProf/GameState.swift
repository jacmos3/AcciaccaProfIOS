import Foundation
import Combine

final class GameState: ObservableObject {
    @Published var running = false
    @Published var paused = false
    @Published var level: Int = 1
    @Published var stageCount = 0

    @Published var colpiti = 0 { didSet { calcolaVoto() } }
    @Published var sfuggiti = 0 { didSet { calcolaVoto() } }
    @Published var sbagliati = 0 { didSet { calcolaVoto() } }
    @Published var voto = 0
    @Published var punti = 0
    @Published var gameOver = false

    @Published var suoni = true
    @Published var sottofondo = false
    @Published var velocita = 50

    func resetScores() {
        colpiti = 0
        sfuggiti = 0
        sbagliati = 0
        voto = 0
        punti = 0
        level = 1
        stageCount = 0
        gameOver = false
    }

    func calcolaVoto() {
        let totali = max(1, colpiti + sfuggiti + sbagliati)
        let votoRaw = (colpiti - sfuggiti) - (2 * sbagliati)
        let valore = (votoRaw * 10) / totali
        voto = valore <= 0 ? 1 : valore
    }

    func registerCattivoSpawn() {
        guard running else { return }
        stageCount += 1
        switch level {
        case 1:
            if stageCount >= 10 {
                level = 2
                stageCount = 0
            }
        case 2:
            if stageCount >= 10 {
                level = 3
                stageCount = 0
            }
        default:
            if stageCount >= 10 {
                running = false
                paused = false
                gameOver = true
            }
        }
    }

    func addPoints(_ delta: Int) {
        let multiplier = scoreMultiplier(for: velocita)
        let adjusted = Int((Double(delta) * multiplier).rounded())
        punti += adjusted
        calcolaVoto()
    }

    private func scoreMultiplier(for speed: Int) -> Double {
        let clamped = max(0, min(100, speed))
        let t = Double(clamped) / 100.0
        // Log curve from 0.5 to 3.0
        return 0.5 + 2.5 * (log10(1 + 9 * t))
    }
}
