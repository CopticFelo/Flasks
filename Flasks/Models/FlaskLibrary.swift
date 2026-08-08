import Foundation
import Subprocess
import System

@Observable
class FlaskLibrary {
    @ObservationIgnored
    let flasksDir = try? FileManager.default.url(
        for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
        create: true
    ).appending(path: "Flasks/Flasks")

    var flaskList: [Flask] = []

    // FIX: Error handling
    func scan() {
        flaskList.removeAll()
        guard let flasksDir else { return }
        guard FileManager.default.fileExists(atPath: flasksDir.path) else { return }
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: flasksDir.path)
            for directory in contents {
                let flask = createFlaskEntry(directory)
                guard let flask else { continue }
                flaskList.append(flask)
            }
        } catch let error {
            print(error)
        }
    }

    // FIX: Error handling
    /// Creates a Flask entry from the JSON File included in each flask
    func createFlaskEntry(_ path: String) -> Flask? {
        let jsonFile = URL(string: path)?.appending(path: "/flask.json")
        guard let jsonFile else { return nil }
        let jsonData = try? Data(contentsOf: jsonFile)
        guard let jsonData else { return nil }
        let flask = try? JSONDecoder().decode(Flask.self, from: jsonData)
        return flask
    }

    // FIX: Error handling
    /// This assumes that no Flask of the same name exists
    func createFlask(_ runner: Runner, name: String, windowsString: String) async -> Flask? {
        /// FIX: Windows Version ignored (requires winecfg)
        let appSupport = try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
            create: true
        )
        guard let appSupport else { return nil }
        let prefixDir = appSupport.appending(path: "Flasks/Flasks/\(name)")
        do {
            try FileManager.default.createDirectory(
                at: prefixDir, withIntermediateDirectories: true)
            let env = Environment.custom([
                "WINEPREFIX": prefixDir.path
            ])
            try await run(
                .path(FilePath(runner.binPath.appending(path: "/wineboot").path)),
                environment: env,
                output: .discarded
            )
            let flask = Flask(registeredApps: [], runner: runner, path: prefixDir, name: name)
            let jsonData = try JSONEncoder().encode(flask)
            // TODO: Maybe add a warning to the top to not delete this file
            try jsonData.write(to: prefixDir.appending(path: "/flask.json"), options: .atomic)
            return flask
        } catch let error {
            print(error)
            return nil
        }
    }
}
