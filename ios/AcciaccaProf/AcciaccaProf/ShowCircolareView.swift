import SwiftUI
import UIKit

struct ShowCircolareView: View {
    @EnvironmentObject private var gameState: GameState
    let esitoBuono: Bool
    let onClose: () -> Void

    var body: some View {
        ZStack {
            if let uiImage = loadImage(named: "Unit4_Image1") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }

            VStack {
                Spacer().frame(height: 140)
                Text(esitoBuono ? "Bella notizia!" : "Brutta notizia!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
        }
        .onAppear {
            if gameState.suoni {
                SoundPlayer.shared.play(name: esitoBuono ? "siii.wav" : "nooo.wav")
            }
        }
        .onTapGesture {
            onClose()
        }
    }

    private func loadImage(named name: String) -> UIImage? {
        if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "images")
            ?? Bundle.main.url(forResource: name, withExtension: "jpg", subdirectory: "images")
            ?? Bundle.main.url(forResource: name, withExtension: "png")
            ?? Bundle.main.url(forResource: name, withExtension: "jpg") {
            return UIImage(contentsOfFile: url.path)
        }
        return nil
    }
}
