import Foundation
import Subprocess
import System

struct Flask: Codable {
    var registeredApps: [URL]
    let runner: Runner
    let path: URL
    let name: String

    mutating func registerApp(_ path: URL) {
        registeredApps.append(path)
    }

    func runApp(_ exePath: URL) async {
        let env = Environment.custom([
            "WINEPREFIX": path.path
        ])
        do {
            try await run(
                .path(FilePath(runner.binPath.appending(path: "/wine").path)),
                arguments: [exePath.path],
                environment: env,
                output: .discarded
            )
        } catch let error {
            // FIX: Error handling
            print(error)
        }
    }
}
