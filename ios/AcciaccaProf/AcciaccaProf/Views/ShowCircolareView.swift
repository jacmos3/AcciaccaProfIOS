import SwiftUI
import UIKit

struct ShowCircolareView: View {
    @EnvironmentObject private var gameState: GameState
    let esitoBuono: Bool
    let onClose: () -> Void
    private let layout = LayoutStore(jsonName: "unit4_layout_all")
    private let baseSize = CGSize(width: 419, height: 576)

    var body: some View {
        ZStack {
            if let uiImage = loadImage(named: "Unit4_Image1") {
                GeometryReader { proxy in
                    let scale = min(proxy.size.width / baseSize.width, proxy.size.height / baseSize.height)
                    ZStack(alignment: .topLeading) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: baseSize.width, height: baseSize.height)

                        circolareTextOverlay()
                            .frame(width: baseSize.width, height: baseSize.height, alignment: .topLeading)
                    }
                    .scaleEffect(scale, anchor: .center)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
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

    @ViewBuilder
    private func circolareTextOverlay() -> some View {
        let subject = esitoBuono ? (layout.caption(for: "Label6") ?? "Oggetto: Festivita' aggiuntive.") :
            (layout.caption(for: "Label6bis") ?? "Oggetto: Corsi di recupero pomeridiani")
        let body = esitoBuono
            ? "Si comunica che da domani la scuola restera' chiusa per festivita' aggiuntive. Buona vacanza!"
            : "Si comunica che sono stati attivati corsi di recupero pomeridiani obbligatori per tutte le classi."

        ZStack(alignment: .topLeading) {
            label("Label1", text: layout.caption(for: "Label1") ?? "", size: 18, weight: .bold)
            label("Label2", text: layout.caption(for: "Label2") ?? "", size: 14)
            label("Label4", text: layout.caption(for: "Label4") ?? "", size: 14)
            label("Label3", text: layout.caption(for: "Label3") ?? "", size: 15, weight: .bold)
            label("Label5", text: layout.caption(for: "Label5") ?? "", size: 14, weight: .semibold)
            label("Label6", text: subject, size: 14, weight: .semibold, align: .leading)
            label("Label7", text: body, size: 13, align: .leading)
            label("Label9", text: layout.caption(for: "Label9") ?? "", size: 13, align: .leading)
            label("Label8", text: layout.caption(for: "Label8") ?? "", size: 13, weight: .semibold, align: .leading)
        }
    }

    @ViewBuilder
    private func label(_ name: String, text: String, size: CGFloat, weight: Font.Weight = .regular, align: TextAlignment = .center) -> some View {
        if let frame = layout.frame(for: name), !text.isEmpty {
            Text(text)
                .font(.system(size: size, weight: weight))
                .foregroundColor(.black)
                .multilineTextAlignment(align)
                .frame(width: frame.width, height: frame.height, alignment: align == .center ? .center : .leading)
                .position(x: frame.minX + frame.width / 2, y: frame.minY + frame.height / 2)
        } else {
            EmptyView()
        }
    }
}
