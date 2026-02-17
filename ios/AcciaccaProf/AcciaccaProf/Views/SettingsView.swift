import SwiftUI
import Photos

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ImageStore.shared
    @StateObject private var purchase = PurchaseManager.shared

    @State private var showingPicker = false
    @State private var showPhotoPermissionAlert = false
    @State private var selectedSlot: CharacterSlot?
    @State private var showPurchaseError = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sblocca le personalizzazioni")
                            .font(.headline)
                        Text("Sblocchi: prof buoni, prof cattivi, bidella e Perla.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if purchase.unlocked {
                            Text("Sblocco attivo")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        } else {
                            HStack {
                                if purchase.isLoading {
                                    ProgressView()
                                }
                                Button("Sblocca") {
                                    Task { await purchase.purchase() }
                                }
                                .disabled(purchase.isLoading)
                                Button("Ripristina acquisti") {
                                    Task { await purchase.restore() }
                                }
                                .disabled(purchase.isLoading)
                                Button("Ricarica") {
                                    Task {
                                        await purchase.refreshProducts()
                                        await purchase.refreshEntitlements()
                                    }
                                }
                                .disabled(purchase.isLoading)
                            }
                            if purchase.product == nil {
                                Text("Prodotto non disponibile. Controlla StoreKit Configuration.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                ForEach(CharacterSlot.allCases) { slot in
                    HStack(spacing: 12) {
                        preview(for: slot)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipped()
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))

                        Text(slot.displayName)
                        Spacer()
                        Button("Scegli") {
                            selectedSlot = slot
                            requestPhotoAccess()
                        }
                        .disabled(!purchase.unlocked)
                        .opacity(purchase.unlocked ? 1 : 0.5)
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
                selectedSlot = nil
            }, onCancel: {
                showingPicker = false
                selectedSlot = nil
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
    }

    private func preview(for slot: CharacterSlot) -> Image {
        _ = store.version
        if let img = store.image(for: slot) {
            return Image(uiImage: img)
        }
        let baseName = slot.baseName
        let exts = ["png","jpg","JPG","jpeg","JPEG"]
        for ext in exts {
            if let url = Bundle.main.url(forResource: baseName, withExtension: ext, subdirectory: "images"),
               let img = UIImage(contentsOfFile: url.path) {
                return Image(uiImage: img)
            }
        }
        return Image(systemName: "person.crop.square")
    }

    private func requestPhotoAccess() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            showingPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        showingPicker = true
                    } else {
                        showPhotoPermissionAlert = true
                    }
                }
            }
        default:
            showPhotoPermissionAlert = true
        }
    }
}
