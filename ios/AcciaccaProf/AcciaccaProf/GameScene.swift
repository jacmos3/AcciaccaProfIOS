import SpriteKit
import UIKit

final class GameScene: SKScene {
    weak var gameState: GameState?
    var onShowCircolare: (() -> Void)?
    var onShowNote: (() -> Void)?

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
            "bidella_1"
        ].compactMap { textureFor(baseName: $0) }

        SKTexture.preload(textures) { [weak self] in
            DispatchQueue.main.async {
                self?.onPreloadComplete?()
            }
        }
    }

    func resetForStart() {
        attivaBidella = false
        profCattivo()
        profBuono()
        bidellaa()
    }

    private func buildScene() {
        removeAllChildren()

        addStaticImages()
        setupDynamicSprites()
        setupBambini()
    }

    private func addStaticImages() {
        let staticNames = [
            "Image1","Image3","Image4","Image5","Image6","Image7","Image8","Image9","Image10",
            "Image11","Image12","Image13","Image14","Image15","Image16","Image17","Image18","Image19",
            "Image20","Image21","Image22","Image23","Image24","Image25","Image26","Image27","Image28",
            "Image29","Image31","Image33","Image35"
        ]

        for name in staticNames {
            guard let frame = layout.frame(for: name), let texture = textureFor(baseName: name) else { continue }
            let node = SKSpriteNode(texture: texture)
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.texture = croppedTextureIfNeeded(texture: texture, frame: frame)
            node.size = frame.size
            node.position = convertPosition(frame: frame)
            node.zPosition = zOrder.zIndex(for: name)
            addChild(node)
        }

        if let frame = layout.frame(for: "Image1") {
            let origin = convertPosition(frame: frame)
            playFieldRect = CGRect(origin: origin, size: frame.size)
        }

        addDeskLink()
        addNoteHotspot()
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
        let y = frame.minY + frame.height * 0.235 - 7
        label.position = CGPoint(x: x, y: baseSize.height - y)
        label.zPosition = zOrder.zIndex(for: "Image3") - 0.5
        addChild(label)
        let frameRect = label.frame
        deskLinkRect = frameRect.insetBy(dx: -8, dy: -6)
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
            profCatt.zPosition = zOrder.zIndex(for: "profcatt") + profZOffset
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
            profBuon.zPosition = zOrder.zIndex(for: "profbuon") + profZOffset
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
            bidella.zPosition = zOrder.zIndex(for: "bidella") + profZOffset
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
            zampilli1.zPosition = zOrder.zIndex(for: "zampilli1")
            zampilli1.isHidden = true
            addChild(zampilli1)
        }
        if let frame = layout.frame(for: "zampilli2"), let texture = textureFor(baseName: "zampilli") {
            zampilli2 = SKSpriteNode(texture: texture)
            zampilli2.anchorPoint = CGPoint(x: 0, y: 0)
            zampilli2.size = frame.size
            zampilli2.position = convertPosition(frame: frame)
            zampilli2.zPosition = zOrder.zIndex(for: "zampilli2")
            zampilli2.isHidden = true
            addChild(zampilli2)
        }
        if let frame = layout.frame(for: "zampilli3"), let texture = textureFor(baseName: "zampilli") {
            zampilli3 = SKSpriteNode(texture: texture)
            zampilli3.anchorPoint = CGPoint(x: 0, y: 0)
            zampilli3.size = frame.size
            zampilli3.position = convertPosition(frame: frame)
            zampilli3.zPosition = zOrder.zIndex(for: "zampilli3")
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

        if let slot = slotForBaseName(resolvedName), let custom = ImageStore.shared.image(for: slot) {
            let tex = SKTexture(image: custom)
            tex.filteringMode = .nearest
            return tex
        }
        let compactName = resolvedName.replacingOccurrences(of: "_", with: "")
        let candidates = [resolvedName, compactName]
        let extensions = ["png", "jpg", "JPG", "jpeg", "JPEG"]
        for name in candidates {
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
        cattLeft = pos.0 + campoLeft - 10
        cattTop = pos.1 + 110 + campoTop + spawnYOffset
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
        buonLeft = pos.0 + campoLeft - 10
        buonTop = pos.1 + 110 + campoTop + spawnYOffset
        resettabuono()
    }

    private func bidellaa() {
        bidella.texture = textureFor(baseName: "bidella_1")
        alzateBidella = 0
        let pos = posizioni.randomElement() ?? (56, 26)
        bidellaLeft = pos.0 + campoLeft - 5
        bidellaTop = pos.1 + 110 + campoTop + spawnYOffset
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
        guard let state = gameState, state.running, !state.paused else { return }
        if deskLinkRect.contains(location) {
            if let url = URL(string: "https://www.semproxlab.it") {
                UIApplication.shared.open(url)
            }
            return
        }
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
}
