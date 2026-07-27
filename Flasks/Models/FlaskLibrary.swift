import Foundation

@Observable
class FlaskLibrary {
    static let shared = FlaskLibrary()

    @ObservationIgnored
    let flasksDir = try? FileManager.default.url(
        for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
        create: true
    ).appending(path: "Flasks/Flasks")

    var flaskList: [Flask] = []

    // FIX: Error handling
    /// This assumes that no Flask of the same name exists
    func createFlask(_ runner: Runner, name: String, windowsString: String) -> Flask? {
        /// FIX: Windows Version ignored (requires winecfg)
        let process = Process()
        process.executableURL = runner.binPath.appending(path: "/wineboot")
        let appSupport = try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
            create: true
        )
        guard let appSupport else { return nil }
        let dir = appSupport.appending(path: "Flasks/Flasks/\(name)")
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let env = [
                "WINEPREFIX": dir.path
            ]
            process.environment = env
            try process.run()
            process.waitUntilExit()
            let flask = Flask(registeredApps: [], runner: runner, path: dir, name: name)
            return flask
        } catch let error {
            print(error)
            return nil
        }
    }
}
