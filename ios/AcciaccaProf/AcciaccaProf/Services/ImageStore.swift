import Foundation
import UIKit

enum CharacterSlot: String, CaseIterable, Identifiable {
    case cattivo1, cattivo2, cattivo3
    case buono1, buono2, buono3
    case bidella

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cattivo1: return "Prof cattivo 1"
        case .cattivo2: return "Prof cattivo 2"
        case .cattivo3: return "Prof cattivo 3"
        case .buono1: return "Prof buono 1"
        case .buono2: return "Prof buono 2"
        case .buono3: return "Prof buono 3"
        case .bidella: return "Bidella"
        }
    }

    var fileName: String {
        switch self {
        case .cattivo1: return "cattivi_1.jpg"
        case .cattivo2: return "cattivi_2.jpg"
        case .cattivo3: return "cattivi_3.jpg"
        case .buono1: return "buoni_1.jpg"
        case .buono2: return "buoni_2.jpg"
        case .buono3: return "buoni_3.jpg"
        case .bidella: return "bidella_1.jpg"
        }
    }
}

final class ImageStore: ObservableObject {
    static let shared = ImageStore()

    private let fm = FileManager.default
    @Published private(set) var version = UUID()

    private var docsURL: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func image(for slot: CharacterSlot) -> UIImage? {
        let url = docsURL.appendingPathComponent(slot.fileName)
        return UIImage(contentsOfFile: url.path)
    }

    func save(image: UIImage, for slot: CharacterSlot) {
        let url = docsURL.appendingPathComponent(slot.fileName)
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: url, options: .atomic)
        }
        version = UUID()
    }

    func remove(for slot: CharacterSlot) {
        let url = docsURL.appendingPathComponent(slot.fileName)
        try? fm.removeItem(at: url)
        version = UUID()
    }

    func resetAll() {
        for slot in CharacterSlot.allCases {
            let url = docsURL.appendingPathComponent(slot.fileName)
            try? fm.removeItem(at: url)
        }
        version = UUID()
    }
}
