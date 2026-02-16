import SwiftUI
import SpriteKit

struct ContentView: View {
    @EnvironmentObject private var gameState: GameState
    @State private var showCircolare = false
    @State private var showEsito = false
    @State private var esitoBuono = false
    @State private var showSettings = false
    @State private var showHelp1 = false
    @State private var showHelp2 = false
    @State private var showHelp3 = false

    private let baseSize = CGSize(width: 618, height: 543)
    private let layout = LayoutStore(jsonName: "unit1_layout_all")
    @State private var scene = GameScene(size: CGSize(width: 618, height: 543))

    var body: some View {
        GeometryReader { proxy in
            let isPortrait = proxy.size.height > proxy.size.width
            let scale = min(proxy.size.width / baseSize.width, proxy.size.height / baseSize.height)

            if isPortrait {
                let panelHeight: CGFloat = 180
                let availableHeight = max(0, proxy.size.height - panelHeight - 12)
                let maxScale = proxy.size.width / baseSize.width
                let rawScale = min(maxScale, availableHeight / baseSize.height)
                let portraitScale = min(maxScale, rawScale * 1.35)
                let gameWidth = baseSize.width * portraitScale
                let gameHeight = baseSize.height * portraitScale

                VStack(spacing: 12) {
                    ZStack(alignment: .topLeading) {
                        SpriteView(scene: scene, options: [.allowsTransparency])
                            .frame(width: baseSize.width, height: baseSize.height)
                        overlayUI(showControls: false)
                    }
                    .frame(width: baseSize.width, height: baseSize.height, alignment: .topLeading)
                    .scaleEffect(portraitScale, anchor: .center)
                    .frame(width: gameWidth, height: gameHeight)
                    .frame(width: proxy.size.width, height: gameHeight, alignment: .center)

                    controlPanelPortrait()
                        .frame(maxWidth: .infinity, minHeight: panelHeight, maxHeight: panelHeight)
                }
                .padding(.bottom, 12)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                .background(Color(white: 0.85).ignoresSafeArea())
            } else {
                ZStack(alignment: .topLeading) {
                    Color(white: 0.85)
                        .ignoresSafeArea()

                    ZStack(alignment: .topLeading) {
                        SpriteView(scene: scene, options: [.allowsTransparency])
                            .frame(width: baseSize.width, height: baseSize.height)

                        overlayUI(showControls: true)
                    }
                    .frame(width: baseSize.width, height: baseSize.height, alignment: .topLeading)
                    .scaleEffect(scale, anchor: .center)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                }
                .ignoresSafeArea()
            }
        }
        .onAppear { configureScene() }
        .onChange(of: gameState.sottofondo) { enabled in
            SoundPlayer.shared.setBackground(enabled: enabled, name: "sottofondo.m4a")
        }
        .sheet(isPresented: $showCircolare) {
            CircolareView { scelta in
                showCircolare = false
                handleCircolare(scelta: scelta)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showEsito) {
            ShowCircolareView(esitoBuono: esitoBuono) {
                showEsito = false
                gameState.paused = false
            }
        }
        .alert("Livello 1", isPresented: $showHelp1) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Apparirà una sola immagine alla volta: se la colpisci guadagni punti, se non la colpisci o se sbagli perdi punti.")
        }
        .alert("Livello 2", isPresented: $showHelp2) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Appariranno 1 prof buono e 1 prof cattivo. Colpisci il cattivo per guadagnare punti.")
        }
        .alert("Livello 3", isPresented: $showHelp3) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Come il livello 2, ma prof buoni/cattivi casuali e la bidella che porta circolari.")
        }
    }

    private func configureScene() {
        scene.gameState = gameState
        scene.onShowCircolare = {
            gameState.paused = true
            showCircolare = true
        }
    }

    @ViewBuilder
    private func overlayUI(showControls: Bool) -> some View {
        let baseFont = Font.system(size: showControls ? 18 : 11)
        let labelFont = Font.system(size: showControls ? 18 : 11, weight: .semibold)
        let boardFont = Font.system(size: showControls ? 14 : 11, weight: .semibold)
        let rightShift: CGFloat = showControls ? 60 : 0
        let rightPanelGap: CGFloat = showControls ? 18 : 0
        let levelShift: CGFloat = showControls ? 60 : 0
        let toggleShift: CGFloat = showControls ? 40 : 0
        let speedShift: CGFloat = showControls ? 20 : 0
        let actionDownShift: CGFloat = showControls ? 22 : 0
        let sideTitleFont = Font.system(size: showControls ? 22 : 11, weight: .semibold)
        let sideItemFont = Font.system(size: showControls ? 20 : 11)

        ZStack(alignment: .topLeading) {
            if showControls {
                if let frame = layout.frame(for: "Button1") {
                    let w = max(frame.width, 170)
                    let h = max(frame.height, 36)
                    Button("Personalizzazioni") { showSettings = true }
                        .font(sideTitleFont)
                        .frame(width: w + 90, height: h + 16, alignment: .center)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(8)
                        .position(x: frame.minX + (w + 90) / 2 + rightShift, y: frame.minY + h / 2 - 14)
                }

                if let frame = layout.frame(for: "Button17") {
                    let w = max(frame.width, 140)
                    let h = max(frame.height, 40)
                    Button(action: {
                        if gameState.running {
                            gameState.running = false
                            gameState.paused = false
                            gameState.calcolaVoto()
                        } else {
                            gameState.resetScores()
                            gameState.running = true
                            scene.resetForStart()
                        }
                    }) {
                        Label(gameState.running ? "Stop" : "Start", systemImage: gameState.running ? "stop.fill" : "play.fill")
                            .labelStyle(.titleAndIcon)
                    }
                    .font(sideItemFont)
                    .frame(width: w + 40, height: h + 12)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(6)
                    .position(x: frame.minX + w / 2, y: frame.minY + h / 2 + rightPanelGap * 2 + actionDownShift)
                }

                if let frame = layout.frame(for: "Button18") {
                    let w = max(frame.width, 140)
                    let h = max(frame.height, 40)
                    Button(action: {
                        if gameState.running {
                            gameState.paused.toggle()
                        }
                    }) {
                        Label(gameState.paused ? "Riprendi" : "Pausa", systemImage: gameState.paused ? "playpause.fill" : "pause.fill")
                            .labelStyle(.titleAndIcon)
                    }
                    .font(sideItemFont)
                    .opacity(gameState.running ? 1 : 0)
                    .frame(width: w + 40, height: h + 12)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(6)
                    .position(x: frame.minX + w / 2, y: frame.minY + h / 2 + rightPanelGap * 3 + actionDownShift)
                }

                radio("ckdlivello1", title: "Livello 1", selected: gameState.level == 1, font: Font.system(size: 22), extraX: levelShift) { gameState.level = 1 }
                radio("ckdlivello2", title: "Livello 2", selected: gameState.level == 2, font: Font.system(size: 22), extraX: levelShift) { gameState.level = 2 }
                radio("ckdlivello3", title: "Livello 3", selected: gameState.level == 3, font: Font.system(size: 22), extraX: levelShift) { gameState.level = 3 }

                groupButton("Button6", title: "ℹ︎", font: Font.system(size: 20), extraX: levelShift) { showHelp1 = true }
                groupButton("Button7", title: "ℹ︎", font: Font.system(size: 20), extraX: levelShift) { showHelp2 = true }
                groupButton("Button8", title: "ℹ︎", font: Font.system(size: 20), extraX: levelShift) { showHelp3 = true }
            }

                // "Velocita" moved into control panels
            label("Label3", font: boardFont)
            label("Label4", font: boardFont)
            label("Label5", font: boardFont)
            label("Label9", font: boardFont)

            valueLabel("profcolpiti", font: baseFont, value: "\(gameState.colpiti)")
            valueLabel("profsfuggiti", font: baseFont, value: "\(gameState.sfuggiti)")
            valueLabel("colpisbagliati", font: baseFont, value: "\(gameState.sbagliati)")
            valueLabel("lblvoto", font: .system(size: 12, weight: .bold), value: "\(gameState.voto)")

            if showControls {
                if let frame = layout.frame(for: "ckdsuoni") {
                    let w = max(frame.width, 170)
                    let h = max(frame.height, 28)
                    Toggle("Suoni", isOn: $gameState.suoni)
                        .font(sideItemFont)
                        .frame(width: w + 40, height: h + 6, alignment: .leading)
                        .position(x: frame.minX + (w + 40) / 2 + rightShift, y: frame.minY + h / 2 + 34)
                        .scaleEffect(showControls ? 1.15 : 1.0)
                }

                if let frame = layout.frame(for: "ckdsottofondo") {
                    let w = max(frame.width, 170)
                    let h = max(frame.height, 28)
                    Toggle("Sottofondo", isOn: $gameState.sottofondo)
                        .font(sideItemFont)
                        .frame(width: w + 40, height: h + 6, alignment: .leading)
                        .position(x: frame.minX + (w + 40) / 2 + rightShift, y: frame.minY + h / 2 - 34)
                        .scaleEffect(showControls ? 1.15 : 1.0)
                }

                landscapeSpeedControl(baseFont: sideItemFont, rightShift: speedShift)
            }
        }
        .frame(width: baseSize.width, height: baseSize.height, alignment: .topLeading)
    }

    @ViewBuilder
    private func label(_ name: String, font: Font) -> some View {
        if let frame = layout.frame(for: name) {
            let width = frame.width + labelExtraWidth(name)
            Text(layout.caption(for: name) ?? "")
                .font(font)
                .frame(width: width, height: frame.height, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .position(x: frame.minX + width / 2, y: frame.minY + frame.height / 2)
        }
    }

    private func labelExtraWidth(_ name: String) -> CGFloat {
        if name == "Label2" { return 120.0 }
        if ["Label3", "Label4", "Label5", "Label9"].contains(name) { return 90.0 }
        return 0.0
    }

    private func adjustedFrame(_ name: String) -> CGRect? {
        guard let frame = layout.frame(for: name) else { return nil }
        if let group = layout.frame(for: "GroupBox1"),
           ["ckdlivello1", "ckdlivello2", "ckdlivello3", "Button6", "Button7", "Button8"].contains(name) {
            return frame.offsetBy(dx: group.minX, dy: group.minY)
        }
        return frame
    }

    @ViewBuilder
    private func groupButton(_ name: String, title: String, font: Font, extraX: CGFloat = 0, action: @escaping () -> Void) -> some View {
        if let frame = adjustedFrame(name) {
            Button(title, action: action)
                .font(font)
                .frame(width: frame.width, height: frame.height)
                .position(x: frame.minX + frame.width / 2 + extraX, y: frame.minY + frame.height / 2)
        }
    }

    @ViewBuilder
    private func radio(_ name: String, title: String, selected: Bool, font: Font, extraX: CGFloat = 0, action: @escaping () -> Void) -> some View {
        if let frame = adjustedFrame(name) {
            radioButton(title: title, selected: selected, action: action)
                .font(font)
                .frame(width: max(frame.width, 140), height: frame.height, alignment: .leading)
                .position(x: frame.minX + frame.width / 2 + extraX, y: frame.minY + frame.height / 2)
        }
    }

    @ViewBuilder
    private func valueLabel(_ name: String, font: Font, value: String) -> some View {
        if let frame = layout.frame(for: name) {
            Text(value)
                .font(font)
                .frame(width: frame.width, height: frame.height, alignment: .leading)
                .position(x: frame.minX + frame.width / 2, y: frame.minY + frame.height / 2)
        }
    }

    private func radioButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .stroke(Color.black, lineWidth: 1)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .fill(selected ? Color.black : Color.clear)
                            .frame(width: 6, height: 6)
                    )
                Text(title)
            }
        }
        .buttonStyle(.plain)
    }

    private func controlPanelPortrait() -> some View {
        VStack(spacing: 10) {
            Button("Personalizzazioni") { showSettings = true }
                .frame(maxWidth: .infinity, minHeight: 44)
            HStack(spacing: 12) {
                Button(action: {
                    if gameState.running {
                        gameState.running = false
                        gameState.paused = false
                        gameState.calcolaVoto()
                    } else {
                        gameState.resetScores()
                        gameState.running = true
                        scene.resetForStart()
                    }
                }) {
                    Label(gameState.running ? "Stop" : "Start", systemImage: gameState.running ? "stop.fill" : "play.fill")
                        .labelStyle(.titleAndIcon)
                }
                .frame(maxWidth: .infinity, minHeight: 44)

                Button(action: {
                    if gameState.running {
                        gameState.paused.toggle()
                    }
                }) {
                    Label(gameState.paused ? "Riprendi" : "Pausa", systemImage: gameState.paused ? "playpause.fill" : "pause.fill")
                        .labelStyle(.titleAndIcon)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .opacity(gameState.running ? 1 : 0)
            }

            HStack(spacing: 12) {
                Toggle("Suoni", isOn: $gameState.suoni)
                Toggle("Sottofondo", isOn: $gameState.sottofondo)
            }

            HStack(spacing: 12) {
                Text("Velocita")
                Slider(value: speedBinding, in: 0...100, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                radioButton(title: "Livello 1", selected: gameState.level == 1) { gameState.level = 1 }
                radioButton(title: "Livello 2", selected: gameState.level == 2) { gameState.level = 2 }
                radioButton(title: "Livello 3", selected: gameState.level == 3) { gameState.level = 3 }
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func landscapeSpeedControl(baseFont: Font, rightShift: CGFloat) -> some View {
        if let frame = layout.frame(for: "ckdsuoni") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Velocita")
                    .font(baseFont)
                Slider(value: speedBinding, in: 0...100, step: 1)
            }
            .frame(width: 200, height: 60)
            .position(x: frame.minX + 80 + rightShift, y: frame.minY + 140)
        }
    }


    private func handleCircolare(scelta: Int) {
        let numero = Int.random(in: 1...2)
        let buono = numero == scelta
        esitoBuono = buono
        if buono {
            gameState.colpiti += 100
        } else {
            gameState.colpiti -= 100
        }
        showEsito = true
    }

    private var speedBinding: Binding<Double> {
        Binding(
            get: { Double(gameState.velocita) },
            set: { gameState.velocita = Int($0) }
        )
    }
}
#Preview("Static Landscape") {
     ContentViewStaticPreview()
         .environmentObject(GameState())
         .previewInterfaceOrientation(.landscapeLeft)
 }


struct ContentViewStaticPreview: View {
    private func loadPreviewImage(named name: String) -> UIImage? {
        if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "images")
            ?? Bundle.main.url(forResource: name, withExtension: "png")
            ?? Bundle.main.url(forResource: name, withExtension: "jpg", subdirectory: "images")
            ?? Bundle.main.url(forResource: name, withExtension: "jpg") {
            return UIImage(contentsOfFile: url.path)
        }
        return nil
    }

    var body: some View {
        ZStack {
            Color(white: 0.85)
            if let img = loadPreviewImage(named: "Image1") {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 618, height: 543)
            } else {
                Text("Preview image not found")
                    .foregroundColor(.red)
            }
        }
    }
}
