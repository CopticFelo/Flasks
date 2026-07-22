import Foundation

struct WineLibrary {
    static var runners: [Runner] = []

    static let runnersDir = try? FileManager.default.url(
        for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
        create: true
    ).appending(path: "Flasks/Runners")

    static func scan() {
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

    static func createRunnerEntry(_ dir: String) -> Runner? {
        guard let runnersDir else { return nil }
        let winePath = runnersDir.appending(path: dir + "/bin/wine")
        guard FileManager.default.fileExists(atPath: winePath.path) else { return nil }
        let wineserverPath = runnersDir.appending(path: dir + "/bin/wineserver")
        guard FileManager.default.fileExists(atPath: wineserverPath.path) else { return nil }
        let wineVersion = getWineVersion(winePath)
        guard let wineVersion else { return nil }
        let runner = Runner(
            name: dir, winePath: winePath, wineserverPath: wineserverPath,
            wineVersion: wineVersion, isExternal: false)
        return runner
    }

    static func getWineVersion(_ winePath: URL) -> String? {
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
