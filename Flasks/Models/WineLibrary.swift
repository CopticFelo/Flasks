import Foundation

@Observable
class WineLibrary {
    var runners: [Runner] = []

    @ObservationIgnored
    let runnersDir = try? FileManager.default.url(
        for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
        create: true
    ).appending(path: "Flasks/Runners")

    func scan() {
        runners.removeAll()
        guard let runnersDir else { return }
        guard FileManager.default.fileExists(atPath: runnersDir.path) else { return }
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: runnersDir.path)
            for directory in contents {
                let runnerEntry = createRunnerEntry(directory)
                guard let runnerEntry else { continue }
                runners.append(runnerEntry)
            }
        } catch let error {
            // FIX: Error handling
            print("ERR: Cannot querry runners directory: ", error)
        }
    }

    func createRunnerEntry(_ dir: String) -> Runner? {
        guard let runnersDir else { return nil }
        let binPath = runnersDir.appending(path: dir + "/bin")
        guard FileManager.default.fileExists(atPath: binPath.path) else { return nil }
        let wineVersion = getWineVersion(binPath.appending(path: "/wine"))
        guard let wineVersion else { return nil }
        let runner = Runner(
            name: dir, binPath: binPath,
            wineVersion: wineVersion, isExternal: false)
        return runner
    }

    func getWineVersion(_ winePath: URL) -> String? {
        let process = Process()
        let pipe = Pipe()
        process.arguments = ["--version"]
        process.executableURL = winePath
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch let error {
            print("ERR: Wine version? \n", error)
            return nil
        }
    }
}
