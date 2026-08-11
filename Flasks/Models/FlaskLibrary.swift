import Foundation
import Subprocess
import System

@Observable
class FlaskLibrary {
    var flaskList: [Flask] = []

    init() {
        // FIX: Error handling (oh no not again)
        try? self.scan()
    }

    func scan() throws {
        let flasksDir = try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
            create: true
        ).appending(path: "Flasks/Flasks")
        guard let flasksDir else { return }
        guard FileManager.default.fileExists(atPath: flasksDir.path) else { return }
        flaskList.removeAll()
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: flasksDir.path)
            for directory in contents {
                let flask = createFlaskEntry(flasksDir.appending(path: directory))
                guard let flask else { continue }
                flaskList.append(flask)
            }
        } catch let error as CocoaError {
            print(error)
            throw FlaskError.fileError(detail: error)
        }
    }

    /// Creates a Flask entry from the JSON File included in each flask
    func createFlaskEntry(_ path: URL) -> Flask? {
        let jsonFile = path.appending(path: "/flask.json")
        let jsonData = try? Data(contentsOf: jsonFile)
        guard let jsonData else { return nil }
        let flask = try? JSONDecoder().decode(Flask.self, from: jsonData)
        return flask
    }

    /// This assumes that no Flask of the same name exists
    func createFlask(_ runner: Runner, name: String, windowsString: String) async throws -> Flask {
        /// FIX: Windows Version ignored (requires winecfg)
        do {
            let appSupport = try FileManager.default.url(
                for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
                create: true
            )
            let prefixDir = appSupport.appending(path: "Flasks/Flasks/\(name)")
            try FileManager.default.createDirectory(
                at: prefixDir, withIntermediateDirectories: true)
            let env = Environment.custom([
                "WINEPREFIX": prefixDir.path
            ])
            let result = try await run(
                .path(FilePath(runner.binPath.appending(path: "/wine").path)),
                arguments: ["wineboot", "-u"],
                environment: env,
                output: .string(limit: 4096)
            )
            switch result.terminationStatus {
            case .exited(let code):
                if code != 0 {
                    throw FlaskError.wineError(detail: "Process exited with code \(code)")
                }
            case .signaled(let code):
                throw FlaskError.wineError(detail: "Process terminated with signal \(code)")
            }
            let flask = Flask(registeredApps: [], runner: runner, path: prefixDir, name: name)
            try flask.saveJson()
            return flask
        } catch let error as CocoaError {
            throw FlaskError.fileError(detail: error)
        } catch let error as SubprocessError {
            throw FlaskError.processError(detail: error)
        }
    }
}
