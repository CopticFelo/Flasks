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

    func runApp(_ exePath: URL) async throws {
        let env = Environment.custom([
            "WINEPREFIX": path.path
        ])
        do {
            let result = try await run(
                .path(FilePath(runner.binPath.appending(path: "/wine").path)),
                arguments: [exePath.path],
                environment: env,
                output: .discarded
            )
            switch result.terminationStatus {
            case .exited(let code):
                if code != 0 {
                    throw FlaskError.wineError(detail: "Process exited with code \(code)")
                }
            case .signaled(let code):
                throw FlaskError.wineError(detail: "Process terminated with signal \(code)")
            }
        } catch let error as SubprocessError {
            throw FlaskError.processError(detail: error)
        }
    }
}
