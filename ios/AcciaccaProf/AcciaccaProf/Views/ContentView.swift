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
    @State private var showGameOver = false
    @State private var showInstructions = false
    @State private var showNote = false
    @State private var showPentathlonRule = false
    @State private var pentathlonRuleText = ""
    @State private var showPentathlonComplete = false
    @State private var pentathlonCompleteText = ""
    @State private var pentathlonCompleteNext: Int?
    @State private var showPentathlonRetry = false
    @State private var isPreloading = true
    @State private var elapsedSeconds: Int = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let baseSize = CGSize(width: 618, height: 543)
    private let layout = LayoutStore(jsonName: "unit1_layout_all")
    @State private var scene = GameScene(size: CGSize(width: 618, height: 543))

    var body: some View {
        GeometryReader { proxy in
            let isPortrait = proxy.size.height > proxy.size.width
            let scale = min(proxy.size.width / baseSize.width, proxy.size.height / baseSize.height)
            let gameFrame = layout.frame(for: "Image1") ?? CGRect(x: 0, y: 0, width: baseSize.width, height: baseSize.height)
            let landscapePanelPadding: CGFloat = 10

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
                        preloadOverlay
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

                    let finalScale = (proxy.size.height) / gameFrame.height
                    let panelWidth = max(310, (proxy.size.width + 50) / finalScale - gameFrame.width - landscapePanelPadding)
                    let compositeWidth = gameFrame.maxX + landscapePanelPadding + panelWidth + landscapePanelPadding
                    let offsetX = 10 - gameFrame.minX * finalScale
                    let offsetY = 10 - gameFrame.minY * finalScale

                    ZStack(alignment: .topLeading) {
                        SpriteView(scene: scene, options: [.allowsTransparency])
                            .frame(width: baseSize.width, height: baseSize.height)

                        overlayUI(showControls: true, panelWidth: panelWidth)
                        preloadOverlay
                    }
                    .frame(width: compositeWidth, height: baseSize.height, alignment: .topLeading)
                    .scaleEffect(finalScale, anchor: .topLeading)
                    .offset(x: offsetX, y: offsetY)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                }
                .ignoresSafeArea()
            }
        }
        .onAppear { configureScene() }
        .onReceive(timer) { _ in
            if gameState.running && !gameState.paused {
                elapsedSeconds += 1
            }
        }
        .onChange(of: gameState.sottofondo) { enabled in
            SoundPlayer.shared.setBackground(enabled: enabled, name: "sottofondo.m4a")
        }
        .onChange(of: gameState.inPentathlon) { started in
            if started {
                scene.queuePentathlonMode(rawValue: 1)
            }
        }
        .onChange(of: gameState.gameOver) { ended in
            if ended {
                showGameOver = true
            }
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
        .alert("Partita finita", isPresented: $showGameOver) {
            Button("OK", role: .cancel) { gameState.gameOver = false }
        } message: {
            Text("Punteggio finale: \(formatPoints(gameState.punti)). Voto in decimi: \(gameState.voto)/10. Puoi ricominciare da capo premendo Start.")
        }
        .alert("Istruzioni", isPresented: $showInstructions) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Punteggi (moltiplicati dalla velocita'):\n• +2 colpisci prof cattivo\n• -1 prof cattivo sfuggito\n• -2 colpisci prof buono\n• +1 prof buono lasciato andare\n• +5 colpisci bidella\n• -1 bidella lasciata andare\n• -1 colpisci un bambino (zampilli)\n• -1 colpo a vuoto\n• +10 circolare buona\n• -10 circolare cattiva\n\nVelocita': la velocita' applica un moltiplicatore logaritmico ai punti, da 0.5x (velocita' 0) fino a 3x (velocita' 100).\n\nLivelli (automatici):\n1) Solo prof cattivo (10 uscite)\n2) Prof cattivo + prof buono (10 uscite)\n3) Come il 2 + bidella con circolari (10 uscite)\n4) Pentathlon: 5 prove speciali (Memory, Riflessi, Scambio di posto, Intruso A/B, Sequenza)\nAl termine il gioco finisce e puoi ricominciare con Start.")
        }
        .alert("NOTE", isPresented: $showNote) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Questo gioco e' stato sviluppato in Delphi nel 2008 tra i banchi di scuola del quinto liceo da Jacopo Moscioni, come svago. Era diventato un po' popolare tra i frequentatori del forum del liceo del tempo, e fu pubblicato su pierotofy, un portale di giovani programmatori. 18 anni dopo, nel 2026, rinasce sottoforma di app per iOS, nella versione Reloaded, con le stesse grafiche e stessi suoni del tempo. E' stata un pochino migliorata solo la dinamica dei livelli e dei punteggi, ma il gameplay e' rimasto identico e semplice come al tempo.")
        }
        .alert("Pentathlon", isPresented: $showPentathlonRule) {
            Button("OK") {
                scene.startPendingPentathlonMode()
                gameState.paused = false
            }
        } message: {
            Text(pentathlonRuleText)
        }
        .alert("Pentathlon", isPresented: $showPentathlonComplete) {
            Button("OK") {
                if let next = pentathlonCompleteNext {
                    scene.queuePentathlonMode(rawValue: next)
                } else {
                    gameState.paused = false
                }
            }
        } message: {
            Text(pentathlonCompleteText)
        }
        .alert("Sequenza sbagliata", isPresented: $showPentathlonRetry) {
            Button("OK") {
                scene.restartPentathlonSequenceAfterRetry()
                gameState.paused = false
            }
        } message: {
            Text("Hai sbagliato la sequenza. Il minigioco riparte da capo.")
        }
    }

    private func configureScene() {
        scene.gameState = gameState
        scene.onShowCircolare = {
            gameState.paused = true
            showCircolare = true
        }
        scene.onShowNote = {
            showNote = true
        }
        scene.onPreloadComplete = {
            isPreloading = false
        }
        scene.onShowPentathlonRule = { mode in
            pentathlonRuleText = pentathlonRuleMessage(for: mode)
            showPentathlonRule = true
        }
        scene.onShowPentathlonComplete = { current, next in
            pentathlonCompleteNext = next
            pentathlonCompleteText = "Minigioco completato! Ora inizia il prossimo."
            showPentathlonComplete = true
        }
        scene.onShowPentathlonRetry = {
            showPentathlonRetry = true
        }
        SoundPlayer.shared.preload(names: ["profmorto.wav","bidella.wav","bambinomorto.wav","fuori.wav","siii.wav","nooo.wav","sottofondo.m4a"]) {
            scene.preloadIfNeeded()
        }
        scene.preloadIfNeeded()
    }

    private func pentathlonRuleMessage(for mode: Int) -> String {
        switch mode {
        case 1:
            return "Memory: per 0.5s vedi 4 prof (2 buoni, 2 cattivi). Poi si coprono. Abbina le coppie. +2 corretto, -1 errore."
        case 2:
            return "Doppio colpo sincronizzato: compaiono 2 prof cattivi e 1 buono. Devi colpire i 2 cattivi insieme con due dita. +3 corretto, -2 errore."
        case 3:
            return "Scambio di posto: appaiono 6 prof. Poi 2 si scambiano di posto. Tocca uno dei due che si sono mossi. +2 corretto, -2 errore."
        case 4:
            return "Intruso A/B: compaiono 4 griglie A-B-A-B. Solo un banco cambia tra A e B. Tocca quello che cambia. +3 corretto, -2 errore."
        case 5:
            return "Sequenza: i prof appaiono in ordine. Ripeti toccando i banchi nella stessa sequenza. Errore = -2 e si riparte."
        default:
            return ""
        }
    }

    private var preloadOverlay: some View {
        Group {
            if isPreloading {
                ZStack {
                    Color.black.opacity(0.35)
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Caricamento...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                }
            }
        }
    }

    @ViewBuilder
    private func overlayUI(showControls: Bool, panelWidth: CGFloat = 0) -> some View {
        let baseFont = Font.system(size: showControls ? 18 : 11)
        let boardFont = Font.system(size: showControls ? 14 : 11, weight: .semibold)
        let gameFrame = layout.frame(for: "Image1") ?? CGRect(x: 0, y: 0, width: baseSize.width, height: baseSize.height)

        ZStack(alignment: .topLeading) {
            if showControls {
                landscapeControlsPanel(gameFrame: gameFrame, panelWidth: panelWidth)
            }

                // "Velocita" moved into control panels
            label("Label3", font: boardFont)
            label("Label4", font: boardFont)
            label("Label5", font: boardFont)
            label("Label9", font: boardFont)

            valueLabel("profcolpiti", font: Font.system(size: showControls ? 27 : 16, weight: .bold), value: formatPoints(gameState.punti))
            valueLabel("lblvoto", font: .system(size: 13.2, weight: .bold), value: "\(gameState.voto)")

            if showControls {
                EmptyView()
            }
        }
        .frame(width: baseSize.width, height: baseSize.height, alignment: .topLeading)
    }

    @ViewBuilder
    private func label(_ name: String, font: Font) -> some View {
        if let frame = layout.frame(for: name) {
            let width = frame.width + labelExtraWidth(name)
            let text: String = {
                switch name {
                case "Label3":
                    return "Punti:"
                case "Label9":
                    return "IL TUO VOTO IN PAGELLA E':"
                case "Label4", "Label5":
                    return ""
                default:
                    return layout.caption(for: name) ?? ""
                }
            }()
            if text.isEmpty {
                EmptyView()
            } else {
                let xShift: CGFloat = name == "Label3" ? 210 : 0
                Text(text)
                    .font(font)
                    .frame(width: width, height: frame.height, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)
                    .position(x: frame.minX + width / 2 + xShift, y: frame.minY + frame.height / 2)
            }
        } else {
            EmptyView()
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
            let width = frame.width + valueLabelExtraWidth(name)
            let xShift: CGFloat = {
                switch name {
                case "profcolpiti":
                    return 180
                case "lblvoto":
                    return 61
                default:
                    return 0
                }
            }()
            Text(value)
                .font(font)
                .frame(width: width, height: frame.height, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .position(x: frame.minX + width / 2 + xShift, y: frame.minY + frame.height / 2)
        }
    }

    private func valueLabelExtraWidth(_ name: String) -> CGFloat {
        switch name {
        case "profcolpiti", "profsfuggiti", "colpisbagliati":
            return 80
        case "lblvoto":
            return 40
        default:
            return 0
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

    @ViewBuilder
    private func landscapeControlsPanel(gameFrame: CGRect, panelWidth: CGFloat) -> some View {
        let panelPadding: CGFloat = 10
        let panelHeight = max(200, baseSize.height - panelPadding * 2)
        let panelX = gameFrame.maxX + panelPadding
        let titleFont = Font.system(size: 20, weight: .semibold)
        let itemFont = Font.system(size: 18, weight: .regular)
        let buttonFont = Font.system(size: 18, weight: .semibold)

        VStack(alignment: .leading, spacing: 16) {
            Button(action: { showSettings = true }) {
                Label("Personalizzazioni", systemImage: "slider.horizontal.3")
                    .labelStyle(.titleAndIcon)
            }
            .font(titleFont)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color.white.opacity(0.95))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 10) {
                Button("Istruzioni") { showInstructions = true }
                    .font(itemFont)
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                Text("Livello")
                    .font(titleFont)
                Spacer(minLength: 4)
                HStack(spacing: 8) {
                    radioButton(title: "Livello 1", selected: gameState.level == 1) {}
                        .font(itemFont)
                        .disabled(true)
                        .opacity(gameState.level == 1 ? 1 : 0.45)
                    Spacer()
                    Button(action: { showHelp1 = true }) {
                        Image(systemName: "info.circle")
                    }
                    .font(itemFont)
                    .buttonStyle(.plain)
                    .opacity(gameState.level == 1 ? 1 : 0.45)
                }
                HStack(spacing: 8) {
                    radioButton(title: "Livello 2", selected: gameState.level == 2) {}
                        .font(itemFont)
                        .disabled(true)
                        .opacity(gameState.level == 2 ? 1 : 0.45)
                    Spacer()
                    Button(action: { showHelp2 = true }) {
                        Image(systemName: "info.circle")
                    }
                    .font(itemFont)
                    .buttonStyle(.plain)
                    .opacity(gameState.level == 2 ? 1 : 0.45)
                }
                HStack(spacing: 8) {
                    radioButton(title: "Livello 3", selected: gameState.level == 3) {}
                        .font(itemFont)
                        .disabled(true)
                        .opacity(gameState.level == 3 ? 1 : 0.45)
                    Spacer()
                    Button(action: { showHelp3 = true }) {
                        Image(systemName: "info.circle")
                    }
                    .font(itemFont)
                    .buttonStyle(.plain)
                    .opacity(gameState.level == 3 ? 1 : 0.45)
                }
            }

            HStack(spacing: 12) {
                Button(action: {
                    if gameState.running {
                        gameState.running = false
                        gameState.paused = false
                        elapsedSeconds = 0
                    } else {
                        gameState.resetScores()
                        elapsedSeconds = 0
                        gameState.paused = false
                        gameState.running = true
                        scene.resetForStart()
                    }
                }) {
                    Label(gameState.running ? "Stop" : "Start", systemImage: gameState.running ? "stop.fill" : "play.fill")
                        .labelStyle(.titleAndIcon)
                }
                .font(buttonFont)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)

                Text(formatElapsed(elapsedSeconds))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .frame(minWidth: 70)

                Button(action: {
                    if gameState.running {
                        gameState.paused.toggle()
                    }
                }) {
                    Label(gameState.paused ? "Riprendi" : "Pausa", systemImage: gameState.paused ? "playpause.fill" : "pause.fill")
                        .labelStyle(.titleAndIcon)
                }
                .font(buttonFont)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)
                .opacity(gameState.running ? 1 : 0.4)
            }

            Button(gameState.inPentathlon ? "Vai al prossimo" : "Vai al Pentathlon") {
                if !gameState.inPentathlon {
                    if !gameState.running {
                        gameState.resetScores()
                        elapsedSeconds = 0
                        gameState.paused = false
                        gameState.running = true
                        scene.resetForStart()
                    }
                    gameState.level = 4
                    gameState.stageCount = 0
                    gameState.inPentathlon = true
                    gameState.paused = false
                } else {
                    scene.debugSkipPentathlonMode()
                }
            }
            .font(buttonFont)
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(Color.white.opacity(0.85))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 10) {
                Toggle("Sottofondo", isOn: $gameState.sottofondo)
                Toggle("Suoni", isOn: $gameState.suoni)
            }
            .font(itemFont)
            .toggleStyle(.switch)

            VStack(alignment: .leading, spacing: 8) {
                Text("Velocità: \(Int(speedBinding.wrappedValue))")
                    .font(itemFont)
                Slider(value: speedBinding, in: 0...100, step: 1)
                    .disabled(gameState.running)
            }
        }
        .foregroundColor(.black)
        .padding(14)
        .frame(width: panelWidth, height: panelHeight, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.92).opacity(0.9)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.15), lineWidth: 1))
        .position(x: panelX + panelWidth / 2, y: panelPadding + panelHeight / 2)
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
                        elapsedSeconds = 0
                    } else {
                        gameState.resetScores()
                        elapsedSeconds = 0
                        gameState.paused = false
                        gameState.running = true
                        scene.resetForStart()
                    }
                }) {
                    Label(gameState.running ? "Stop" : "Start", systemImage: gameState.running ? "stop.fill" : "play.fill")
                        .labelStyle(.titleAndIcon)
                }
                .frame(maxWidth: .infinity, minHeight: 44)

                Text(formatElapsed(elapsedSeconds))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .frame(minWidth: 70)

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

            Button(gameState.inPentathlon ? "Vai al prossimo" : "Vai al Pentathlon") {
                if !gameState.inPentathlon {
                    if !gameState.running {
                        gameState.resetScores()
                        elapsedSeconds = 0
                        gameState.paused = false
                        gameState.running = true
                        scene.resetForStart()
                    }
                    gameState.level = 4
                    gameState.stageCount = 0
                    gameState.inPentathlon = true
                    gameState.paused = false
                } else {
                    scene.debugSkipPentathlonMode()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 36)

            HStack(spacing: 12) {
                Toggle("Suoni", isOn: $gameState.suoni)
                Toggle("Sottofondo", isOn: $gameState.sottofondo)
            }

            HStack(spacing: 12) {
                Text("Velocità: \(Int(speedBinding.wrappedValue))")
                Slider(value: speedBinding, in: 0...100, step: 1)
                    .disabled(gameState.running)
            }

            VStack(alignment: .leading, spacing: 8) {
                Button("Istruzioni") { showInstructions = true }
                    .frame(maxWidth: .infinity, minHeight: 40)
                HStack(spacing: 8) {
                    radioButton(title: "Livello 1", selected: gameState.level == 1) {}
                        .disabled(true)
                        .opacity(gameState.level == 1 ? 1 : 0.45)
                    Spacer()
                    Button(action: { showHelp1 = true }) {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.plain)
                    .opacity(gameState.level == 1 ? 1 : 0.45)
                }
                HStack(spacing: 8) {
                    radioButton(title: "Livello 2", selected: gameState.level == 2) {}
                        .disabled(true)
                        .opacity(gameState.level == 2 ? 1 : 0.45)
                    Spacer()
                    Button(action: { showHelp2 = true }) {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.plain)
                    .opacity(gameState.level == 2 ? 1 : 0.45)
                }
                HStack(spacing: 8) {
                    radioButton(title: "Livello 3", selected: gameState.level == 3) {}
                        .disabled(true)
                        .opacity(gameState.level == 3 ? 1 : 0.45)
                    Spacer()
                    Button(action: { showHelp3 = true }) {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.plain)
                    .opacity(gameState.level == 3 ? 1 : 0.45)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func landscapeSpeedControl(baseFont: Font, rightShift: CGFloat) -> some View {
        if let frame = layout.frame(for: "ckdsuoni") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Velocità: \(Int(speedBinding.wrappedValue))")
                    .font(baseFont)
                Slider(value: speedBinding, in: 0...100, step: 1)
                    .disabled(gameState.running)
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
            gameState.addPoints(10)
        } else {
            gameState.addPoints(-10)
        }
        showEsito = true
    }

    private var speedBinding: Binding<Double> {
        Binding(
            get: { Double(gameState.velocita) },
            set: { gameState.velocita = Int($0) }
        )
    }

    private func formatElapsed(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private func formatPoints(_ value: Double) -> String {
        String(format: "%.2f", value)
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
