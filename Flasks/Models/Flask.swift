import Foundation

struct Flask: Codable {
    var registeredApps: [URL]
    let runner: Runner
    let path: URL
    let name: String

    mutating func registerApp(_ path: URL) {
        registeredApps.append(path)
    }

    func runApp(_ exePath: URL) {
        let process = Process()
        process.executableURL = runner.binPath.appending(path: "/wine")
        let env = [
            "WINEPREFIX": path.path
        ]
        process.environment = env
        process.arguments = [exePath.path]
        process.qualityOfService = .userInteractive
        do {
            try process.run()
            Task.detached {
                process.waitUntilExit()
            }
        } catch let error {
            // FIX: Error handling
            print(error)
        }
    }
}
