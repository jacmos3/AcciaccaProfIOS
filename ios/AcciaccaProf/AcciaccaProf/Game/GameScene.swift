import SpriteKit
import UIKit
#if targetEnvironment(macCatalyst)
import AppKit
#endif

final class GameScene: SKScene {
    weak var gameState: GameState?
    var onShowCircolare: (() -> Void)?
    var onShowNote: (() -> Void)?
    var onShowPentathlonRule: ((Int) -> Void)?
    var onShowPentathlonComplete: ((Int, Int?) -> Void)?
    var onShowPentathlonRetry: (() -> Void)?
    var onShowPrivateFacesUnlocked: ((Bool) -> Void)?

    private let layout = LayoutStore(jsonName: "unit1_layout_all")
    private let zOrder = ZOrderStore(jsonName: "unit1_zorder")
    private let baseSize = CGSize(width: 618, height: 543)

    private var timer: Timer?

    private var profBuon = SKSpriteNode()
    private var profCatt = SKSpriteNode()
    private var bidella = SKSpriteNode()
    private var schizzi = SKSpriteNode()
    private var zampilli1 = SKSpriteNode()
    private var zampilli2 = SKSpriteNode()
    private var zampilli3 = SKSpriteNode()
    private var bambino1 = SKSpriteNode()
    private var bambino2 = SKSpriteNode()
    private var bambino3 = SKSpriteNode()
    private var playFieldRect = CGRect.zero
    private var deskLinkRect = CGRect.zero
    private var noteRect = CGRect.zero
    private var pentathlonLabel = SKLabelNode()
    private var pentathlonPerlaHint = SKSpriteNode()
    private var pentathlonPerlaGlow = SKShapeNode()
    private var pentathlonPerlaMode: PentathlonMode?
    #if targetEnvironment(macCatalyst)
    private var cursorUp: NSCursor?
    private var cursorDown: NSCursor?
    #endif

    private enum PentathlonMode: Int {
        case memory = 1
        case sequence = 2
        case intruder = 3
        case quickCalc = 4
        case reflex = 5
    }

    private var pentathlonMode: PentathlonMode = .memory
    private var pendingPentathlonMode: PentathlonMode?
    private var pentathlonActive = false
    private var pentathlonCards: [SKSpriteNode] = []
    private var pentathlonCardMap: [String: String] = [:]
    private var pentathlonFlipped: Set<String> = []
    private var pentathlonFirstPick: String?
    private var pentathlonMatchedPairs = 0
    private var pentathlonSequence: [Int] = []
    private var pentathlonInputIndex = 0
    private var pentathlonSequenceLength = 2
    private var pentathlonSequenceTextures: [String] = []
    private var pentathlonSequenceTextureMap: [Int: String] = [:]
    private var pentathlonSequenceCovers: [Int: SKSpriteNode] = [:]
    private var pentathlonIntruderName: String?
    private var pentathlonIntruderTargetIndex: Int?
    private var pentathlonIntruderBasePositions: [Int] = []
    private var pentathlonIntruderBaseTextures: [Int: String] = [:]
    private var pentathlonIntruderAltTextures: [Int: String] = [:]
    private var pentathlonIntruderActive = false
    private var pentathlonCalcNumbers: (Int, Int) = (0, 0)
    private var pentathlonCalcNodes: [SKLabelNode] = []
    private var pentathlonSuccessCount = 0
    private var pentathlonSyncNodes: [SKSpriteNode] = []
    private var pentathlonSyncCattivi: Set<Int> = []
    private var pentathlonSyncBuoni: Set<Int> = []
    private var pentathlonSyncActive = false
    private var pentathlonSyncTickCount = 0
    private var pentathlonSyncPendingReposition = false
    private var pentathlonSwapPositions: [Int] = []
    private var pentathlonSwapTargetIndices: Set<Int> = []
    private var pentathlonSwapTextures: [Int: String] = [:]
    private var pentathlonSwapBaseTextures: [Int: String] = [:]
    private var pentathlonSwapSelected: Set<Int> = []
    private var pentathlonSwapActive = false
    private var pentathlonSwapFirstPick: Int?
    private var pentathlonSwapFirstPickTime: CFTimeInterval = 0
    private var pentathlonSwapInstruction = SKLabelNode()
    private var pentathlonSwapCountdown = SKLabelNode()
    private var pentathlonSeatOrder: [Int] = []
    private var pentathlonSeatTextures: [Int: String] = [:]
    private var pentathlonSeatNodes: [Int: SKSpriteNode] = [:]
    private var pentathlonSeatCovers: [Int: SKSpriteNode] = [:]
    private var pentathlonSeatTargets: [String] = []
    private var pentathlonSeatTargetIndex = 0
    private var pentathlonSeatCenterNode = SKSpriteNode()
    private var pentathlonSeatActive = false
    private var pentathlonSeatLastSpeed: Int = -1
    private var usePrivateFaces = false
    private var pentathlonLogicNodes: [Int: SKSpriteNode] = [:]
    private var pentathlonLogicActive = false
    private var pentathlonLogicRuleIndex = 0
    private var pentathlonLogicViolationIndex: Int?
    private var pentathlonRiskNodes: [Int: SKSpriteNode] = [:]
    private var pentathlonRiskTargets: Set<Int> = []
    private var pentathlonRiskActive = false
    private var pentathlonRiskTypes: [Int: String] = [:]
    private var pentathlonRiskCycleKey = "riskCycle"
    private var pentathlonRiskLastSpeed: Int = -1
    private var pentathlonRiskLastDuration: TimeInterval = -1
    private var pentathlonMovingNodes: [SKSpriteNode] = []
    private var pentathlonMovingPositions: [String: Int] = [:]
    private var pentathlonMovingActive = false

    private var alzateCatt = 0
    private var alzateBuon = 0
    private var alzateBidella = 0
    private var attivaBidella = false

    private var cattLeft: CGFloat = 0
    private var cattTop: CGFloat = 0
    private var cattWidth: CGFloat = 0
    private var cattHeight: CGFloat = 0
    private var cattFullHeight: CGFloat = 0

    private var buonLeft: CGFloat = 0
    private var buonTop: CGFloat = 0
    private var buonWidth: CGFloat = 0
    private var buonHeight: CGFloat = 0
    private var buonFullHeight: CGFloat = 0

    private var bidellaLeft: CGFloat = 0
    private var bidellaTop: CGFloat = 0
    private var bidellaWidth: CGFloat = 0
    private var bidellaHeight: CGFloat = 0
    private var bidellaFullHeight: CGFloat = 0

    private let posizioni: [(CGFloat, CGFloat)] = [
        (56, 26), (200, 26), (352, 26),
        (80, 162), (224, 162), (376, 162),
        (48, 290), (192, 290), (344, 290)
    ]

    private let campoLeft: CGFloat = 13
    private let campoTop: CGFloat = 10
    private let spawnYOffset: CGFloat = 85
    private let profZOffset: CGFloat = -1.0
    private var didPreload = false
    var onPreloadComplete: (() -> Void)?

    override func didMove(to view: SKView) {
        size = baseSize
        scaleMode = .resizeFill
        backgroundColor = .clear
        buildScene()
        startLoop()
        preloadIfNeeded()
    }

    func preloadIfNeeded() {
        if didPreload {
            onPreloadComplete?()
            return
        }
        didPreload = true
        let textures = [
            "Image1","Image3","Image4","Image5","Image10","Image11","Image13","Image16","Image19","Image22","Image25","Image28",
            "Image30","Image31","Image32","Image33","Image34","Image35",
            "schizzi","zampilli",
            "cattivi_1","cattivi_2","cattivi_3",
            "buoni_1","buoni_2","buoni_3",
            "bidella_1",
            "perla_1"
        ].compactMap { textureFor(baseName: $0) }

        SKTexture.preload(textures) { [weak self] in
            DispatchQueue.main.async {
                self?.onPreloadComplete?()
            }
        }
    }

    func resetForStart() {
        attivaBidella = false
        pentathlonActive = false
        clearPentathlonNodes()
        pentathlonLabel.isHidden = true
        profCatt.isHidden = false
        profBuon.isHidden = false
        bidella.isHidden = false
        profCattivo()
        profBuono()
        bidellaa()
    }

    func setPrivateFacesEnabled(_ enabled: Bool) {
        usePrivateFaces = enabled
        gameState?.usePrivateFaces = enabled
        onShowPrivateFacesUnlocked?(enabled)
        profCattivo()
        profBuono()
        bidellaa()
    }

    private func buildScene() {
        removeAllChildren()

        addStaticImages()
        setupDynamicSprites()
        setupBambini()
        setupPentathlonLabel()
        setupPerlaHint()
        setupSwapLabels()
        setupCursorsIfNeeded()
    }

    private func setupCursorsIfNeeded() {
        #if targetEnvironment(macCatalyst)
        if cursorUp == nil {
            cursorUp = loadCursor(named: "martsu")
            cursorDown = loadCursor(named: "martgiu")
            cursorUp?.set()
        }
        #endif
    }

    #if targetEnvironment(macCatalyst)
    private func loadCursor(named name: String) -> NSCursor? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "cur", subdirectory: "cursors"),
              let image = NSImage(contentsOf: url) else { return nil }
        return NSCursor(image: image, hotSpot: NSPoint(x: image.size.width / 2, y: image.size.height / 2))
    }
    #endif

    private func addStaticImages() {
        let staticNames = [
            "Image1","Image3","Image4","Image5","Image6","Image7","Image8","Image9","Image10",
            "Image11","Image12","Image13","Image14","Image15","Image16","Image17","Image18","Image19",
            "Image20","Image21","Image22","Image23","Image24","Image25","Image26","Image27","Image28",
            "Image29","Image31","Image33","Image35"
        ]

        let overlayNames: Set<String> = [
            "Image4","Image7","Image10","Image13","Image16","Image19","Image22","Image25","Image28"
        ]
        let overlayZ = zOrder.zIndex(for: "Image4")
        for name in staticNames {
            guard let frame = layout.frame(for: name), let texture = textureFor(baseName: name) else { continue }
            let node = SKSpriteNode(texture: texture)
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.texture = croppedTextureIfNeeded(texture: texture, frame: frame)
            node.size = frame.size
            node.position = convertPosition(frame: frame)
            var z = zOrder.zIndex(for: name)
            if overlayNames.contains(name) {
                z = max(z, overlayZ)
            }
            node.zPosition = z
            addChild(node)
        }

        if let frame = layout.frame(for: "Image1") {
            let origin = convertPosition(frame: frame)
            playFieldRect = CGRect(origin: origin, size: frame.size)
        }

        addDeskLink()
        addNoteHotspot()
    }

    private func setupPentathlonLabel() {
        pentathlonLabel = SKLabelNode(text: "")
        pentathlonLabel.fontName = "Helvetica-Bold"
        pentathlonLabel.fontSize = 16
        pentathlonLabel.fontColor = .white
        pentathlonLabel.horizontalAlignmentMode = .left
        pentathlonLabel.verticalAlignmentMode = .center
        pentathlonLabel.position = CGPoint(x: 235, y: baseSize.height - 30)
        pentathlonLabel.zPosition = 9999
        pentathlonLabel.isHidden = true
        addChild(pentathlonLabel)
    }

    private func setupPerlaHint() {
        pentathlonPerlaHint = SKSpriteNode(texture: textureFor(baseName: "perla_1"))
        pentathlonPerlaHint.name = "perlaHint"
        pentathlonPerlaHint.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pentathlonPerlaHint.size = CGSize(width: 60, height: 60)
        pentathlonPerlaHint.zPosition = 9997
        pentathlonPerlaHint.isHidden = true
        addChild(pentathlonPerlaHint)

        pentathlonPerlaGlow = SKShapeNode(circleOfRadius: 38)
        pentathlonPerlaGlow.strokeColor = .yellow
        pentathlonPerlaGlow.lineWidth = 4
        pentathlonPerlaGlow.glowWidth = 8
        pentathlonPerlaGlow.fillColor = .clear
        pentathlonPerlaGlow.zPosition = 9996
        pentathlonPerlaGlow.isHidden = true
        addChild(pentathlonPerlaGlow)
    }

    private func setupSwapLabels() {
        pentathlonSwapInstruction = SKLabelNode(text: "")
        pentathlonSwapInstruction.fontName = "Helvetica-Bold"
        pentathlonSwapInstruction.fontSize = 16
        pentathlonSwapInstruction.fontColor = .white
        pentathlonSwapInstruction.horizontalAlignmentMode = .center
        pentathlonSwapInstruction.verticalAlignmentMode = .center
        pentathlonSwapInstruction.position = CGPoint(x: baseSize.width / 2, y: baseSize.height - 50)
        pentathlonSwapInstruction.zPosition = 9998
        pentathlonSwapInstruction.isHidden = true
        addChild(pentathlonSwapInstruction)

        pentathlonSwapCountdown = SKLabelNode(text: "")
        pentathlonSwapCountdown.fontName = "Helvetica-Bold"
        pentathlonSwapCountdown.fontSize = 28
        pentathlonSwapCountdown.fontColor = .yellow
        pentathlonSwapCountdown.horizontalAlignmentMode = .center
        pentathlonSwapCountdown.verticalAlignmentMode = .center
        pentathlonSwapCountdown.position = CGPoint(x: baseSize.width / 2, y: baseSize.height / 2)
        pentathlonSwapCountdown.zPosition = 9999
        pentathlonSwapCountdown.isHidden = true
        addChild(pentathlonSwapCountdown)
    }

    private func addDeskLink() {
        guard let frame = layout.frame(for: "Image1") else { return }
        let label = SKLabelNode(text: "www.semproxlab.it")
        label.fontName = "Helvetica"
        label.fontSize = 12
        label.fontColor = .black
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center

        let x = frame.minX + frame.width * 0.60 + 20
        let y = frame.minY + frame.height * 0.235 - 8
        label.position = CGPoint(x: x, y: baseSize.height - y)
        label.zPosition = zOrder.zIndex(for: "Image3") - 0.5
        addChild(label)
        let frameRect = label.frame
        deskLinkRect = frameRect.insetBy(dx: -8, dy: -6)
        label.name = "deskLink"
    }

    private func addNoteHotspot() {
        if let frame = layout.frame(for: "Image2") {
            noteRect = CGRect(origin: convertPosition(frame: frame), size: frame.size)
        }
    }

    private func setupDynamicSprites() {
        if let frame = layout.frame(for: "profcatt") {
            profCatt = SKSpriteNode(texture: textureFor(baseName: "cattivi_1"))
            profCatt.name = "profcatt"
            profCatt.anchorPoint = CGPoint(x: 0, y: 0)
            cattWidth = frame.width
            cattHeight = frame.height
            cattFullHeight = frame.height
            cattLeft = frame.minX
            cattTop = frame.minY
            applyFrame(node: profCatt, left: frame.minX, top: frame.minY, width: cattWidth, height: cattHeight)
            profCatt.zPosition = zOrder.zIndex(for: "Image4") - 1
            addChild(profCatt)
            resettacattivo()
        }

        if let frame = layout.frame(for: "profbuon") {
            profBuon = SKSpriteNode(texture: textureFor(baseName: "buoni_1"))
            profBuon.name = "profbuon"
            profBuon.anchorPoint = CGPoint(x: 0, y: 0)
            buonWidth = frame.width
            buonHeight = frame.height
            buonFullHeight = frame.height
            buonLeft = frame.minX
            buonTop = frame.minY
            applyFrame(node: profBuon, left: frame.minX, top: frame.minY, width: buonWidth, height: buonHeight)
            profBuon.zPosition = zOrder.zIndex(for: "Image4") - 1
            addChild(profBuon)
            resettabuono()
        }

        if let frame = layout.frame(for: "bidella") {
            bidella = SKSpriteNode(texture: textureFor(baseName: "bidella_1"))
            bidella.name = "bidella"
            bidella.anchorPoint = CGPoint(x: 0, y: 0)
            bidellaWidth = frame.width
            bidellaHeight = frame.height
            bidellaFullHeight = frame.height
            bidellaLeft = frame.minX
            bidellaTop = frame.minY
            applyFrame(node: bidella, left: frame.minX, top: frame.minY, width: bidellaWidth, height: bidellaHeight)
            bidella.zPosition = zOrder.zIndex(for: "Image4") - 1
            addChild(bidella)
            resettabidella()
        }

        if let frame = layout.frame(for: "schizzi"), let texture = textureFor(baseName: "schizzi") {
            schizzi = SKSpriteNode(texture: texture)
            schizzi.anchorPoint = CGPoint(x: 0, y: 0)
            schizzi.size = frame.size
            schizzi.position = convertPosition(frame: frame)
            schizzi.zPosition = zOrder.zIndex(for: "schizzi")
            schizzi.isHidden = true
            addChild(schizzi)
        }

        if let frame = layout.frame(for: "zampilli1"), let texture = textureFor(baseName: "zampilli") {
            zampilli1 = SKSpriteNode(texture: texture)
            zampilli1.anchorPoint = CGPoint(x: 0, y: 0)
            zampilli1.size = frame.size
            zampilli1.position = convertPosition(frame: frame)
            zampilli1.zPosition = zOrder.zIndex(for: "zampilli")
            zampilli1.isHidden = true
            addChild(zampilli1)
        }
        if let frame = layout.frame(for: "zampilli2"), let texture = textureFor(baseName: "zampilli") {
            zampilli2 = SKSpriteNode(texture: texture)
            zampilli2.anchorPoint = CGPoint(x: 0, y: 0)
            zampilli2.size = frame.size
            zampilli2.position = convertPosition(frame: frame)
            zampilli2.zPosition = zOrder.zIndex(for: "zampilli")
            zampilli2.isHidden = true
            addChild(zampilli2)
        }
        if let frame = layout.frame(for: "zampilli3"), let texture = textureFor(baseName: "zampilli") {
            zampilli3 = SKSpriteNode(texture: texture)
            zampilli3.anchorPoint = CGPoint(x: 0, y: 0)
            zampilli3.size = frame.size
            zampilli3.position = convertPosition(frame: frame)
            zampilli3.zPosition = zOrder.zIndex(for: "zampilli")
            zampilli3.isHidden = true
            addChild(zampilli3)
        }
    }

    private func setupBambini() {
        if let frame = layout.frame(for: "Image30"), let texture = textureFor(baseName: "Image30") {
            bambino1 = SKSpriteNode(texture: texture)
            bambino1.anchorPoint = CGPoint(x: 0, y: 0)
            bambino1.size = frame.size
            bambino1.position = convertPosition(frame: frame)
            bambino1.zPosition = zOrder.zIndex(for: "Image30")
            bambino1.name = "bambino1"
            addChild(bambino1)
        }
        if let frame = layout.frame(for: "Image32"), let texture = textureFor(baseName: "Image32") {
            bambino2 = SKSpriteNode(texture: texture)
            bambino2.anchorPoint = CGPoint(x: 0, y: 0)
            bambino2.size = frame.size
            bambino2.position = convertPosition(frame: frame)
            bambino2.zPosition = zOrder.zIndex(for: "Image32")
            bambino2.name = "bambino2"
            addChild(bambino2)
        }
        if let frame = layout.frame(for: "Image34"), let texture = textureFor(baseName: "Image34") {
            bambino3 = SKSpriteNode(texture: texture)
            bambino3.anchorPoint = CGPoint(x: 0, y: 0)
            let size = texture.size()
            bambino3.size = size
            bambino3.position = CGPoint(x: frame.minX, y: baseSize.height - frame.minY - size.height)
            bambino3.zPosition = zOrder.zIndex(for: "Image34")
            bambino3.name = "bambino3"
            addChild(bambino3)
        }
    }

    private func textureFor(baseName: String) -> SKTexture? {
        let sharedDesks: Set<String> = ["Image3","Image6","Image9","Image12","Image15","Image18","Image21","Image24","Image27"]
        let sharedEdges: Set<String> = ["Image4","Image7","Image10","Image13","Image16","Image19","Image22","Image25","Image28"]
        let sharedMids: Set<String> = ["Image5","Image8","Image11","Image14","Image17","Image20","Image23","Image26","Image29"]
        let resolvedName: String
        if sharedDesks.contains(baseName) {
            resolvedName = "Image3"
        } else if sharedEdges.contains(baseName) {
            resolvedName = "Image4"
        } else if sharedMids.contains(baseName) {
            resolvedName = "Image5"
        } else {
            resolvedName = baseName
        }

        let compactName = resolvedName.replacingOccurrences(of: "_", with: "")
        let extensions = ["png", "jpg", "JPG", "jpeg", "JPEG"]

        if usePrivateFaces {
            let privateCandidates = [resolvedName, compactName]
            for name in privateCandidates {
                for ext in extensions {
                    if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "images/VA") {
                        if let img = UIImage(contentsOfFile: url.path) {
                            let tex = SKTexture(image: img)
                            tex.filteringMode = .nearest
                            return tex
                        }
                    }
                }
            }
        }

        if let slot = slotForBaseName(resolvedName), let custom = ImageStore.shared.image(for: slot) {
            let tex = SKTexture(image: custom)
            tex.filteringMode = .nearest
            return tex
        }

        let publicCandidates = [resolvedName]
        for name in publicCandidates {
            for ext in extensions {
                if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "images")
                    ?? Bundle.main.url(forResource: name, withExtension: ext) {
                    if let img = UIImage(contentsOfFile: url.path) {
                        let tex = SKTexture(image: img)
                        tex.filteringMode = .nearest
                        return tex
                    }
                }
            }
        }
        return nil
    }

    private func slotForBaseName(_ baseName: String) -> CharacterSlot? {
        switch baseName {
        case "cattivi_1": return .cattivo1
        case "cattivi_2": return .cattivo2
        case "cattivi_3": return .cattivo3
        case "buoni_1": return .buono1
        case "buoni_2": return .buono2
        case "buoni_3": return .buono3
        case "bidella_1": return .bidella
        case "perla_1": return .perla
        default: return nil
        }
    }

    private func croppedTextureIfNeeded(texture: SKTexture, frame: CGRect) -> SKTexture {
        let size = texture.size()
        if size.width <= frame.width && size.height <= frame.height {
            return texture
        }
        let w = min(frame.width, size.width) / size.width
        let h = min(frame.height, size.height) / size.height
        let rect = CGRect(x: 0, y: 1.0 - h, width: w, height: h)
        let cropped = SKTexture(rect: rect, in: texture)
        cropped.filteringMode = .nearest
        return cropped
    }

    private func convertPosition(frame: CGRect) -> CGPoint {
        CGPoint(x: frame.minX, y: baseSize.height - frame.minY - frame.height)
    }

    private func applyFrame(node: SKSpriteNode, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) {
        node.size = CGSize(width: width, height: height)
        node.position = CGPoint(x: left, y: baseSize.height - top - height)
    }

    private func startLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard let state = gameState, state.running, !state.paused else { return }

        if state.inPentathlon {
            tickPentathlon()
            return
        }

        switch state.level {
        case 1:
            scorriCattivo()
        case 2:
            scorriCattivo()
            scorriBuono()
        default:
            if attivaBidella {
                scorriBidella()
            } else if Int.random(in: 1...100) == 30 {
                attivaBidella = true
                scorriBidella()
            } else {
                scorriCattivo()
                scorriBuono()
            }
        }
    }

    private func tickPentathlon() {
        guard let state = gameState else { return }
        if !pentathlonActive {
            pentathlonActive = true
            pentathlonSuccessCount = 0
            //queuePentathlonRule(for: .memory)
            return
        }

        if pentathlonMode == .sequence, pentathlonSyncActive {
            guard let state = gameState else { return }
            if pentathlonSyncPendingReposition {
                pentathlonSyncPendingReposition = false
                repositionSyncNodes()
                return
            }
            let speed = max(1, state.velocita / 5)
            let maxSteps = max(1, Int(ceil(120.0 / Double(speed))))
            for node in pentathlonSyncNodes where !node.isHidden {
                let fullHeight = isSyncBuono(node) ? buonFullHeight : cattFullHeight
                node.size = CGSize(width: node.size.width, height: min(fullHeight, node.size.height + CGFloat(speed)))
            }
            pentathlonSyncTickCount += 1
            if pentathlonSyncTickCount >= maxSteps {
                pentathlonSyncTickCount = 0
                for node in pentathlonSyncNodes {
                    node.isHidden = true
                }
                pentathlonSyncPendingReposition = true
            }
        }

        if pentathlonMode == .quickCalc, pentathlonRiskActive {
            let speed = state.velocita
            let duration = riskCycleDuration()
            if speed != pentathlonRiskLastSpeed || abs(duration - pentathlonRiskLastDuration) > 0.05 {
                pentathlonRiskLastSpeed = speed
                pentathlonRiskLastDuration = duration
                removeAction(forKey: pentathlonRiskCycleKey)
                repositionRiskNodes(moveDuration: duration * 0.6)
                startRiskCycle()
            }
        }

        if pentathlonMode == .intruder, pentathlonSeatActive {
            let speed = state.velocita
            if speed != pentathlonSeatLastSpeed {
                pentathlonSeatLastSpeed = speed
                runSwapRevealSequence()
            }
        }
    }

    private func startPentathlonMode() {
        clearPentathlonNodes()
        profCatt.isHidden = true
        profBuon.isHidden = true
        bidella.isHidden = true
        switch pentathlonMode {
        case .memory:
            pentathlonLabel.text = "Pentathlon 1/5: Memory"
            pentathlonLabel.isHidden = false
            startMemoryRound()
        case .sequence:
            pentathlonLabel.text = "Pentathlon 2/5: Riflessi"
            pentathlonLabel.isHidden = false
            pentathlonSuccessCount = 0
            startSyncMinigame()
        case .intruder:
            pentathlonLabel.text = "Pentathlon 3/5: Scambio di posto"
            pentathlonLabel.isHidden = false
            pentathlonSuccessCount = 0
            startSwapMemoryRound()
        case .quickCalc:
            pentathlonLabel.text = "Pentathlon 4/5: Rischio controllato"
            pentathlonLabel.isHidden = false
            startRiskRound()
        case .reflex:
            pentathlonLabel.text = "Pentathlon 5/5: Sequenza"
            pentathlonLabel.isHidden = false
            pentathlonSuccessCount = 0
            startSequenceRound()
        }
    }

    private func finishPentathlonMode() {
        if pentathlonMode == .reflex {
            endPentathlon()
            return
        }
        let current = pentathlonMode
        let next = PentathlonMode(rawValue: current.rawValue + 1)
        gameState?.paused = true
        onShowPentathlonComplete?(current.rawValue, next?.rawValue)
    }

    private func endPentathlon() {
        guard let state = gameState else { return }
        state.inPentathlon = false
        state.running = false
        state.gameOver = true
        pentathlonLabel.isHidden = true
        clearPentathlonNodes()
    }

    private func clearPentathlonNodes() {
        for node in pentathlonCards { node.removeFromParent() }
        pentathlonCards.removeAll()
        pentathlonCardMap.removeAll()
        pentathlonFlipped.removeAll()
        pentathlonFirstPick = nil
        pentathlonMatchedPairs = 0
        for node in pentathlonCalcNodes { node.removeFromParent() }
        pentathlonCalcNodes.removeAll()
        pentathlonSequence.removeAll()
        pentathlonSequenceTextures.removeAll()
        pentathlonSequenceTextureMap.removeAll()
        pentathlonInputIndex = 0
        for (_, node) in pentathlonSequenceCovers { node.removeFromParent() }
        pentathlonSequenceCovers.removeAll()
        pentathlonIntruderName = nil
        pentathlonIntruderTargetIndex = nil
        pentathlonIntruderBasePositions.removeAll()
        pentathlonIntruderBaseTextures.removeAll()
        pentathlonIntruderAltTextures.removeAll()
        pentathlonIntruderActive = false
        for node in pentathlonSyncNodes { node.removeFromParent() }
        pentathlonSyncNodes.removeAll()
        pentathlonSyncCattivi.removeAll()
        pentathlonSyncBuoni.removeAll()
        pentathlonSyncActive = false
        pentathlonSyncTickCount = 0
        pentathlonSyncPendingReposition = false
        pentathlonSwapPositions.removeAll()
        pentathlonSwapTargetIndices.removeAll()
        pentathlonSwapTextures.removeAll()
        pentathlonSwapBaseTextures.removeAll()
        pentathlonSwapSelected.removeAll()
        pentathlonSwapActive = false
        pentathlonSwapFirstPick = nil
        pentathlonSwapFirstPickTime = 0
        pentathlonSwapInstruction.isHidden = true
        pentathlonSwapCountdown.isHidden = true
        for node in pentathlonSeatNodes.values { node.removeFromParent() }
        pentathlonSeatNodes.removeAll()
        for node in pentathlonSeatCovers.values { node.removeFromParent() }
        pentathlonSeatCovers.removeAll()
        pentathlonSeatTextures.removeAll()
        pentathlonSeatOrder.removeAll()
        pentathlonSeatTargets.removeAll()
        pentathlonSeatTargetIndex = 0
        pentathlonSeatCenterNode.removeFromParent()
        pentathlonSeatActive = false
        pentathlonSeatLastSpeed = -1
        for node in pentathlonLogicNodes.values { node.removeFromParent() }
        pentathlonLogicNodes.removeAll()
        pentathlonLogicActive = false
        pentathlonLogicRuleIndex = 0
        pentathlonLogicViolationIndex = nil
        for node in pentathlonMovingNodes { node.removeFromParent() }
        pentathlonMovingNodes.removeAll()
        pentathlonMovingPositions.removeAll()
        pentathlonMovingActive = false
        for node in pentathlonRiskNodes.values { node.removeFromParent() }
        pentathlonRiskNodes.removeAll()
        pentathlonRiskTargets.removeAll()
        pentathlonRiskActive = false
        pentathlonRiskTypes.removeAll()
        removeAction(forKey: pentathlonRiskCycleKey)
        hidePerlaHint()
    }

    private func showPerlaHint(for mode: PentathlonMode) {
        pentathlonPerlaMode = mode
        let gameFrame = layout.frame(for: "Image1") ?? CGRect(x: 0, y: 0, width: baseSize.width, height: baseSize.height)
        let x = gameFrame.minX + gameFrame.width - 40
        let yTop = gameFrame.minY + 40
        let y = baseSize.height - yTop
        let pos = CGPoint(x: x, y: y)
        pentathlonPerlaHint.position = pos
        pentathlonPerlaGlow.position = pos
        pentathlonPerlaHint.isHidden = false
        pentathlonPerlaGlow.isHidden = false
        pentathlonPerlaHint.removeAllActions()
        pentathlonPerlaGlow.removeAllActions()
        let pulse = SKAction.sequence([
            .scale(to: 1.15, duration: 0.3),
            .scale(to: 1.0, duration: 0.3)
        ])
        pentathlonPerlaHint.run(.repeat(pulse, count: 2))
        pentathlonPerlaGlow.run(.repeat(pulse, count: 2))
    }

    private func hidePerlaHint() {
        pentathlonPerlaHint.isHidden = true
        pentathlonPerlaGlow.isHidden = true
        pentathlonPerlaMode = nil
    }

    private func queuePentathlonRule(for mode: PentathlonMode) {
        pendingPentathlonMode = mode
        pentathlonMode = mode
        gameState?.paused = true
        onShowPentathlonRule?(mode.rawValue)
    }

    func startPendingPentathlonMode() {
        guard pendingPentathlonMode != nil else { return }
        pendingPentathlonMode = nil
        startPentathlonMode()
    }

    func queuePentathlonMode(rawValue: Int) {
        guard let mode = PentathlonMode(rawValue: rawValue) else { return }
        queuePentathlonRule(for: mode)
    }

    func restartPentathlonSequenceAfterRetry() {
        resetSequenceCovers()
        showSequenceStep(index: 0)
    }

    func restartPentathlonSyncAfterRetry() {
        startSyncMinigame()
    }

    func currentPentathlonModeRawValue() -> Int? {
        guard gameState?.inPentathlon == true else { return nil }
        return pentathlonMode.rawValue
    }

    func restartPentathlonAfterRetry() {
        switch pentathlonMode {
        case .intruder:
            startSwapMemoryRound()
        case .sequence:
            restartPentathlonSyncAfterRetry()
        case .reflex:
            restartPentathlonSequenceAfterRetry()
        case .quickCalc:
            startRiskRound()
        default:
            return
        }
    }

    func debugSkipPentathlonMode() {
        finishPentathlonMode()
    }

    private func setupSequenceCovers() {
        if !pentathlonSequenceCovers.isEmpty { return }
        for i in 0..<posizioni.count {
            let cover = SKSpriteNode(color: .lightGray, size: CGSize(width: cattWidth, height: cattFullHeight))
            cover.name = "seqCover_\(i)"
            cover.anchorPoint = CGPoint(x: 0, y: 0)
            let pos = posizioni[i]
            let left = pos.0 + campoLeft - 10
            let top = pos.1 + 110 + campoTop + spawnYOffset - 120
            applyFrame(node: cover, left: left, top: top, width: cattWidth, height: cattFullHeight)
            cover.zPosition = zOrder.zIndex(for: "Image4") - 1
            addChild(cover)
            pentathlonSequenceCovers[i] = cover
        }
    }

    private func resetSequenceCovers() {
        for (_, cover) in pentathlonSequenceCovers {
            cover.texture = nil
            cover.color = .lightGray
            cover.colorBlendFactor = 0
        }
    }

    private func revealSequenceCover(index: Int) {
        guard let cover = pentathlonSequenceCovers[index] else { return }
        let texName = pentathlonSequenceTextureMap[index] ?? "cattivi_1"
        cover.texture = textureFor(baseName: texName)
        cover.color = .clear
        cover.colorBlendFactor = 0
    }

    private func showIntruderGrid(textures: [Int: String]) {
        for (idx, cover) in pentathlonSequenceCovers {
            if let texName = textures[idx] {
                cover.texture = textureFor(baseName: texName)
                cover.color = .clear
                cover.colorBlendFactor = 0
            } else {
                cover.texture = nil
                cover.color = .lightGray
                cover.colorBlendFactor = 0
            }
        }
    }

    private func runSwapRoundSequence(indexA: Int, indexB: Int) {
        for (idx, texName) in pentathlonSwapBaseTextures {
            if let cover = pentathlonSequenceCovers[idx] {
                cover.texture = textureFor(baseName: texName)
                cover.color = .clear
                cover.colorBlendFactor = 0
            }
        }

        run(.sequence([
            .wait(forDuration: 0.4),
            .run { [weak self] in
                guard let self else { return }
                self.resetSequenceCovers()
                self.showSwapCountdown {
                    self.showBaseThenSwap(indexA: indexA, indexB: indexB)
                }
            }
        ]))
    }

    private func showSwapCountdown(onComplete: @escaping () -> Void) {
        pentathlonSwapActive = false
        pentathlonSwapInstruction.isHidden = true
        pentathlonSwapCountdown.isHidden = false
        let steps = ["3", "2", "1"]
        var actions: [SKAction] = []
        for (i, step) in steps.enumerated() {
            actions.append(.run { [weak self] in self?.pentathlonSwapCountdown.text = step })
            actions.append(.wait(forDuration: i == steps.count - 1 ? 0.4 : 0.6))
        }
        actions.append(.run { [weak self] in
            guard let self else { return }
            self.pentathlonSwapCountdown.isHidden = true
            onComplete()
        })
        pentathlonSwapCountdown.run(.sequence(actions))
    }

    private func applySwapTextures(indexA: Int, indexB: Int) {
        var textures = pentathlonSwapBaseTextures
        let temp = textures[indexA]
        textures[indexA] = textures[indexB]
        textures[indexB] = temp
        pentathlonSwapTextures = textures
        for (idx, texName) in textures {
            guard let cover = pentathlonSequenceCovers[idx] else { continue }
            cover.texture = textureFor(baseName: texName)
            cover.color = .clear
            cover.colorBlendFactor = 0
        }
        pentathlonSwapSelected.removeAll()
        pentathlonSwapActive = true
        pentathlonSwapInstruction.text = "Seleziona i due che si sono cambiati di posto"
        pentathlonSwapInstruction.isHidden = false
    }

    private func showBaseThenSwap(indexA: Int, indexB: Int) {
        applySwapTextures(indexA: indexA, indexB: indexB)
    }

    private func highlightSwapSelection(index: Int, selected: Bool) {
        guard let cover = pentathlonSequenceCovers[index] else { return }
        if selected {
            cover.color = .yellow
            cover.colorBlendFactor = 0.35
        } else {
            cover.colorBlendFactor = 0
        }
    }

    private func toggleSwapSelection(index: Int) {
        if pentathlonSwapSelected.contains(index) {
            pentathlonSwapSelected.remove(index)
            highlightSwapSelection(index: index, selected: false)
        } else {
            pentathlonSwapSelected.insert(index)
            highlightSwapSelection(index: index, selected: true)
        }
    }

    private func positionForDesk(index: Int) -> CGPoint {
        let pos = posizioni[index]
        let left = pos.0 + campoLeft - 20
        let top = pos.1 + 110 + campoTop + spawnYOffset - 120
        return CGPoint(x: left, y: baseSize.height - top - 120)
    }

    private func startMemoryRound() {
        pentathlonFirstPick = nil
        pentathlonFlipped.removeAll()
        pentathlonMatchedPairs = 0
        let indices = Array(0..<posizioni.count).shuffled().prefix(8)
        let names = [
            "cattivi_1","cattivi_1",
            "cattivi_2","cattivi_2",
            "buoni_1","buoni_1",
            "buoni_2","buoni_2"
        ].shuffled()
        for (idx, deskIndex) in indices.enumerated() {
            let texName = names[idx]
            let isBuono = texName.hasPrefix("buoni")
            let width = isBuono ? buonWidth : cattWidth
            let height = isBuono ? buonFullHeight : cattFullHeight
            let card = SKSpriteNode(texture: textureFor(baseName: texName))
            card.name = "memCard_\(idx)"
            card.anchorPoint = CGPoint(x: 0, y: 0)
            let pos = posizioni[deskIndex]
            let left = pos.0 + campoLeft - 10
            let top = pos.1 + 110 + campoTop + spawnYOffset - 120
            applyFrame(node: card, left: left, top: top, width: width, height: height)
            card.zPosition = zOrder.zIndex(for: isBuono ? "profbuon" : "profcatt") + profZOffset
            addChild(card)
            pentathlonCards.append(card)
            pentathlonCardMap[card.name ?? ""] = texName
        }
        run(.sequence([.wait(forDuration: 0.5), .run { [weak self] in
            guard let self else { return }
            for card in self.pentathlonCards {
                card.texture = nil
                card.color = .lightGray
            }
        }]))
    }

    private func startSequenceRound() {
        pentathlonSequenceLength = 2
        pentathlonSequence = Array(0..<posizioni.count).shuffled().prefix(pentathlonSequenceLength).map { $0 }
        pentathlonSequenceTextures = orderedSequenceTextures().prefix(pentathlonSequenceLength).map { $0 }
        pentathlonSequenceTextureMap = Dictionary(uniqueKeysWithValues: zip(pentathlonSequence, pentathlonSequenceTextures))
        pentathlonInputIndex = 0
        setupSequenceCovers()
        showSequenceStep(index: 0)
    }

    private func showSequenceStep(index: Int) {
        if index >= pentathlonSequence.count {
            return
        }
        let pos = pentathlonSequence[index]
        let texName = pentathlonSequenceTextureMap[pos] ?? "cattivi_1"
        guard let cover = pentathlonSequenceCovers[pos] else { return }
        cover.texture = textureFor(baseName: texName)
        cover.color = .clear
        cover.run(.sequence([.wait(forDuration: 0.4), .run {
            cover.texture = nil
            cover.color = .lightGray
        }, .wait(forDuration: 0.05), .run {
            self.showSequenceStep(index: index + 1)
        }]))
    }

    private func orderedSequenceTextures() -> [String] {
        return [
            "buoni_1","buoni_2","buoni_3",
            "cattivi_1","cattivi_2","cattivi_3",
            "bidella_1","bidella_1","bidella_1"
        ]
    }

    private func startIntruderRound() {
        clearPentathlonNodes()
        setupSequenceCovers()
        resetSequenceCovers()
        pentathlonIntruderActive = false
        pentathlonIntruderBaseTextures = [:]
        pentathlonIntruderAltTextures = [:]

        let positions = Array(0..<posizioni.count).shuffled().prefix(6).map { $0 }
        pentathlonIntruderBasePositions = positions
        let faces = [
            "cattivi_1","cattivi_2","cattivi_3",
            "buoni_1","buoni_2","buoni_3"
        ].shuffled()
        for (i, idx) in positions.enumerated() {
            pentathlonIntruderBaseTextures[idx] = faces[i]
        }

        let target = positions.randomElement() ?? positions[0]
        pentathlonIntruderTargetIndex = target
        let current = pentathlonIntruderBaseTextures[target] ?? "cattivi_1"
        let alt = faces.first(where: { $0 != current }) ?? "buoni_1"
        pentathlonIntruderAltTextures = pentathlonIntruderBaseTextures
        pentathlonIntruderAltTextures[target] = alt

        pentathlonSwapInstruction.text = "Seleziona il banco che cambia tra A e B"
        pentathlonSwapInstruction.isHidden = true

        run(.sequence([
            .run { [weak self] in self?.showIntruderGrid(textures: self?.pentathlonIntruderBaseTextures ?? [:]) },
            .wait(forDuration: 0.5),
            .run { [weak self] in self?.showIntruderGrid(textures: self?.pentathlonIntruderAltTextures ?? [:]) },
            .wait(forDuration: 0.5),
            .run { [weak self] in self?.showIntruderGrid(textures: self?.pentathlonIntruderBaseTextures ?? [:]) },
            .wait(forDuration: 0.5),
            .run { [weak self] in self?.showIntruderGrid(textures: self?.pentathlonIntruderAltTextures ?? [:]) },
            .wait(forDuration: 0.2),
            .run { [weak self] in
                guard let self else { return }
                self.pentathlonIntruderActive = true
                self.pentathlonSwapInstruction.isHidden = false
            }
        ]))
    }

    private func startQuickCalcRound() {
        clearPentathlonNodes()
        setupSequenceCovers()
        resetSequenceCovers()

        let positions = Array(0..<posizioni.count)
        pentathlonSwapPositions = positions
        let baseFaces = [
            "cattivi_1","cattivi_2","cattivi_3",
            "buoni_1","buoni_2","buoni_3"
        ]
        let extraFaces = baseFaces.shuffled().prefix(3)
        let faceNames = (baseFaces + extraFaces).shuffled()

        pentathlonSwapTextures = [:]
        pentathlonSwapBaseTextures = [:]
        pentathlonSwapSelected.removeAll()
        pentathlonSwapActive = false
        pentathlonSwapInstruction.isHidden = true
        pentathlonSwapCountdown.isHidden = true
        for (i, idx) in positions.enumerated() {
            let texName = faceNames[i]
            pentathlonSwapTextures[idx] = texName
            pentathlonSwapBaseTextures[idx] = texName
        }

        var indexA = positions.randomElement() ?? 0
        var indexB = positions.randomElement() ?? 1
        var guardCount = 0
        while (indexA == indexB || pentathlonSwapTextures[indexA] == pentathlonSwapTextures[indexB]) && guardCount < 20 {
            indexA = positions.randomElement() ?? indexA
            indexB = positions.randomElement() ?? indexB
            guardCount += 1
        }
        pentathlonSwapTargetIndices = [indexA, indexB]
        runSwapRoundSequence(indexA: indexA, indexB: indexB)
    }

    private func startLogicRound() {
        clearPentathlonNodes()
        pentathlonLogicActive = false
        pentathlonLogicRuleIndex = Int.random(in: 0...2)
        pentathlonLogicViolationIndex = nil

        let lateral = [0, 1, 2, 3, 5, 6, 7, 8].shuffled()
        let good = ["buoni_1","buoni_2","buoni_3"]
        let bad = ["cattivi_1","cattivi_2","cattivi_3"]
        let extras = ["bidella_1","perla_1"]
        var pool = (good + bad + extras).shuffled()

        var assigned: [Int: String] = [:]
        for idx in lateral {
            assigned[idx] = pool.removeFirst()
        }

        switch pentathlonLogicRuleIndex {
        case 0: // no two cattivi adjacent (left-right in same row)
            let violatingPair = [(0,1),(1,2),(3,5),(6,7),(7,8)].randomElement() ?? (0,1)
            assigned[violatingPair.0] = bad[0]
            assigned[violatingPair.1] = bad[1]
            pentathlonLogicViolationIndex = violatingPair.1
        case 1: // bidella must be top row
            assigned[0] = "bidella_1"
            pentathlonLogicViolationIndex = 0
            if Int.random(in: 0...1) == 0 {
                assigned[0] = good[0]
                let target = [3,5,6,7,8].randomElement() ?? 3
                assigned[target] = "bidella_1"
                pentathlonLogicViolationIndex = target
            }
        default: // perla not center (index 4)
            let target = Int.random(in: 0...1) == 0 ? 4 : [0,1,2,3,5,6,7,8].randomElement() ?? 0
            assigned[target] = "perla_1"
            pentathlonLogicViolationIndex = target == 4 ? 4 : target
        }

        for (idx, texName) in assigned {
            let node = makeLogicNode(textureName: texName, index: idx)
            pentathlonLogicNodes[idx] = node
        }

        pentathlonLogicActive = true
    }

    private func startMovingTargetRound() {
        clearPentathlonNodes()
        pentathlonMovingActive = true
        pentathlonMovingNodes.removeAll()
        pentathlonMovingPositions.removeAll()

        let lateral = [0, 1, 2, 3, 5, 6, 7, 8].shuffled()
        let cattivi = ["cattivi_1","cattivi_2","cattivi_3"]
        let buoni = ["buoni_1","buoni_2","buoni_3"]
        let textures = (cattivi + buoni).shuffled()

        for (i, idx) in lateral.prefix(6).enumerated() {
            let texName = textures[i]
            let node = makeMovingNode(textureName: texName, index: idx, slot: i)
            pentathlonMovingNodes.append(node)
            if let name = node.name {
                pentathlonMovingPositions[name] = idx
            }
        }

        runMovingCycle()
    }

    private func makeMovingNode(textureName: String, index: Int, slot: Int) -> SKSpriteNode {
        let tex = textureFor(baseName: textureName)
        let node = SKSpriteNode(texture: tex)
        let isCattivo = textureName.hasPrefix("cattivi")
        node.name = isCattivo ? "moveCatt_\(slot)" : "moveBuon_\(slot)"
        node.anchorPoint = CGPoint(x: 0, y: 0)
        let (width, fullHeight) = sizeForTextureName(textureName)
        let frame = pentathlonDeskFrame(index: index, offsetY: -120, width: width, height: fullHeight)
        node.position = frame.origin
        node.size = CGSize(width: width, height: fullHeight)
        node.zPosition = zOrder.zIndex(for: "profcatt") + 2
        addChild(node)
        return node
    }

    private func runMovingCycle() {
        guard pentathlonMovingActive else { return }
        let duration = movingCycleDuration()
        var occupied = Set<Int>()
        var newPositions: [String: Int] = [:]

        for node in pentathlonMovingNodes {
            guard let name = node.name, let current = pentathlonMovingPositions[name] else { continue }
            let neighbors = pentathlonNeighbors(for: current).shuffled()
            let target = neighbors.first(where: { !occupied.contains($0) }) ?? current
            occupied.insert(target)
            newPositions[name] = target

            let frame = pentathlonDeskFrame(index: target, offsetY: -120, width: node.size.width, height: node.size.height)
            let move = SKAction.move(to: frame.origin, duration: duration)
            move.timingMode = .easeInEaseOut
            node.run(move)
        }

        pentathlonMovingPositions = newPositions
        run(.sequence([.wait(forDuration: duration + 0.1), .run { [weak self] in
            self?.runMovingCycle()
        }]))
    }

    private func movingCycleDuration() -> TimeInterval {
        guard let state = gameState else { return 1.0 }
        return max(0.45, 1.6 - Double(state.velocita) * 0.01)
    }

    private func pentathlonNeighbors(for index: Int) -> [Int] {
        let row = index / 3
        let col = index % 3
        var list: [Int] = []
        if row > 0 { list.append(index - 3) }
        if row < 2 { list.append(index + 3) }
        if col > 0 { list.append(index - 1) }
        if col < 2 { list.append(index + 1) }
        return list
    }

    private func makeLogicNode(textureName: String, index: Int) -> SKSpriteNode {
        let tex = textureFor(baseName: textureName)
        let node = SKSpriteNode(texture: tex)
        node.name = "logicNode_\(index)"
        node.anchorPoint = CGPoint(x: 0, y: 0)
        let (width, fullHeight) = sizeForTextureName(textureName)
        let pos = posizioni[index]
        let left = pos.0 + campoLeft - 10
        let top = pos.1 + 110 + campoTop + spawnYOffset - 120
        let bottom = baseSize.height - top - fullHeight
        node.position = CGPoint(x: left, y: bottom)
        node.size = CGSize(width: width, height: fullHeight)
        node.zPosition = zOrder.zIndex(for: "profcatt") + 2
        addChild(node)
        return node
    }

    private func startRiskRound() {
        clearPentathlonNodes()
        pentathlonRiskActive = false
        pentathlonRiskNodes.removeAll()
        pentathlonRiskTargets.removeAll()
        pentathlonRiskTypes.removeAll()
        pentathlonRiskLastSpeed = -1
        pentathlonRiskLastDuration = -1

        let cattivi = ["cattivi_1","cattivi_2","cattivi_3"].shuffled()
        let buoni = ["buoni_1","buoni_2","buoni_3"].shuffled()

        var guardCount = 0
        while guardCount < 20 {
            let indices = Array(0..<posizioni.count).shuffled().prefix(6)
            let positions = Array(indices)
            var assigned: [Int: String] = [:]
            for i in 0..<3 {
                assigned[positions[i]] = cattivi[i]
            }
            for i in 0..<3 {
                assigned[positions[i + 3]] = buoni[i]
            }

            let targetSet = targetCattiviWithAdjacentBuono(assigned: assigned)
            if !targetSet.isEmpty {
                for (idx, texName) in assigned {
                    let node = makeRiskNode(textureName: texName, index: idx)
                    pentathlonRiskNodes[idx] = node
                    pentathlonRiskTypes[idx] = texName
                }
                pentathlonRiskTargets = targetSet
                pentathlonRiskActive = true
                pentathlonRiskLastSpeed = gameState?.velocita ?? -1
                pentathlonRiskLastDuration = riskCycleDuration()
                startRiskCycle()
                return
            }
            guardCount += 1
        }
    }

    private func makeRiskNode(textureName: String, index: Int) -> SKSpriteNode {
        let tex = textureFor(baseName: textureName)
        let node = SKSpriteNode(texture: tex)
        node.name = textureName.hasPrefix("buoni") ? "riskBuon_\(index)" : "riskCatt_\(index)"
        node.anchorPoint = CGPoint(x: 0, y: 0)
        let (width, fullHeight) = sizeForTextureName(textureName)
        let pos = posizioni[index]
        let left = pos.0 + campoLeft - 10
        let top = pos.1 + 110 + campoTop + spawnYOffset - 120
        let bottom = baseSize.height - top - fullHeight
        node.position = CGPoint(x: left, y: bottom)
        node.size = CGSize(width: width, height: fullHeight)
        node.zPosition = zOrder.zIndex(for: "profcatt") + 2
        addChild(node)
        return node
    }

    private func targetCattiviWithAdjacentBuono(assigned: [Int: String]) -> Set<Int> {
        var targets: Set<Int> = []
        for (idx, tex) in assigned where tex.hasPrefix("cattivi") {
            let neighbors = pentathlonNeighbors(for: idx)
            if neighbors.contains(where: { assigned[$0]?.hasPrefix("buoni") == true }) {
                targets.insert(idx)
            }
        }
        return targets
    }

    private func startRiskCycle() {
        removeAction(forKey: pentathlonRiskCycleKey)
        let duration = riskCycleDuration()
        let action = SKAction.sequence([
            .wait(forDuration: duration),
            .run { [weak self] in
                let moveDuration = (self?.riskCycleDuration() ?? duration) * 0.6
                self?.repositionRiskNodes(moveDuration: moveDuration)
                self?.startRiskCycle()
            }
        ])
        run(action, withKey: pentathlonRiskCycleKey)
    }

    private func riskCycleDuration() -> TimeInterval {
        guard let state = gameState else { return 1.0 }
        return max(0.6, 1.8 - Double(state.velocita) * 0.012)
    }

    private func repositionRiskNodes(moveDuration: TimeInterval) {
        guard pentathlonRiskActive else { return }
        let count = pentathlonRiskNodes.count
        guard count > 0 else { return }
        let indices = Array(0..<posizioni.count).shuffled().prefix(count)
        let positions = Array(indices)
        var newTypes: [Int: String] = [:]
        var newNodes: [Int: SKSpriteNode] = [:]

        for (offset, (oldIndex, node)) in pentathlonRiskNodes.enumerated() {
            let newIndex = positions[offset]
            let isBuono = node.name?.hasPrefix("riskBuon_") == true
            let typeName = isBuono ? "buoni_1" : "cattivi_1"
            node.name = isBuono ? "riskBuon_\(newIndex)" : "riskCatt_\(newIndex)"
            newTypes[newIndex] = typeName
            newNodes[newIndex] = node

            let (width, fullHeight) = sizeForTextureName(typeName)
            let pos = posizioni[newIndex]
            let left = pos.0 + campoLeft - 10
            let top = pos.1 + 110 + campoTop + spawnYOffset - 120
            let bottom = baseSize.height - top - fullHeight
            let target = CGPoint(x: left, y: bottom)
            node.run(.move(to: target, duration: moveDuration))
        }

        pentathlonRiskNodes = newNodes
        pentathlonRiskTypes = newTypes
        pentathlonRiskTargets = targetCattiviWithAdjacentBuono(assigned: newTypes)
        if pentathlonRiskTargets.isEmpty {
            pentathlonRiskTargets = targetCattiviWithAdjacentBuono(assigned: newTypes)
        }
    }

    private func startSwapMemoryRound() {
        clearPentathlonNodes()
        pentathlonSeatActive = false
        pentathlonSeatTargets.removeAll()
        pentathlonSeatTargetIndex = 0

        let lateral = [0, 1, 2, 3, 5, 6, 7, 8].shuffled()
        let textures = [
            "buoni_1","buoni_2","buoni_3",
            "cattivi_1","cattivi_2","cattivi_3",
            "bidella_1","perla_1"
        ]

        for (idx, deskIndex) in lateral.enumerated() {
            let texName = textures[idx]
            pentathlonSeatTextures[deskIndex] = texName
            let node = makeSeatNode(textureName: texName, index: deskIndex)
            node.isHidden = true
            pentathlonSeatNodes[deskIndex] = node
        }

        let revealOrder = lateral.shuffled()
        pentathlonSeatOrder = revealOrder
        pentathlonSeatTargets = revealOrder.compactMap { pentathlonSeatTextures[$0] }
        runSwapRevealSequence()
    }

    private func runSwapRevealSequence() {
        guard let state = gameState else { return }
        removeAction(forKey: "swapReveal")
        var actions: [SKAction] = []
        let clamped = max(0, min(100, state.velocita))
        let t = Double(clamped) / 100.0
        // 0 -> slow, 100 -> fast (very visible change)
        let revealDuration = max(0.08, 1.5 - t * 1.4)
        let pause = max(0.05, 1.1 - t * 1.0)
        for deskIndex in pentathlonSeatOrder {
            guard let node = pentathlonSeatNodes[deskIndex],
                  let texName = pentathlonSeatTextures[deskIndex] else { continue }
            let (_, fullHeight) = sizeForTextureName(texName)
            actions.append(.run {
                node.isHidden = false
                node.size = CGSize(width: node.size.width, height: 1)
                node.run(SKAction.customAction(withDuration: revealDuration) { sprite, elapsed in
                    guard let sprite = sprite as? SKSpriteNode else { return }
                    let t = CGFloat(elapsed / revealDuration)
                    let h = 1 + (fullHeight - 1) * t
                    sprite.size = CGSize(width: sprite.size.width, height: h)
                })
            })
            actions.append(.wait(forDuration: revealDuration + pause))
        }
        actions.append(.run { [weak self] in
            self?.flipSwapFaces()
        })
        run(.sequence(actions), withKey: "swapReveal")
    }

    private func flipSwapFaces() {
        pentathlonSeatCovers.removeAll()
        for (deskIndex, texName) in pentathlonSeatTextures {
            guard let node = pentathlonSeatNodes[deskIndex] else { continue }
            let (width, fullHeight) = sizeForTextureName(texName)
            let cover = SKSpriteNode(color: .lightGray, size: CGSize(width: width, height: fullHeight))
            cover.anchorPoint = CGPoint(x: 0, y: 0)
            cover.position = node.position
            cover.zPosition = node.zPosition + 2
            cover.name = "swapCover_\(deskIndex)"
            addChild(cover)
            pentathlonSeatCovers[deskIndex] = cover
        }
        pentathlonSeatTargetIndex = 0
        showSwapCenterTarget()
        pentathlonSeatActive = true
        pentathlonSeatLastSpeed = gameState?.velocita ?? -1
    }

    private func showSwapCenterTarget() {
        pentathlonSeatCenterNode.removeFromParent()
        guard pentathlonSeatTargetIndex < pentathlonSeatTargets.count else { return }
        let texName = pentathlonSeatTargets[pentathlonSeatTargetIndex]
        let (width, fullHeight) = sizeForTextureName(texName)
        let tex = textureFor(baseName: texName)
        let node = SKSpriteNode(texture: tex)
        node.anchorPoint = CGPoint(x: 0, y: 0)
        let pos = posizioni[4]
        let left = pos.0 + campoLeft - 10
        let top = pos.1 + 110 + campoTop + spawnYOffset - 120
        let bottom = baseSize.height - top - fullHeight
        node.position = CGPoint(x: left, y: bottom)
        node.size = CGSize(width: width, height: fullHeight)
        node.zPosition = zOrder.zIndex(for: "profcatt") + 5
        addChild(node)
        pentathlonSeatCenterNode = node
    }

    private func sizeForTextureName(_ name: String) -> (CGFloat, CGFloat) {
        if name.hasPrefix("buoni") || name.hasPrefix("perla") {
            return (buonWidth, buonFullHeight)
        }
        if name.hasPrefix("bidella") {
            return (bidellaWidth, bidellaFullHeight)
        }
        return (cattWidth, cattFullHeight)
    }

    private func makeSeatNode(textureName: String, index: Int) -> SKSpriteNode {
        let tex = textureFor(baseName: textureName)
        let node = SKSpriteNode(texture: tex)
        node.anchorPoint = CGPoint(x: 0, y: 0)
        let (width, fullHeight) = sizeForTextureName(textureName)
        let pos = posizioni[index]
        let left = pos.0 + campoLeft - 10
        let top = pos.1 + 110 + campoTop + spawnYOffset - 120
        let bottom = baseSize.height - top - fullHeight
        node.position = CGPoint(x: left, y: bottom)
        node.size = CGSize(width: width, height: 1)
        let zKey = textureName.hasPrefix("buoni") || textureName.hasPrefix("perla") ? "profbuon" : "profcatt"
        node.zPosition = zOrder.zIndex(for: zKey) + profZOffset
        addChild(node)
        return node
    }

    private func startSyncMinigame() {
        startSyncRound()
    }

    private func startSyncRound() {
        for node in pentathlonSyncNodes { node.removeFromParent() }
        pentathlonSyncNodes.removeAll()
        pentathlonSyncCattivi.removeAll()
        pentathlonSyncBuoni.removeAll()
        pentathlonSyncTickCount = 0
        pentathlonSyncPendingReposition = false

        let indices = Array(0..<posizioni.count).shuffled().prefix(6)
        let positions = indices.count == 6 ? Array(indices) : [0, 1, 2, 3, 4, 5]
        let cattivi = ["cattivi_1","cattivi_2","cattivi_3"].shuffled()
        let buoni = ["buoni_1","buoni_2","buoni_3"].shuffled()

        let cattPositions = Array(positions.prefix(3))
        let buonPositions = Array(positions.suffix(3))

        for (i, idx) in cattPositions.enumerated() {
            pentathlonSyncCattivi.insert(idx)
            let node = makeSyncNode(textureName: cattivi[i], isBuono: false, index: idx)
            pentathlonSyncNodes.append(node)
        }
        for (i, idx) in buonPositions.enumerated() {
            pentathlonSyncBuoni.insert(idx)
            let node = makeSyncNode(textureName: buoni[i], isBuono: true, index: idx)
            pentathlonSyncNodes.append(node)
        }

        pentathlonSyncActive = true
    }

    private func makeSyncNode(textureName: String, isBuono: Bool, index: Int) -> SKSpriteNode {
        let node = SKSpriteNode(texture: textureFor(baseName: textureName))
        node.name = isBuono ? "syncBuon_\(index)" : "syncCatt_\(index)"
        node.anchorPoint = CGPoint(x: 0, y: 0)
        let width = isBuono ? buonWidth : cattWidth
        let fullHeight = isBuono ? buonFullHeight : cattFullHeight
        let pos = posizioni[index]
        let left = pos.0 + campoLeft - 10
        let top = pos.1 + 110 + campoTop + spawnYOffset - 120
        let bottom = baseSize.height - top - fullHeight
        node.position = CGPoint(x: left, y: bottom)
        node.size = CGSize(width: width, height: 1)
        node.zPosition = zOrder.zIndex(for: isBuono ? "profbuon" : "profcatt") + profZOffset
        addChild(node)
        riseSyncNode(node, fullHeight: fullHeight)
        return node
    }

    private func riseSyncNode(_ node: SKSpriteNode, fullHeight: CGFloat) {
        let startHeight: CGFloat = 1
        node.run(SKAction.customAction(withDuration: 0.25) { sprite, elapsed in
            guard let sprite = sprite as? SKSpriteNode else { return }
            let t = CGFloat(elapsed / 0.25)
            let h = startHeight + (fullHeight - startHeight) * t
            sprite.size = CGSize(width: sprite.size.width, height: h)
        })
    }

    private func isSyncBuono(_ node: SKSpriteNode) -> Bool {
        return node.name?.hasPrefix("syncBuon_") ?? false
    }

    private func repositionSyncNodes() {
        let count = pentathlonSyncNodes.count
        guard count > 0 else { return }
        let indices = Array(0..<posizioni.count).shuffled().prefix(count)
        let positions = Array(indices)
        pentathlonSyncCattivi.removeAll()
        pentathlonSyncBuoni.removeAll()
        for (idx, node) in pentathlonSyncNodes.enumerated() {
            let posIndex = positions[idx]
            let isBuono = isSyncBuono(node)
            node.name = isBuono ? "syncBuon_\(posIndex)" : "syncCatt_\(posIndex)"
            if isBuono {
                pentathlonSyncBuoni.insert(posIndex)
            } else {
                pentathlonSyncCattivi.insert(posIndex)
            }
            let width = isBuono ? buonWidth : cattWidth
            let fullHeight = isBuono ? buonFullHeight : cattFullHeight
            let pos = posizioni[posIndex]
            let left = pos.0 + campoLeft - 10
            let top = pos.1 + 110 + campoTop + spawnYOffset - 120
            let bottom = baseSize.height - top - fullHeight
            node.position = CGPoint(x: left, y: bottom)
            node.size = CGSize(width: width, height: 1)
            node.isHidden = false
        }
    }

    private func profCattivo() {
        if let state = gameState, state.level == 3 {
            let n = Int.random(in: 1...3)
            profCatt.texture = textureFor(baseName: "cattivi_\(n)")
        } else {
            profCatt.texture = textureFor(baseName: "cattivi_1")
        }
        alzateCatt = 0
        gameState?.registerCattivoSpawn()
        let pos = posizioni.randomElement() ?? (56, 26)
        cattLeft = pos.0 + campoLeft - 11
        cattTop = pos.1 + 110 + campoTop + spawnYOffset + 0
        resettacattivo()
    }

    private func profBuono() {
        if let state = gameState, state.level == 3 {
            let n = Int.random(in: 1...3)
            profBuon.texture = textureFor(baseName: "buoni_\(n)")
        } else {
            profBuon.texture = textureFor(baseName: "buoni_1")
        }
        alzateBuon = 0
        let pos = posizioni.randomElement() ?? (56, 26)
        buonLeft = pos.0 + campoLeft - 11
        buonTop = pos.1 + 110 + campoTop + spawnYOffset + 0
        resettabuono()
    }

    private func bidellaa() {
        bidella.texture = textureFor(baseName: "bidella_1")
        alzateBidella = 0
        let pos = posizioni.randomElement() ?? (56, 26)
        bidellaLeft = pos.0 + campoLeft - 6
        bidellaTop = pos.1 + 110 + campoTop + spawnYOffset + 0
        resettabidella()
    }

    private func resettabidella() {
        bidellaHeight = 1
        applyFrame(node: bidella, left: bidellaLeft, top: bidellaTop + bidellaFullHeight, width: bidellaWidth, height: bidellaHeight)
    }

    private func resettabuono() {
        buonHeight = 1
        applyFrame(node: profBuon, left: buonLeft, top: buonTop + buonFullHeight, width: buonWidth, height: buonHeight)
    }

    private func resettacattivo() {
        cattHeight = 1
        applyFrame(node: profCatt, left: cattLeft, top: cattTop + cattFullHeight, width: cattWidth, height: cattHeight)
    }

    private func scorriBidella() {
        guard let state = gameState else { return }
        let speed = max(1, state.velocita / 5)
        if bidellaHeight < bidellaFullHeight {
            bidellaHeight += CGFloat(speed)
        }
        if alzateBidella < 120 / speed {
            bidellaTop -= CGFloat(speed)
            applyFrame(node: bidella, left: bidellaLeft, top: bidellaTop, width: bidellaWidth, height: bidellaHeight)
            alzateBidella += 1
        } else {
            attivaBidella = false
            state.addPoints(-1)
            bidellaa()
        }
    }

    private func scorriBuono() {
        guard let state = gameState else { return }
        let speed = max(1, state.velocita / 5)
        if buonHeight < buonFullHeight {
            buonHeight += CGFloat(speed)
        }
        if alzateBuon < 120 / speed {
            buonTop -= CGFloat(speed)
            applyFrame(node: profBuon, left: buonLeft, top: buonTop, width: buonWidth, height: buonHeight)
            alzateBuon += 1
        } else {
            state.addPoints(1)
            profBuono()
        }
    }

    private func scorriCattivo() {
        guard let state = gameState else { return }
        let speed = max(1, state.velocita / 5)
        if cattHeight < cattFullHeight {
            cattHeight += CGFloat(speed)
        }
        if alzateCatt < 120 / speed {
            cattTop -= CGFloat(speed)
            applyFrame(node: profCatt, left: cattLeft, top: cattTop, width: cattWidth, height: cattHeight)
            alzateCatt += 1
        } else {
            profCattivo()
            state.sfuggiti += 1
            state.addPoints(-1)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if noteRect.contains(location) {
            onShowNote?()
            return
        }
        #if targetEnvironment(macCatalyst)
        cursorDown?.set()
        #endif
        if let state = gameState, state.inPentathlon {
            handlePentathlonTouches(touches)
            return
        }
        if let node = atPoint(location) as? SKNode, node.name == "deskLink" {
            if let url = URL(string: "https://www.semproxlab.it") {
                UIApplication.shared.open(url)
            }
            return
        }
        guard let state = gameState, state.running, !state.paused else { return }
        if !playFieldRect.contains(location) {
            return
        }
        let node = atPoint(location)

        switch node.name {
        case "profcatt":
            colpitoCattivo(at: location)
        case "profbuon":
            colpitoBuono(at: location)
        case "bidella":
            colpitaBidella()
        case "bambino1":
            colpitoBambino(zampillo: zampilli1)
        case "bambino2":
            colpitoBambino(zampillo: zampilli2)
        case "bambino3":
            colpitoBambino(zampillo: zampilli3)
        default:
            colpoFuori()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if targetEnvironment(macCatalyst)
        cursorUp?.set()
        #endif
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if targetEnvironment(macCatalyst)
        cursorUp?.set()
        #endif
    }

    private func handlePentathlonTouch(at location: CGPoint) {
        guard let state = gameState else { return }
        switch pentathlonMode {
        case .memory:
            guard let card = pentathlonCards.first(where: { $0.contains(location) }) else { return }
            guard let name = card.name, !pentathlonFlipped.contains(name) else { return }
            if let texName = pentathlonCardMap[name], let tex = textureFor(baseName: texName) {
                card.texture = tex
                card.color = .clear
                pentathlonFlipped.insert(name)
            }
            if pentathlonFirstPick == nil {
                pentathlonFirstPick = name
                return
            }
            let first = pentathlonFirstPick!
            pentathlonFirstPick = nil
            if pentathlonCardMap[first] == pentathlonCardMap[name] {
                state.addPoints(2)
                if state.suoni { SoundPlayer.shared.play(name: "siii.wav") }
                pentathlonMatchedPairs += 1
                if pentathlonMatchedPairs >= 4 {
                    finishPentathlonMode()
                }
            } else {
                state.addPoints(-1)
                if state.suoni { SoundPlayer.shared.play(name: "nooo.wav") }
                showZampilli(at: location)
                let firstCard = pentathlonCards.first(where: { $0.name == first })
                card.run(.sequence([.wait(forDuration: 0.4), .run {
                    card.texture = nil
                    card.color = .lightGray
                    firstCard?.texture = nil
                    firstCard?.color = .lightGray
                    self.pentathlonFlipped.remove(name)
                    self.pentathlonFlipped.remove(first)
                }]))
            }
        case .intruder:
            guard pentathlonSeatActive else { return }
            guard let cover = pentathlonSeatCovers.values.first(where: { $0.contains(location) }) else { return }
            guard let name = cover.name else { return }
            let idxString = name.replacingOccurrences(of: "swapCover_", with: "")
            guard let idx = Int(idxString) else { return }
            guard pentathlonSeatTargetIndex < pentathlonSeatTargets.count else { return }
            let expected = pentathlonSeatTargets[pentathlonSeatTargetIndex]
            if pentathlonSeatTextures[idx] == expected {
                cover.removeFromParent()
                pentathlonSeatCovers.removeValue(forKey: idx)
                pentathlonSeatTargetIndex += 1
                if state.suoni { SoundPlayer.shared.play(name: "siii.wav") }
                if pentathlonSeatTargetIndex >= pentathlonSeatTargets.count {
                    finishPentathlonMode()
                } else {
                    showSwapCenterTarget()
                }
            } else {
                state.addPoints(-2)
                if state.suoni { SoundPlayer.shared.play(name: "nooo.wav") }
                showZampilli(at: location)
                pentathlonSeatActive = false
                gameState?.paused = true
                onShowPentathlonRetry?()
            }
        case .quickCalc:
            guard pentathlonRiskActive else { return }
            guard let tapped = pentathlonRiskNodes.first(where: { $0.value.contains(location) }) else { return }
            let idx = tapped.key
            let isBuono = pentathlonRiskTypes[idx]?.hasPrefix("buoni") == true
            if isBuono {
                state.addPoints(-2)
                if state.suoni { SoundPlayer.shared.play(name: "nooo.wav") }
                showZampilli(at: location)
                pentathlonRiskActive = false
                gameState?.paused = true
                onShowPentathlonRetry?()
                return
            }
            if pentathlonRiskTargets.contains(idx) {
                state.addPoints(2)
                if state.suoni { SoundPlayer.shared.play(name: "profmorto.wav") }
                tapped.value.removeFromParent()
                pentathlonRiskNodes.removeValue(forKey: idx)
                pentathlonRiskTargets.remove(idx)
                pentathlonRiskTypes.removeValue(forKey: idx)
                pentathlonRiskTargets = targetCattiviWithAdjacentBuono(assigned: pentathlonRiskTypes)
                let hasCattivi = pentathlonRiskNodes.values.contains { $0.name?.hasPrefix("riskCatt_") == true }
                if !hasCattivi {
                    finishPentathlonMode()
                }
            } else {
                state.addPoints(-2)
                if state.suoni { SoundPlayer.shared.play(name: "nooo.wav") }
                showZampilli(at: location)
                pentathlonRiskActive = false
                gameState?.paused = true
                onShowPentathlonRetry?()
            }
        case .sequence:
            guard pentathlonSyncActive else { return }
            guard let tapped = pentathlonSyncNodes.first(where: { $0.contains(location) }) else { return }
            guard let name = tapped.name else { return }
            if name.hasPrefix("syncBuon_") {
                state.addPoints(-2)
                if state.suoni { SoundPlayer.shared.play(name: "fuori.wav") }
                showZampilli(at: location)
                pentathlonSyncActive = false
                gameState?.paused = true
                onShowPentathlonRetry?()
                return
            }
            if name.hasPrefix("syncCatt_") {
                state.addPoints(1)
                if state.suoni { SoundPlayer.shared.play(name: "profmorto.wav") }
                tapped.isHidden = true
                if let removeIndex = pentathlonSyncNodes.firstIndex(of: tapped) {
                    pentathlonSyncNodes.remove(at: removeIndex)
                }
                if pentathlonSyncNodes.first(where: { $0.name?.hasPrefix("syncCatt_") == true }) == nil {
                    finishPentathlonMode()
                }
            }
            return
        case .reflex:
            guard let idx = nearestPentathlonDeskIndex(to: location, offsetY: -120) else { return }
            if idx == pentathlonSequence[pentathlonInputIndex] {
                revealSequenceCover(index: idx)
                if state.suoni { SoundPlayer.shared.play(name: "profmorto.wav") }
                pentathlonInputIndex += 1
                if pentathlonInputIndex >= pentathlonSequence.count {
                    state.addPoints(2)
                    if pentathlonSequenceLength >= 9 {
                        finishPentathlonMode()
                    } else {
                        pentathlonSequenceLength += 1
                        pentathlonSequence = Array(0..<posizioni.count).shuffled().prefix(pentathlonSequenceLength).map { $0 }
                        pentathlonSequenceTextures = orderedSequenceTextures().prefix(pentathlonSequenceLength).map { $0 }
                        pentathlonSequenceTextureMap = Dictionary(uniqueKeysWithValues: zip(pentathlonSequence, pentathlonSequenceTextures))
                        pentathlonInputIndex = 0
                        gameState?.paused = true
                        run(.sequence([.wait(forDuration: 1.0), .run { [weak self] in
                            guard let self else { return }
                            self.resetSequenceCovers()
                            self.gameState?.paused = false
                            self.showSequenceStep(index: 0)
                        }]))
                    }
                }
            } else {
                state.addPoints(-1)
                if state.suoni { SoundPlayer.shared.play(name: "fuori.wav") }
                showZampilli(at: location)
                pentathlonSequenceLength = 2
                pentathlonSequence = Array(0..<posizioni.count).shuffled().prefix(pentathlonSequenceLength).map { $0 }
                pentathlonSequenceTextures = orderedSequenceTextures().prefix(pentathlonSequenceLength).map { $0 }
                pentathlonSequenceTextureMap = Dictionary(uniqueKeysWithValues: zip(pentathlonSequence, pentathlonSequenceTextures))
                pentathlonInputIndex = 0
                revealSequenceCover(index: idx)
                gameState?.paused = true
                run(.sequence([.wait(forDuration: 1.0), .run { [weak self] in
                    guard let self else { return }
                    self.resetSequenceCovers()
                    self.onShowPentathlonRetry?()
                }]))
            }
        }
    }

    private func handlePentathlonTouches(_ touches: Set<UITouch>) {
//        guard let state = gameState else { return }
        if let first = touches.first {
            let location = first.location(in: self)
            if !pentathlonPerlaHint.isHidden, pentathlonPerlaHint.contains(location) {
                if let mode = pentathlonPerlaMode {
                    gameState?.paused = true
                    onShowPentathlonRule?(mode.rawValue)
                }
                return
            }
            handlePentathlonTouch(at: location)
        }
    }

    private func nearestDeskIndex(to point: CGPoint) -> Int? {
        var best: (idx: Int, dist: CGFloat)?
        for i in 0..<posizioni.count {
            let p = positionForDesk(index: i)
            let dx = p.x - point.x
            let dy = p.y - point.y
            let d = dx*dx + dy*dy
            if best == nil || d < best!.dist {
                best = (i, d)
            }
        }
        return best?.idx
    }

    private func pentathlonDeskFrame(index: Int, offsetY: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        let pos = posizioni[index]
        let left = pos.0 + campoLeft - 10
        let top = pos.1 + 110 + campoTop + spawnYOffset + offsetY
        let y = baseSize.height - top - height
        return CGRect(x: left, y: y, width: width, height: height)
    }

    private func nearestPentathlonDeskIndex(to point: CGPoint, offsetY: CGFloat) -> Int? {
        var best: (idx: Int, dist: CGFloat)?
        for i in 0..<posizioni.count {
            let frame = pentathlonDeskFrame(index: i, offsetY: offsetY, width: cattWidth, height: cattFullHeight)
            if !frame.contains(point) { continue }
            let center = CGPoint(x: frame.midX, y: frame.midY)
            let dx = center.x - point.x
            let dy = center.y - point.y
            let d = dx*dx + dy*dy
            if best == nil || d < best!.dist {
                best = (i, d)
            }
        }
        return best?.idx
    }

    private func colpitoCattivo(at location: CGPoint) {
        guard let state = gameState else { return }
        showSchizzi(at: location)
        profCattivo()
        profBuono()
        bidellaa()
        attivaBidella = false
        state.colpiti += 1
        state.addPoints(2)
        if state.suoni { SoundPlayer.shared.play(name: "profmorto.wav") }
    }

    private func colpitoBuono(at location: CGPoint) {
        guard let state = gameState else { return }
        showSchizzi(at: location)
        state.sbagliati += 1
        state.addPoints(-2)
        profCattivo()
        profBuono()
        bidellaa()
        attivaBidella = false
        if state.suoni { SoundPlayer.shared.play(name: "profmorto.wav") }
    }

    private func colpitaBidella() {
        guard let state = gameState else { return }
        state.addPoints(5)
        if state.suoni { SoundPlayer.shared.play(name: "bidella.wav") }
        onShowCircolare?()
        attivaBidella = false
        bidellaa()
    }

    private func colpitoBambino(zampillo: SKSpriteNode) {
        guard let state = gameState else { return }
        zampillo.isHidden = false
        zampillo.run(.sequence([.wait(forDuration: 0.1), .hide()]))
        state.addPoints(-1)
        if state.suoni { SoundPlayer.shared.play(name: "bambinomorto.wav") }
    }

    private func colpoFuori() {
        guard let state = gameState else { return }
        state.addPoints(-1)
        if state.suoni { SoundPlayer.shared.play(name: "fuori.wav") }
    }

    private func showSchizzi(at location: CGPoint) {
        schizzi.position = CGPoint(x: location.x - 45, y: location.y - 25)
        schizzi.isHidden = false
        schizzi.run(.sequence([.wait(forDuration: 0.1), .hide()]))
    }

    private func showZampilli(at location: CGPoint) {
        let options = [zampilli1, zampilli2, zampilli3]
        guard let zampillo = options.randomElement() else { return }
        zampillo.position = CGPoint(x: location.x - 45, y: location.y - 25)
        zampillo.isHidden = false
        zampillo.run(.sequence([.wait(forDuration: 0.1), .hide()]))
    }
}
