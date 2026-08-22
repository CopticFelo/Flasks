import SwiftUI

struct TableDownloadView: View {
    let downloadable: Downloadable
    let isDownloaded: Bool

    private var isButtonDisabled: Bool {
        guard let state = downloader?.state else { return isDownloaded }
        return (state != .idle && state != .downloading) || isDownloaded
    }

    @Binding var alertError: FlaskError?

    @State private var downloader: Downloader?
    @State private var errorString = ""
    var body: some View {
        HStack {
            Spacer()
            switch downloader?.state {
            case .downloading: ProgressView(value: downloader?.progress)
            case .extracting: Text("Extracting...")
            default:
                if !errorString.isEmpty {
                    Text(errorString)
                }
            }
            Button {
                switch downloader?.state ?? DownloadState.idle {
                case .idle:
                    if downloadable.url == nil {
                        errorString = "Bad URL"
                        return
                    }
                    downloader = Downloader(downloadable)
                    downloader?.startDownload()
                case .downloading:
                    downloader?.cancelDownload()
                default: return
                }
            } label: {
                if isDownloaded {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                } else {
                    switch downloader?.state {
                    case .downloading: Image(systemName: "x.circle")
                    case .complete:
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    default: Image(systemName: "square.and.arrow.down")
                    }
                }
            }.disabled(isButtonDisabled)
        }
    }
}
