import Foundation

struct WineApp: Identifiable, Hashable, Codable {
    var id = UUID()
    var appPath: URL
}
