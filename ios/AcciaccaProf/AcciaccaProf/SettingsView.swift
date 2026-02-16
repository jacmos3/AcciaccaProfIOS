import SwiftUI
import Photos

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ImageStore.shared

    @State private var showingPicker = false
    @State private var showPhotoPermissionAlert = false
    @State private var selectedSlot: CharacterSlot?
    @State private var selectedImage: CroppableImage?

    private struct CroppableImage: Identifiable {
        let id = UUID()
        let image: UIImage
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(CharacterSlot.allCases) { slot in
                    HStack(spacing: 12) {
                        preview(for: slot)
                            .frame(width: 50, height: 50)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))

                        Text(slot.displayName)
                        Spacer()
                        Button("Scegli") {
                            selectedSlot = slot
                            requestPhotoAccess()
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    selectedImage = CroppableImage(image: image)
                }
            }, onCancel: {
                showingPicker = false
            })
        }
        .sheet(item: $selectedImage) { item in
            if let slot = selectedSlot {
                ImageCropperView(image: item.image) {
                    store.save(image: $0, for: slot)
                    selectedImage = nil
                } onCancel: {
                    selectedImage = nil
                }
            }
        }
        .alert("Accesso alle foto", isPresented: $showPhotoPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Consenti l'accesso alle foto per scegliere un'immagine. Puoi abilitarlo in Impostazioni > Privacy > Foto.")
        }
    }

    private func preview(for slot: CharacterSlot) -> Image {
        _ = store.version
        if let img = store.image(for: slot) {
            return Image(uiImage: img)
        }
        if let url = Bundle.main.url(forResource: slot.fileName.replacingOccurrences(of: ".jpg", with: ""), withExtension: "jpg", subdirectory: "images"),
           let img = UIImage(contentsOfFile: url.path) {
            return Image(uiImage: img)
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
