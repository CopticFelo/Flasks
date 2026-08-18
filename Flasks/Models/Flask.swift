import Foundation
import Subprocess
import System

struct ConsoleLog: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date = Date()
    let appName: String
    let runnerName: String?
    let message: String

    func fullMessage() -> String {
        return
            "[\(appName.prefix(20))@\(timestamp.formatted(date: .omitted, time: .shortened))]: \(message)"
    }
}

@Observable
class Flask: Codable, Identifiable {
    let id = UUID()
    var registeredApps: [WineApp]
    let runner: Runner
    let path: URL
    let name: String

    var consoleOutput: [ConsoleLog] = []

    init(registeredApps: [WineApp], runner: Runner, path: URL, name: String) {
        self.registeredApps = registeredApps
        self.runner = runner
        self.path = path
        self.name = name
    }

    // Json coding boilerplate
    enum CodingKeys: String, CodingKey {
        case registeredApps = "registered_apps"
        case runner = "runner"
        case path = "path"
        case name = "name"
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        registeredApps = try container.decode([WineApp].self, forKey: .registeredApps)
        runner = try container.decode(Runner.self, forKey: .runner)
        path = try container.decode(URL.self, forKey: .path)
        name = try container.decode(String.self, forKey: .name)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(registeredApps, forKey: .registeredApps)
        try container.encode(runner, forKey: .runner)
        try container.encode(path, forKey: .path)
        try container.encode(name, forKey: .name)
    }
    // end of boilerplate section

    func saveJson() throws {
        let jsonData = try JSONEncoder().encode(self)
        // TODO: Maybe add a warning to the top to not delete this file
        let jsonPath = self.path.appending(path: "/flask.json")
        try jsonData.write(to: jsonPath, options: .atomic)
    }

    /// Path validation must be done by the caller
    /// this only throws Json saving errors
    func registerApp(_ path: URL) throws {
        let app = WineApp(appPath: path)
        registeredApps.append(app)
        try saveJson()
    }

    func removeApp(_ id: WineApp.ID) throws {
        registeredApps.removeAll { $0.id == id }
        try saveJson()
    }

    func runApp(_ exePath: URL) async throws {
        let env = Environment.custom([
            "WINEPREFIX": path.path
        ])
        do {
            let appName = exePath.lastPathComponent
            let result = try await run(
                .path(FilePath(runner.binPath.appending(path: "/wine").path)),
                arguments: [exePath.path],
                environment: env,
                input: .none,
                output: .sequence,
                error: .combinedWithOutput
            ) { exec in
                for try await line in exec.standardOutput.strings() {
                    DispatchQueue.main.async {
                        self.consoleOutput.append(
                            ConsoleLog(
                                appName: appName, runnerName: self.runner.name, message: line))
                    }
                }
            }
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
