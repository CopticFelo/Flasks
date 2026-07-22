import Foundation

struct Runner: Identifiable, Hashable {
    let id = UUID()
    let name: String?
    let winePath: URL
    let wineserverPath: URL
    let wineVersion: String
    let isExternal: Bool
}
