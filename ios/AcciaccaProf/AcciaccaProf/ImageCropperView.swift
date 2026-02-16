import SwiftUI
import UIKit

struct ImageCropperView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    let onCancel: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0

    private let cropSize: CGFloat = 260

    var body: some View {
        VStack(spacing: 12) {
            Text("Ritaglia il viso")
                .font(.headline)

            ZStack {
                Color.black.opacity(0.9)
                cropContent
                cropOverlay
            }
            .frame(width: cropSize, height: cropSize)
            .clipped()
            .cornerRadius(8)

            HStack(spacing: 16) {
                Button("Annulla") { onCancel() }
                Spacer()
                Button("Salva") {
                    let cropped = cropImage()
                    onSave(cropped)
                }
            }
            .frame(width: cropSize)
        }
        .padding(16)
    }

    private var cropContent: some View {
        let img = Image(uiImage: image)
        return img
            .resizable()
            .scaledToFill()
            .scaleEffect(scale)
            .offset(offset)
            .gesture(dragGesture().simultaneously(with: magnificationGesture()))
            .frame(width: cropSize, height: cropSize)
    }

    private var cropOverlay: some View {
        Rectangle()
            .stroke(Color.white.opacity(0.8), lineWidth: 2)
            .frame(width: cropSize, height: cropSize)
    }

    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                let newOffset = CGSize(width: lastOffset.width + value.translation.width,
                                       height: lastOffset.height + value.translation.height)
                offset = clampedOffset(newOffset, scale: scale)
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = max(1.0, lastScale * value)
                scale = newScale
                offset = clampedOffset(offset, scale: scale)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }

    private func clampedOffset(_ offset: CGSize, scale: CGFloat) -> CGSize {
        let baseScale = max(cropSize / image.size.width, cropSize / image.size.height)
        let displayScale = baseScale * scale
        let imageSize = CGSize(width: image.size.width * displayScale, height: image.size.height * displayScale)
        let maxX = max(0, (imageSize.width - cropSize) / 2)
        let maxY = max(0, (imageSize.height - cropSize) / 2)
        let clampedX = min(max(offset.width, -maxX), maxX)
        let clampedY = min(max(offset.height, -maxY), maxY)
        return CGSize(width: clampedX, height: clampedY)
    }

    private func cropImage() -> UIImage {
        let baseScale = max(cropSize / image.size.width, cropSize / image.size.height)
        let displayScale = baseScale * scale
        let imageSize = CGSize(width: image.size.width * displayScale, height: image.size.height * displayScale)
        let origin = CGPoint(x: (cropSize - imageSize.width) / 2 + offset.width,
                             y: (cropSize - imageSize.height) / 2 + offset.height)

        var cropRect = CGRect(
            x: (0 - origin.x) / displayScale,
            y: (0 - origin.y) / displayScale,
            width: cropSize / displayScale,
            height: cropSize / displayScale
        )

        cropRect = cropRect.intersection(CGRect(origin: .zero, size: image.size))

        let source = image.normalizedImage()
        guard let cgImage = source.cgImage,
              let cropped = cgImage.cropping(to: cropRect) else {
            return image
        }
        return UIImage(cgImage: cropped)
    }
}
