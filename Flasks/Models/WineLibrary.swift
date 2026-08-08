import Foundation
import Subprocess
import System

@Observable
class WineLibrary {
    var runners: [Runner] = []

    func scan() async throws {
        do {
            let runnersDir = try FileManager.default.url(
                for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
                create: true
            ).appending(path: "Flasks/Runners")
            guard FileManager.default.fileExists(atPath: runnersDir.path) else { return }
            let contents = try FileManager.default.contentsOfDirectory(atPath: runnersDir.path)
            runners.removeAll()
            for directory in contents {
                let runnerEntry = await createRunnerEntry(directory, runnersDir: runnersDir)
                guard let runnerEntry else { continue }
                runners.append(runnerEntry)
            }
        } catch let error as CocoaError {
            throw FlaskError.fileError(detail: error)
        }
    }

    func createRunnerEntry(_ dir: String, runnersDir: URL) async -> Runner? {
        let binPath = runnersDir.appending(path: dir + "/bin")
        guard FileManager.default.fileExists(atPath: binPath.path) else { return nil }
        let wineVersion = await getWineVersion(binPath.appending(path: "/wine"))
        guard let wineVersion else { return nil }
        let runner = Runner(
            name: dir, binPath: binPath,
            wineVersion: wineVersion, isExternal: false)
        return runner
    }

    func getWineVersion(_ winePath: URL) async -> String? {
        do {
            let result = try await run(
                .path(FilePath(winePath.path)),
                arguments: ["--version"],
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
            return result.standardOutput
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch let error {
            print("WARN: Invalid Wine install at \(winePath.path) \n", error)
            return nil
        }
    }
}
