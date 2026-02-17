import Foundation

final class ZOrderStore {
    private var order: [String] = []

    init(jsonName: String) {
        if let url = Bundle.main.url(forResource: jsonName, withExtension: "json", subdirectory: "layout")
            ?? Bundle.main.url(forResource: jsonName, withExtension: "json") {
            if let data = try? Data(contentsOf: url),
               let list = try? JSONDecoder().decode([String].self, from: data) {
                order = list
            }
        }
    }

    func zIndex(for name: String) -> CGFloat {
        if let idx = order.firstIndex(of: name) {
            return CGFloat(idx)
        }
        return 0
    }
}
