import Foundation
import SWCompression

@Observable
class WineDownloader: NSObject {
    @ObservationIgnored
    private lazy var session = URLSession(
        configuration: .default, delegate: self, delegateQueue: nil)

    @ObservationIgnored
    private let tempWineDir = try? FileManager.default.url(
        for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

    @ObservationIgnored
    private lazy var runnersDir: URL? = {
        guard
            let appSupport = try? FileManager.default.url(
                for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
                create: true
            )
        else { return nil }
        let dir = appSupport.appending(path: "Flasks/Runners")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    var downloadTask: URLSessionDownloadTask?

    var progress: Float = 0.0

    func startDownload(_ url: URL) {
        let task = self.session.downloadTask(with: url)
        task.resume()
        self.downloadTask = task
    }
    func untarAndInstall(_ path: URL) {
        guard let runnersDir else {
            // FIX: Silent failures
            return
        }
        do {
            let untarProcess = Process()
            untarProcess.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
            untarProcess.arguments = [
                "-xf", path.path, "-C", path.deletingLastPathComponent().path,
            ]
            print("Extracting........")
            try untarProcess.run()
            untarProcess.waitUntilExit()
            // FIX: Check for decompression failure
            print("Moving.........")
            let dst = runnersDir.appending(
                path: path.deletingPathExtension().deletingPathExtension().lastPathComponent
            )
            if FileManager.default.fileExists(
                atPath: dst.path)
            {
                try FileManager.default.removeItem(at: dst)
            }
            try FileManager.default.moveItem(
                at: path.deletingLastPathComponent().appending(
                    path: "Wine Devel.app/Contents/Resources/wine"),
                to: dst)
            // TODO: Cleanup
        } catch let error {
            // FIX: Error Handling for XZArchive.unarchive
            print("ERR: XZ DECOMP: ", error)
        }
    }
}

extension WineDownloader: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        do {
            guard let downloadDir = tempWineDir else { return }
            guard let filename = downloadTask.response?.suggestedFilename else {
                return
            }
            let downloadURL = downloadDir.appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: downloadURL.path) {
                try FileManager.default.removeItem(at: downloadURL)
            }
            try FileManager.default.moveItem(at: location, to: downloadURL)
            untarAndInstall(downloadURL)
        } catch let error {
            // FIX: Error Handling for Wine download
            print("ERR: WINE INSTL: ", error)
        }
    }
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        if downloadTask == self.downloadTask {
            let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                print(calculatedProgress)
                self.progress = calculatedProgress
            }
        }
    }
}
