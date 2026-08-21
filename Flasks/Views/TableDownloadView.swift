import SwiftUI

struct TableDownloadView: View {
    let name: String
    let downloadURL: String

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
                let url = URL(string: downloadURL)
                guard let url else {
                    errorString = "Bad URL"
                    return
                }
                downloader = Downloader()
                downloader?.startDownload(url)
            } label: {
                switch downloader?.state {
                case .downloading: Image(systemName: "x.circle")
                case .complete:
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                default: Image(systemName: "square.and.arrow.down")
                }
            }.disabled(
                downloader?.state != .idle && downloader != nil)
        }
    }
}
