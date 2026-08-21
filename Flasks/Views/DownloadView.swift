import SwiftUI

struct DownloadView: View {
    struct Downloadable: Identifiable {
        let id = UUID()
        let name: String
        let url: String
    }

    // TODO: Find a better way instead of hardcoding ts
    let runnerList: [Downloadable] = [
        Downloadable(
            name: "wine-devel-11.13",
            url:
                "https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.13/wine-devel-11.13-osx64.tar.xz"
        ),
        Downloadable(
            name: "wine-devel-11.12",
            url:
                "https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.12/wine-devel-11.12-osx64.tar.xz"
        ),
    ]
    @Environment(\.dismissWindow) private var dismissWindow

    @State var selectedRunner = "wine-devel-11.13"
    var downloader = WineDownloader()
    var body: some View {
        VStack {
            Text("Choose Wine Runner to download")
            Table(runnerList) {
                TableColumn("name", value: \.name)
                TableColumn("Download") { downloadable in
                    TableDownloadView(downloadURL: downloadable.url)
                }
            }
            Spacer()
            if downloader.state == .downloading || downloader.state == .extracting {
                VStack {
                    ProgressView(value: downloader.progress)
                    if downloader.state == .downloading {
                        Text(downloader.progress, format: .percent.precision(.fractionLength(1)))
                    } else {
                        Text("Extracting...")
                    }
                }
            }
            Divider()
            HStack {
                Button(
                    action: {
                        dismissWindow(id: "downloader")
                    },
                    label: {
                        Text("Cancel")
                    })
                Spacer()
                // Button(
                //     action: {
                //         guard
                //             let downloadUrl = URL(
                //                 string: runnerList[selectedRunner].url
                //             )
                //         else { return }
                //         print("Started download")
                //         downloader.startDownload(downloadUrl)
                //     },
                //     label: {
                //         Text("Download Runner")
                //     }
                // ).disabled(downloader.state == .downloading || downloader.state == .extracting)
            }
        }.padding()
    }
}
