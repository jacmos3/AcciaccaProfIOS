import Foundation
import CoreGraphics

struct LayoutItem: Decodable {
    let `class`: String?
    let Left: CGFloat?
    let Top: CGFloat?
    let Width: CGFloat?
    let Height: CGFloat?
    let Caption: String?
}

final class LayoutStore {
    private var items: [String: LayoutItem] = [:]

    init(jsonName: String) {
        guard let url = Bundle.main.url(forResource: jsonName, withExtension: "json", subdirectory: "layout")
            ?? Bundle.main.url(forResource: jsonName, withExtension: "json") else {
            return
        }
        do {
            let data = try Data(contentsOf: url)
            items = try JSONDecoder().decode([String: LayoutItem].self, from: data)
        } catch {
            items = [:]
        }
    }

    func frame(for name: String) -> CGRect? {
        guard let item = items[name],
              let left = item.Left,
              let top = item.Top,
              let width = item.Width,
              let height = item.Height else {
            return nil
        }
        return CGRect(x: left, y: top, width: width, height: height)
    }

    func caption(for name: String) -> String? {
        guard let raw = items[name]?.Caption else { return nil }
        return decodeCaption(raw)
    }

    private func decodeCaption(_ raw: String) -> String {
        var out = ""
        var i = raw.startIndex
        while i < raw.endIndex {
            let c = raw[i]
            if c == "'" {
                i = raw.index(after: i)
                while i < raw.endIndex && raw[i] != "'" {
                    out.append(raw[i])
                    i = raw.index(after: i)
                }
                if i < raw.endIndex { i = raw.index(after: i) }
            } else if c == "#" {
                i = raw.index(after: i)
                var num = ""
                while i < raw.endIndex, raw[i].isNumber {
                    num.append(raw[i])
                    i = raw.index(after: i)
                }
                if let v = Int(num), let scalar = UnicodeScalar(v) {
                    out.append(Character(scalar))
                }
            } else {
                i = raw.index(after: i)
            }
        }
        return out
    }
}
