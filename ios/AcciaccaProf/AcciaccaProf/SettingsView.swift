import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ImageStore.shared

    @State private var showingPicker = false
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
                            showingPicker = true
                        }
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
            PhotoPicker { image in
                selectedImage = CroppableImage(image: image)
                showingPicker = false
            }
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
}
