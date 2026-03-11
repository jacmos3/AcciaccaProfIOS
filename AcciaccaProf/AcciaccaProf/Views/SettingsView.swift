import SwiftUI
import Photos
import UniformTypeIdentifiers

private struct FacesExportPayload: Codable {
    let version: Int
    let images: [String: String]
}

private extension UTType {
    static let acciaccaProfFaces = UTType(exportedAs: "it.semproxlab.acciaccaprof.faces")
}

private struct FacesExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.acciaccaProfFaces, .json] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ImageStore.shared
    @StateObject private var purchase = PurchaseManager.shared

    @State private var showingPicker = false
    @State private var showPhotoPermissionAlert = false
    @State private var selectedSlot: CharacterSlot?
    @State private var pendingImage: UIImage?
    @State private var cropScale: CGFloat = 1.0
    @State private var cropOffset: CGSize = .zero
    @State private var cropBaseOffset: CGSize = .zero
    @State private var cropBaseScale: CGFloat = 1.0
    @State private var resizingSlot: CharacterSlot?
    @State private var showPurchaseError = false
    @State private var showExport = false
    @State private var showImport = false
    @State private var exportData: Data?
    @State private var showExportAlert = false
    @State private var exportAlertText = ""
    @State private var showImportAlert = false
    @State private var importAlertText = ""

    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(GameCopy.settingsIntro)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Sblocca le personalizzazioni")
                            .font(.headline)
                        Text(GameCopy.settingsUnlockDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if purchase.unlocked {
                            Text("Sblocco attivo")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        } else {
                            HStack(spacing: 10) {
                                if purchase.isLoading {
                                    ProgressView()
                                }
                                actionPill(
                                    title: "Sblocca",
                                    color: .blue,
                                    disabled: purchase.isLoading
                                ) {
                                    Task { await purchase.purchase() }
                                }

                                actionPill(
                                    title: "Ripristina acquisti",
                                    color: .orange,
                                    disabled: purchase.isLoading
                                ) {
                                    Task { await purchase.restore() }
                                }

#if DEBUG
                                actionPill(
                                    title: "Ricarica",
                                    color: .gray,
                                    disabled: purchase.isLoading
                                ) {
                                    Task {
                                        await purchase.refreshProducts()
                                        await purchase.refreshEntitlements()
                                    }
                                }
#endif
                            }
                            if purchase.product == nil {
                                Text("Prodotto non disponibile. Controlla StoreKit Configuration.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Condivisione profili")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            HStack(spacing: 10) {
                                actionPill(
                                    title: "Esporta profili",
                                    color: .purple,
                                    disabled: !purchase.unlocked
                                ) {
                                    exportData = buildExportData()
                                    showExport = exportData != nil
                                }
                                actionPill(
                                    title: "Importa profili",
                                    color: .indigo,
                                    disabled: !purchase.unlocked
                                ) {
                                    showImport = true
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                ForEach(CharacterSlot.allCases) { slot in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            ZStack {
                                if resizingSlot == slot, let image = pendingImage {
                                    editablePreview(image: image)
                                } else {
                                    preview(for: slot)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 120)
                                        .clipped()
                                }
                                if resizingSlot == slot {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.blue, lineWidth: 2)
                                        .allowsHitTesting(false)
                                    facePlaceholder()
                                        .frame(width: 200, height: 240)
                                        .allowsHitTesting(false)
                                }
                            }
                            .frame(width: resizingSlot == slot ? 200 : 100, height: resizingSlot == slot ? 240 : 120)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))

                            VStack(alignment: .leading, spacing: 6) {
                                Text(slot.displayName)
                                if resizingSlot != slot {
                                    HStack(spacing: 8) {
                                        actionPill(
                                            title: "Scegli dalla galleria",
                                            color: .blue,
                                            disabled: !purchase.unlocked
                                        ) {
                                            selectedSlot = slot
                                            requestPhotoAccess()
                                        }

                                        actionPill(
                                            title: "Ridimensiona",
                                            color: .teal,
                                            disabled: !purchase.unlocked
                                        ) {
                                            showingPicker = false
                                            if let img = store.image(for: slot) ?? loadDefaultImage(for: slot) {
                                                pendingImage = img
                                                cropScale = 2.0
                                                cropOffset = .zero
                                                resizingSlot = slot
                                                selectedSlot = nil
                                                cropBaseScale = 2.0
                                                cropBaseOffset = .zero
                                            }
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        if resizingSlot == slot {
                            HStack(spacing: 12) {
                                actionPill(
                                    title: "Salva",
                                    color: .green,
                                    disabled: false
                                ) {
                                    if let slot = resizingSlot ?? selectedSlot, let image = pendingImage, let cropped = cropImage(image: image) {
                                        store.save(image: cropped, for: slot)
                                    }
                                    pendingImage = nil
                                    selectedSlot = nil
                                    resizingSlot = nil
                                }
                                actionPill(
                                    title: "Annulla",
                                    color: .red,
                                    disabled: false
                                ) {
                                    pendingImage = nil
                                    selectedSlot = nil
                                    resizingSlot = nil
                                }
                            }
                        }
                    }
                }
                Section {
                    Button(role: .destructive) {
                        store.resetAll()
                    } label: {
                        Text("Ripristina default")
                    }
                }
            }
            .id(store.version)
            .navigationTitle("Personalizzazioni")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showingPicker) {
            PhotoPicker(onImage: { image in
                showingPicker = false
                if let slot = selectedSlot {
                    store.save(image: image, for: slot)
                }
                pendingImage = nil
                resizingSlot = nil
                cropScale = 1.0
                cropOffset = .zero
                cropBaseScale = 1.0
                cropBaseOffset = .zero
                selectedSlot = nil
            }, onCancel: {
                showingPicker = false
                selectedSlot = nil
                pendingImage = nil
                resizingSlot = nil
            })
        }
        .alert("Accesso alle foto", isPresented: $showPhotoPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Consenti l'accesso alle foto per scegliere un'immagine. Puoi abilitarlo in Impostazioni > Privacy > Foto.")
        }
        .alert("Errore acquisto", isPresented: $showPurchaseError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchase.errorMessage ?? "Errore sconosciuto.")
        }
        .onReceive(purchase.$errorMessage) { newValue in
            if newValue != nil {
                showPurchaseError = true
            }
        }
        .task {
            await purchase.refreshProducts()
            await purchase.refreshEntitlements()
        }
        .fileExporter(
            isPresented: $showExport,
            document: FacesExportDocument(data: exportData ?? Data()),
            contentType: .acciaccaProfFaces,
            defaultFilename: "AcciaccaProf_profili"
        ) { result in
            switch result {
            case .success:
                exportAlertText = "Esportazione completata."
            case .failure:
                exportAlertText = "Esportazione non riuscita."
            }
            showExportAlert = true
        }
        .fileImporter(
            isPresented: $showImport,
            allowedContentTypes: [.acciaccaProfFaces, .json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                let didAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if didAccess { url.stopAccessingSecurityScopedResource() }
                }
                if let data = try? Data(contentsOf: url) {
                    importFromData(data)
                    importAlertText = "Importazione completata."
                } else {
                    importAlertText = "Importazione non riuscita."
                }
                showImportAlert = true
            case .failure:
                importAlertText = "Importazione annullata."
                showImportAlert = true
                break
            }
        }
        .alert("Esportazione", isPresented: $showExportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportAlertText)
        }
        .alert("Importazione", isPresented: $showImportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importAlertText)
        }
    }

    private func preview(for slot: CharacterSlot) -> Image {
        _ = store.version
        if let img = store.image(for: slot) {
            return Image(uiImage: img)
        }
        if let img = loadDefaultImage(for: slot) {
            return Image(uiImage: img)
        }
        return Image(systemName: "person.crop.square")
    }

    private func loadDefaultImage(for slot: CharacterSlot) -> UIImage? {
        store.imageFromBundle(slot: slot)
    }

    private func actionPill(title: String, color: Color, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .foregroundColor(.white.opacity(disabled ? 0.6 : 1))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(disabled ? 0.35 : 0.95))
        .cornerRadius(10)
    }

    private func buildExportData() -> Data? {
        var images: [String: String] = [:]
        for slot in CharacterSlot.allCases {
            if let img = store.image(for: slot) ?? loadDefaultImage(for: slot) {
                let data = img.pngData() ?? img.jpegData(compressionQuality: 0.9)
                if let data {
                    images[slot.rawValue] = data.base64EncodedString()
                }
            }
        }
        let payload = FacesExportPayload(version: 1, images: images)
        return try? JSONEncoder().encode(payload)
    }

    private func importFromData(_ data: Data) {
        guard let payload = try? JSONDecoder().decode(FacesExportPayload.self, from: data) else { return }
        for slot in CharacterSlot.allCases {
            guard let encoded = payload.images[slot.rawValue],
                  let imgData = Data(base64Encoded: encoded),
                  let image = UIImage(data: imgData) else { continue }
            store.save(image: image, for: slot)
        }
    }

    private func editablePreview(image: UIImage) -> some View {
        let drag = DragGesture()
            .onChanged { value in
                cropOffset = CGSize(width: cropBaseOffset.width + value.translation.width,
                                    height: cropBaseOffset.height + value.translation.height)
                clampCropOffset()
            }
            .onEnded { _ in
                cropBaseOffset = cropOffset
            }
        let zoom = MagnificationGesture()
            .onChanged { value in
                cropScale = max(1.0, min(6.0, cropBaseScale * value))
                clampCropOffset()
            }
            .onEnded { _ in
                cropBaseScale = cropScale
            }

        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 240)
            .scaleEffect(cropScale)
            .offset(cropOffset)
            .gesture(drag.simultaneously(with: zoom))
            .onAppear {
                if cropScale < 2.0 {
                    cropScale = 2.0
                    cropBaseScale = 2.0
                    clampCropOffset()
                }
            }
    }

    private func facePlaceholder() -> some View {
        ZStack {
            Ellipse()
                .stroke(Color.black.opacity(0.25), lineWidth: 4)
                .frame(width: 180, height: 210)
                .offset(y: -5)
            HStack(spacing: 28) {
                Circle().fill(Color.black.opacity(0.25)).frame(width: 10, height: 10)
                Circle().fill(Color.black.opacity(0.25)).frame(width: 10, height: 10)
            }
            .offset(y: -20)
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.25), lineWidth: 4)
                .frame(width: 70, height: 20)
                .offset(y: 40)
        }
    }

    private func clampCropOffset() {
        let frameSize = CGSize(width: 200, height: 240)
        let maxX = frameSize.width * (cropScale - 1) / 2
        let maxY = frameSize.height * (cropScale - 1) / 2
        let clampedX = min(max(cropOffset.width, -maxX), maxX)
        let clampedY = min(max(cropOffset.height, -maxY), maxY)
        cropOffset = CGSize(width: clampedX, height: clampedY)
    }
    private func cropImage(image: UIImage) -> UIImage? {
        let frameSize = CGSize(width: 200, height: 240)
        let boxSize = CGSize(width: 200, height: 240)
        let imgSize = image.size
        let baseScale = min(frameSize.width / imgSize.width, frameSize.height / imgSize.height)
        let actualScale = baseScale * cropScale
        let displaySize = CGSize(width: imgSize.width * actualScale, height: imgSize.height * actualScale)
        let imageOrigin = CGPoint(x: (frameSize.width - displaySize.width) / 2 + cropOffset.width,
                                  y: (frameSize.height - displaySize.height) / 2 + cropOffset.height)
        let cropOrigin = CGPoint(x: (frameSize.width - boxSize.width) / 2,
                                 y: (frameSize.height - boxSize.height) / 2)
        let originInImage = CGPoint(x: (cropOrigin.x - imageOrigin.x) / actualScale,
                                    y: (cropOrigin.y - imageOrigin.y) / actualScale)
        let cropRect = CGRect(x: originInImage.x, y: originInImage.y,
                              width: boxSize.width / actualScale,
                              height: boxSize.height / actualScale).integral
        guard let cg = image.cgImage else { return nil }
        let safeRect = cropRect.intersection(CGRect(origin: .zero, size: imgSize))
        guard let croppedCg = cg.cropping(to: safeRect) else { return nil }
        return UIImage(cgImage: croppedCg)
    }

    private func requestPhotoAccess() {
        // PHPicker does not require photo library permission.
        showingPicker = true
    }
}
