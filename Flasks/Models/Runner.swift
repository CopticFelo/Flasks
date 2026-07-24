import Foundation

struct Runner: Identifiable, Hashable {
    let id = UUID()
    let name: String?
    let binPath: URL
    let wineVersion: String
    let isExternal: Bool
}
