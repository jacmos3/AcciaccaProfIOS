import SwiftUI
import UIKit

struct CircolareView: View {
    @EnvironmentObject private var gameState: GameState
    @State private var scelta = 1
    let onDone: (Int) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(GameCopy.circolareIntro)
                .font(.system(size: 16))
                .multilineTextAlignment(.leading)

            if let uiImage = loadImage(named: "Unit2_Image1") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 137, height: 137)
            }

            Picker("Scelta", selection: $scelta) {
                Text("Circolare 1").tag(1)
                Text("Circolare 2").tag(2)
            }
            .pickerStyle(.segmented)

            Button("OK") {
                onDone(scelta)
            }
            .padding(.top, 8)
        }
        .padding(16)
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

#Preview {
     ContentView()
         .environmentObject(GameState())
 }
