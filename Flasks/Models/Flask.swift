import Foundation
import Subprocess
import System

struct Flask: Codable, Identifiable {
    var id = UUID()
    var registeredApps: [WineApp]
    let runner: Runner
    let path: URL
    let name: String

    func saveJson() throws {
        let jsonData = try JSONEncoder().encode(self)
        // TODO: Maybe add a warning to the top to not delete this file
        let jsonPath = self.path.appending(path: "/flask.json")
        try jsonData.write(to: jsonPath, options: .atomic)
    }

    mutating func registerApp(_ path: URL) throws {
        let app = WineApp(appPath: path)
        registeredApps.append(app)
        try saveJson()
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
