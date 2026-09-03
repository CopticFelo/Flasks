import AppKit
import Foundation
import Subprocess
import System

struct WineApp: Identifiable, Hashable, Codable {
    var id = UUID()
    var appPath: URL

    func getIcon() async throws(FlaskError) -> NSImage? {
        let wrestoolPath = Bundle.main.sharedSupportURL?.appending(path: "bin/wrestool")
        guard let wrestoolPath else { throw FlaskError.unknownError }
        do {
            let result = try await run(
                .path(FilePath(wrestoolPath.path)),
                arguments: ["-x", "-t", "14", appPath.path],
                input: .none,
                output: .bytes(limit: Int.max),
                error: .combinedWithOutput
            )
            switch result.terminationStatus {
            case .exited(let code):
                if code != 0 {
                    throw FlaskError.wineError(detail: "Process exited with code \(code)")
                }
            case .signaled(let code):
                throw FlaskError.wineError(detail: "Process terminated with signal \(code)")
            }
            let raw = Data(result.standardOutput)
            return NSImage(data: raw)
        } catch let error as SubprocessError {
            throw FlaskError.processError(detail: error)
        } catch let error as FlaskError {
            throw error
        } catch {
            throw FlaskError.unknownError
        }
    }
}
