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
    @State private var showOnboarding = false
    @AppStorage("didShowOnboarding") private var didShowOnboarding = false
    @State private var showExistential = false
    @State private var existentialAnswer = ""
    @State private var showPentathlonRule = false
    @State private var pentathlonRuleText = ""
    @State private var showPentathlonComplete = false
    @State private var pentathlonCompleteText = ""
    @State private var pentathlonCompleteNext: Int?
    @State private var showPentathlonRetry = false
    @State private var showLevelAlert = false
    @State private var levelAlertText = ""
    @State private var showPrivateAlert = false
    @State private var privateAlertText = ""
    @State private var isPreloading = true
    @State private var elapsedSeconds: Int = 0
    @State private var sessionTimer: Timer?
    @State private var showAuthors = false

    private let baseSize = CGSize(width: 618, height: 543)
    private let layout = LayoutStore(jsonName: "unit1_layout_all")
    @State private var scene = GameScene(size: CGSize(width: 618, height: 543))

    var body: some View { pentathlonAndSessionFlowAlerts }

    private var rootContent: some View {
        GeometryReader { proxy in
            mainLayout(proxy)
        }
        .onAppear { configureScene() }
        .onAppear {
            if !didShowOnboarding {
                showOnboarding = true
            } else {
                SoundPlayer.shared.setBackground(enabled: gameState.sottofondo, name: "sottofondo.m4a")
            }
        }
        .onChange(of: gameState.running) { running in
            if running {
                startSessionTimer()
            } else {
                stopSessionTimer(reset: false)
            }
        }
        .onDisappear {
            stopSessionTimer(reset: false)
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
        .overlay {
            if showOnboarding {
                OnboardingView {
                    didShowOnboarding = true
                    showOnboarding = false
                    SoundPlayer.shared.setBackground(enabled: gameState.sottofondo, name: "sottofondo.m4a")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showAuthors) {
            NavigationView {
                AuthorsView()
            }
        }
        .sheet(isPresented: $showEsito) {
            ShowCircolareView(esitoBuono: esitoBuono) {
                showEsito = false
                gameState.paused = false
            }
        }
    }

    private var sessionAlerts: some View {
        rootContent
            .alert("Lezione 1", isPresented: $showHelp1) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(GameCopy.lezione1)
            }
            .alert("Lezione 2", isPresented: $showHelp2) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(GameCopy.lezione2)
            }
            .alert("Lezione 3", isPresented: $showHelp3) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(GameCopy.lezione3)
            }
    }

    private var gameAlerts: some View {
        sessionAlerts
            .alert("Partita finita", isPresented: $showGameOver) {
                Button("OK", role: .cancel) { gameState.gameOver = false }
            } message: {
                Text(String(format: GameCopy.gameOver, formatPoints(gameState.punti), String(gameState.voto)))
            }
            .alert("Istruzioni", isPresented: $showInstructions) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(GameCopy.istruzioni)
            }
            .alert("NOTE", isPresented: $showNote) {
                Button("OK", role: .cancel) {}
                Button("OOK") {
                    showNote = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showExistential = true
                    }
                }
            } message: {
                Text(GameCopy.note)
            }
            .alert("Domanda", isPresented: $showExistential) {
                TextField("Risposta", text: $existentialAnswer)
                Button("OK") {
                    let cleaned = existentialAnswer.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                    if cleaned == "VA" {
                        ImageStore.shared.applyVAFaces()
                        scene.resetForStart()
                        privateAlertText = GameCopy.privateAlertEnabled
                        showPrivateAlert = true
                    } else {
                        privateAlertText = "Semper laudabitur!"
                        showPrivateAlert = true
                    }
                    existentialAnswer = ""
                }
                Button("Annulla", role: .cancel) {
                    existentialAnswer = ""
                }
            } message: {
                Text("Se l'universo è un pensiero che sogna se stesso, chi sta sognando te?")
            }
    }

    private var pentathlonAndSessionFlowAlerts: some View {
        gameAlerts
            .alert("Pentathlon", isPresented: $showPentathlonRule) {
                Button("OK") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scene.startPendingPentathlonMode()
                        gameState.paused = false
                    }
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
            .alert("Pentathlon", isPresented: $showPentathlonRetry) {
                Button("OK") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scene.restartPentathlonAfterRetry()
                        gameState.paused = false
                    }
                }
            } message: {
                Text(GameCopy.retryPentathlon)
            }
            .alert("Campanella", isPresented: $showLevelAlert) {
                Button("OK", role: .cancel) {
                    gameState.paused = false
                }
            } message: {
                Text(levelAlertText)
            }
            .alert("", isPresented: $showPrivateAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(privateAlertText)
            }
            .onReceive(gameState.$levelUpTrigger) { value in
                guard value == 2 || value == 3 else { return }
                gameState.paused = true
                playCampanellaIfNeeded()
                levelAlertText = "Sta cominciando la lezione \(value)!"
                showLevelAlert = true
                gameState.levelUpTrigger = 0
            }
    }

    @ViewBuilder
    private func mainLayout(_ proxy: GeometryProxy) -> some View {
        let isPortrait = proxy.size.height > proxy.size.width
        if isPortrait {
            portraitLayout(proxy)
        } else {
            landscapeLayout(proxy)
        }
    }

    @ViewBuilder
    private func portraitLayout(_ proxy: GeometryProxy) -> some View {
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
    }

    @ViewBuilder
    private func landscapeLayout(_ proxy: GeometryProxy) -> some View {
        let gameFrame = layout.frame(for: "Image1") ?? CGRect(x: 0, y: 0, width: baseSize.width, height: baseSize.height)
        let landscapePanelPadding: CGFloat = 10
        ZStack(alignment: .topLeading) {
            Color(white: 0.85)
                .ignoresSafeArea()

            let finalScale = (proxy.size.height) / gameFrame.height
            let availableWidth = max(0, (proxy.size.width / finalScale) - gameFrame.width - landscapePanelPadding * 2)
            let panelWidth = availableWidth
            let panelScale = min(1, panelWidth / 310)
            let compositeWidth = gameFrame.maxX + landscapePanelPadding + panelWidth + landscapePanelPadding
            let offsetX = 10 - gameFrame.minX * finalScale
            let offsetY = 10 - gameFrame.minY * finalScale

            ZStack(alignment: .topLeading) {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: baseSize.width, height: baseSize.height)

                overlayUI(showControls: panelWidth > 0, panelWidth: panelWidth, panelScale: panelScale)
                preloadOverlay
            }
            .frame(width: compositeWidth, height: baseSize.height, alignment: .topLeading)
            .scaleEffect(finalScale, anchor: .topLeading)
            .offset(x: offsetX, y: offsetY)
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
    }

    private func configureScene() {
        scene.gameState = gameState
        scene.onShowCircolare = {
            gameState.paused = true
            showCircolare = true
        }
        scene.onShowNote = {
            if ImageStore.shared.vaAttivo {
                showAuthors = true
            } else {
                showNote = true
            }
        }
        scene.onPreloadComplete = {
            isPreloading = false
        }
        scene.onShowPentathlonRule = { mode in
            pentathlonRuleText = pentathlonRuleMessage(for: mode)
            if mode == 1 { playCampanellaIfNeeded() }
            showPentathlonRule = true
        }
        scene.onShowPentathlonComplete = { current, next in
            pentathlonCompleteNext = next
            pentathlonCompleteText = "Attività completata! Ora inizia la prossima."
            playCampanellaIfNeeded()
            showPentathlonComplete = true
        }
        scene.onShowPentathlonRetry = {
            showPentathlonRetry = true
        }
        scene.onShowPrivateFacesUnlocked = { enabled in
            privateAlertText = enabled ? GameCopy.privateAlertEnabled : GameCopy.privateAlertDisabled
            showPrivateAlert = true
        }
        SoundPlayer.shared.preload(names: ["robot_hit.wav","assistant_hit.wav","desk_hit.wav","miss.wav","success.wav","fail.wav","sottofondo.m4a","campanella.m4a"]) {
            scene.preloadIfNeeded()
        }
        scene.preloadIfNeeded()
    }

    private func playCampanellaIfNeeded() {
        if gameState.suoni {
            SoundPlayer.shared.play(name: "campanella.m4a")
        }
    }

    private func pentathlonRuleMessage(for mode: Int) -> String {
        GameCopy.pentathlonRule(for: mode)
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
    private func overlayUI(showControls: Bool, panelWidth: CGFloat = 0, panelScale: CGFloat = 1) -> some View {
        //let baseFont = Font.system(size: showControls ? 18 : 11)
        let boardFont = Font.system(size: showControls ? 14 : 11, weight: .semibold)
        let gameFrame = layout.frame(for: "Image1") ?? CGRect(x: 0, y: 0, width: baseSize.width, height: baseSize.height)

        ZStack(alignment: .topLeading) {
            if showControls {
                landscapeControlsPanel(gameFrame: gameFrame, panelWidth: panelWidth, panelScale: panelScale)
            }

                // "Velocita" moved into control panels
            label("Label3", font: boardFont, color: .white)
            label("Label4", font: boardFont, color: .white)
            label("Label5", font: boardFont, color: .white)
            label("Label9", font: boardFont, color: .white)

            valueLabel("profcolpiti", font: Font.system(size: showControls ? 24.3 : 14.4, weight: .bold), value: formatPoints(gameState.punti), color: .white)
            valueLabel("lblvoto", font: .system(size: 13.2, weight: .bold), value: "\(gameState.voto)", color: .white)

            if showControls {
                EmptyView()
            }
        }
        .frame(width: baseSize.width, height: baseSize.height, alignment: .topLeading)
    }

    @ViewBuilder
    private func label(_ name: String, font: Font, color: Color = .black) -> some View {
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
                    .foregroundColor(color)
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
    private func valueLabel(_ name: String, font: Font, value: String, color: Color = .black) -> some View {
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
                .foregroundColor(color)
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

    private func perlaUIImage() -> UIImage? {
        if let custom = ImageStore.shared.image(for: .perla) {
            return custom
        }
        return ImageStore.shared.imageFromBundle(slot: .perla)
    }

    @ViewBuilder
    private func landscapeControlsPanel(gameFrame: CGRect, panelWidth: CGFloat, panelScale: CGFloat) -> some View {
        let panelPadding: CGFloat = 10
        let panelHeight = max(200, baseSize.height - panelPadding * 2)
        let panelX = gameFrame.maxX + panelPadding
        let scale = max(0.75, panelScale)
        let titleFont = Font.system(size: 20 * scale, weight: .semibold)
        let itemFont = Font.system(size: 18 * scale, weight: .regular)
        let buttonFont = Font.system(size: 18 * scale, weight: .semibold)

        VStack(alignment: .leading, spacing: 16 * scale) {
            Button(action: { showSettings = true }) {
                Label("Personalizzazioni", systemImage: "slider.horizontal.3")
                    .labelStyle(.titleAndIcon)
            }
            .font(titleFont)
            .frame(maxWidth: .infinity, minHeight: 48 * scale)
            .background(Color.white.opacity(0.95))
            .cornerRadius(8)
            if gameState.inPentathlon {
                VStack(alignment: .leading, spacing: 10 * scale) {
                    Text("Coach Perla - Clicca per info su questo minigame del Pentathlon")
                        .font(titleFont)
                    Spacer(minLength: 4)
                    Button(action: {
                        pentathlonRuleText = pentathlonRuleMessage(for: scene.currentPentathlonModeRawValue() ?? 1)
                        showPentathlonRule = true
                    }) {
                        Image(uiImage: perlaUIImage() ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 120)
                            .clipShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    //.padding(.top, 4)
                }
            }
            else{
                VStack(alignment: .leading, spacing: 10 * scale) {
                    Button("Istruzioni") { showInstructions = true }
                        .font(itemFont)
                        .frame(maxWidth: .infinity, minHeight: 36 * scale)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                    Text("Lezioni della giornata")
                        .font(titleFont)
                    Spacer(minLength: 4)
                    HStack(alignment: .top, spacing: 12 * scale) {
                        VStack(alignment: .leading, spacing: 10 * scale) {
                            HStack(spacing: 8 * scale) {
                                Button(action: { showHelp1 = true }) {
                                    Image(systemName: "info.circle")
                                }
                                .font(itemFont)
                                .buttonStyle(.plain)
                                .opacity(gameState.level == 1 ? 1 : 0.45)
                                radioButton(title: "Lezione 1", selected: gameState.level == 1) {}
                                    .font(itemFont)
                                    .disabled(true)
                                    .opacity(gameState.level == 1 ? 1 : 0.45)
                                Spacer()
                            }
                            HStack(spacing: 8 * scale) {
                                Button(action: { showHelp2 = true }) {
                                    Image(systemName: "info.circle")
                                }
                                .font(itemFont)
                                .buttonStyle(.plain)
                                .opacity(gameState.level == 2 ? 1 : 0.45)
                                radioButton(title: "Lezione 2", selected: gameState.level == 2) {}
                                    .font(itemFont)
                                    .disabled(true)
                                    .opacity(gameState.level == 2 ? 1 : 0.45)
                                Spacer()
                            }
                            HStack(spacing: 8 * scale) {
                                Button(action: { showHelp3 = true }) {
                                    Image(systemName: "info.circle")
                                }
                                .font(itemFont)
                                .buttonStyle(.plain)
                                .opacity(gameState.level == 3 ? 1 : 0.45)
                                radioButton(title: "Lezione 3", selected: gameState.level == 3) {}
                                    .font(itemFont)
                                    .disabled(true)
                                    .opacity(gameState.level == 3 ? 1 : 0.45)
                                Spacer()
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }

            HStack(spacing: 12 * scale) {
                Button(action: {
                    if gameState.running {
                        gameState.running = false
                        gameState.paused = false
                        stopSessionTimer(reset: true)
                    } else {
                        gameState.resetScores()
                        stopSessionTimer(reset: true)
                        gameState.paused = false
                        gameState.running = true
                        scene.resetForStart()
                    }
                }) {
                    Label(gameState.running ? "Stop" : "Start", systemImage: gameState.running ? "stop.fill" : "play.fill")
                        .labelStyle(.titleAndIcon)
                }
                .font(buttonFont)
                .frame(maxWidth: .infinity, minHeight: 44 * scale)
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)

                Text(formatElapsed(elapsedSeconds))
                    .font(.system(size: 14 * scale, weight: .semibold, design: .monospaced))
                    .frame(minWidth: 70 * scale)
            }

            // Pentathlon access removed in release flow

            VStack(alignment: .leading, spacing: 8 * scale) {
                Text("Velocità: \(Int(speedBinding.wrappedValue))")
                    .font(itemFont)
                Slider(value: speedBinding, in: 0...100, step: 1)
                    .disabled(gameState.running)
            }
            VStack(alignment: .leading, spacing: 10 * scale) {
                Toggle("Sottofondo", isOn: $gameState.sottofondo)
                Toggle("Suoni", isOn: $gameState.suoni)
            }
            .font(itemFont)
            .toggleStyle(.switch)
        }
        .foregroundColor(.black)
        .padding(14 * scale)
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
                        stopSessionTimer(reset: true)
                    } else {
                        gameState.resetScores()
                        stopSessionTimer(reset: true)
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
            }

            // Pentathlon access removed in release flow

            HStack(spacing: 12) {
                Text("Velocità: \(Int(speedBinding.wrappedValue))")
                Slider(value: speedBinding, in: 0...100, step: 1)
                    .disabled(gameState.running)
            }
            HStack(spacing: 12) {
                Toggle("Suoni", isOn: $gameState.suoni)
                Toggle("Sottofondo", isOn: $gameState.sottofondo)
            }

            VStack(alignment: .leading, spacing: 8) {
                Button("Istruzioni") { showInstructions = true }
                    .frame(maxWidth: .infinity, minHeight: 40)
                HStack(spacing: 8) {
                    radioButton(title: "Sessione 1", selected: gameState.level == 1) {}
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
                    radioButton(title: "Sessione 2", selected: gameState.level == 2) {}
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
                    radioButton(title: "Sessione 3", selected: gameState.level == 3) {}
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

    private func startSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if gameState.running && !gameState.paused {
                elapsedSeconds += 1
            }
        }
    }

    private func stopSessionTimer(reset: Bool) {
        sessionTimer?.invalidate()
        sessionTimer = nil
        if reset {
            elapsedSeconds = 0
        }
    }

    private func formatPoints(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

struct OnboardingView: View {
    let onClose: () -> Void
    @State private var pageIndex = 0

    private struct OnboardingPage: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let body: String
        let icon: String
        let tint: Color
    }

    private let pages: [OnboardingPage] = [
        .init(
            title: GameCopy.onboardingPage1Title,
            subtitle: GameCopy.onboardingPage1Subtitle,
            body: GameCopy.onboardingPage1Body,
            icon: "desktopcomputer",
            tint: Color(red: 0.16, green: 0.46, blue: 0.56)
        ),
        .init(
            title: GameCopy.onboardingPage2Title,
            subtitle: GameCopy.onboardingPage2Subtitle,
            body: GameCopy.onboardingPage2Body,
            icon: "text.book.closed",
            tint: Color(red: 0.55, green: 0.34, blue: 0.18)
        ),
        .init(
            title: GameCopy.onboardingPage3Title,
            subtitle: GameCopy.onboardingPage3Subtitle,
            body: GameCopy.onboardingPage3Body,
            icon: "figure.run",
            tint: Color(red: 0.72, green: 0.18, blue: 0.18)
        ),
        .init(
            title: GameCopy.onboardingPage4Title,
            subtitle: GameCopy.onboardingPage4Subtitle,
            body: GameCopy.onboardingPage4Body,
            icon: "gamecontroller.fill",
            tint: Color(red: 0.55, green: 0.34, blue: 0.18)
        ),
        .init(
            title: GameCopy.onboardingPage5Title,
            subtitle: GameCopy.onboardingPage5Subtitle,
            body: GameCopy.onboardingPage5Body,
            icon: "bell.fill",
            tint: Color(red: 0.55, green: 0.34, blue: 0.18)
        )
    ]

    var body: some View {
        ZStack {
            Color(white: 0.86).ignoresSafeArea()
            VStack(spacing: 16) {
                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        onboardingPage(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxHeight: 560)
                .padding(.bottom, 12)

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { idx in
                        Circle()
                            .fill(idx == pageIndex ? Color.black : Color.black.opacity(0.25))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 24)
            }
            .padding(.top, 12)
        }
    }

    private func onboardingPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(page.tint.opacity(0.12))
                    .frame(height: 130)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(page.tint.opacity(0.25), lineWidth: 2)
                    )
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(page.tint.opacity(0.2))
                            .frame(width: 66, height: 66)
                        Image(systemName: page.icon)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(page.tint)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(page.title)
                            .font(.system(size: 24, weight: .bold))
                        Text(page.subtitle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    Spacer()
                    if pageIndex == pages.count - 1 {
                        Button("Inizia") {
                            onClose()
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 18)
            }
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 10) {
                Text(page.body)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.92))
            .cornerRadius(14)
            .padding(.horizontal, 12)
        }
        .padding(.top, 10)
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
