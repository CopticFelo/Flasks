import Foundation
import os

enum DownloadState {
    case extracting
    case downloading
    case idle
    case complete
}

@Observable
class WineDownloader: NSObject {
    @ObservationIgnored
    private lazy var session = URLSession(
        configuration: .default, delegate: self, delegateQueue: nil)

    @ObservationIgnored
    var downloadTask: URLSessionDownloadTask?

    var state: DownloadState = .idle
    var error: FlaskError?
    var progress: Float = 0.0

    private func getRunnersDir() throws -> URL {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
            create: true
        )
        let dir = appSupport.appending(path: "Flasks/Runners")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func startDownload(_ url: URL) {
        let task = self.session.downloadTask(with: url)
        task.resume()
        self.downloadTask = task
        state = .downloading
    }
    func untarAndInstall(_ path: URL) {
        do {
            let untarProcess = Process()
            untarProcess.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
            untarProcess.arguments = [
                "-xf", path.path, "-C", path.deletingLastPathComponent().path,
            ]

            print("Extracting........")
            try untarProcess.run()  // throws CocoaError
            untarProcess.waitUntilExit()

            print("Moving.........")
            let dst = try getRunnersDir().appending(
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
            state = .complete
            // TODO: Cleanup
        } catch let error as CocoaError {
            DispatchQueue.main.async {
                self.state = .idle
                self.error = .fileError(detail: error)
            }
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.state = .idle
                self.error = .processError(detail: error)
            }
        }
    }
}

extension WineDownloader: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?
    ) {
        guard let networkError = error as? URLError else { return }
        if networkError.code == .cancelled {
            return
        }
        DispatchQueue.main.async {
            self.state = .idle
            self.error = FlaskError.networkError(detail: networkError)
        }
    }
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        do {
            // gaurding against stupid http errors :<
            guard let response = downloadTask.response as? HTTPURLResponse else {
                self.state = .idle
                self.error = FlaskError.invalidResponseError
                return
            }
            guard (200...299).contains(response.statusCode) else {
                self.state = .idle
                self.error = FlaskError.serverError(code: response.statusCode)
                return
            }

            let filename =
                response.suggestedFilename ?? "unknown-wine-\(UUID().uuidString.prefix(4)).tar.xz"
            let downloadURL = try FileManager.default.url(
                for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true
            )
            .appendingPathComponent(filename)

            if FileManager.default.fileExists(atPath: downloadURL.path) {
                try FileManager.default.removeItem(at: downloadURL)
            }
            try FileManager.default.moveItem(at: location, to: downloadURL)

            DispatchQueue.main.async {
                self.state = .extracting
            }

            untarAndInstall(downloadURL)
        } catch let error as FlaskError {
            DispatchQueue.main.async {
                self.state = .idle
                self.error = error
            }
        } catch {
            let cocoaError = error as? CocoaError ?? CocoaError(.fileWriteUnknown)
            DispatchQueue.main.async {
                self.state = .idle
                self.error = FlaskError.fileError(detail: cocoaError)
            }
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
