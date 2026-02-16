import Foundation
import Combine

final class GameState: ObservableObject {
    @Published var running = false
    @Published var paused = false
    @Published var level: Int = 1

    @Published var colpiti = 0
    @Published var sfuggiti = 0
    @Published var sbagliati = 0
    @Published var voto = 0

    @Published var suoni = true
    @Published var sottofondo = false
    @Published var velocita = 50

    func resetScores() {
        colpiti = 0
        sfuggiti = 0
        sbagliati = 0
        voto = 0
    }

    func calcolaVoto() {
        let totali = max(1, colpiti + sfuggiti + sbagliati)
        let votoRaw = (colpiti - sfuggiti) - (2 * sbagliati)
        let valore = (votoRaw * 10) / totali
        voto = valore <= 0 ? 1 : valore
    }
}
