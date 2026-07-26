import Foundation

struct Runner: Identifiable, Hashable, Codable {
    var id = UUID()
    let name: String?
    let binPath: URL
    let wineVersion: String
    let isExternal: Bool
}
