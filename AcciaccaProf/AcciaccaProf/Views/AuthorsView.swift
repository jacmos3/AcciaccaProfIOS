import SwiftUI

struct AuthorsView: View {
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 16)
    ]

    private var authorImages: [URL] {
        Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "images/VA")?
            .filter { url in
                let ext = url.pathExtension.lowercased()
                return ["png", "jpg", "jpeg"].contains(ext)
            }
            .sorted { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() }
            ?? []
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(authorImages, id: \.self) { url in
                    VStack(spacing: 8) {
                        if let image = UIImage(contentsOfFile: url.path) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 120)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                        }
                        Text(url.lastPathComponent)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
            .padding(16)
        }
        .background(Color(white: 0.95))
        .navigationTitle("Special Thanks to:")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
        }
    }
}

#Preview {
    AuthorsView()
}
