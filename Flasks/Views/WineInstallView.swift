import SwiftUI

let runnerList: [String: String] = [
    "wine-devel-11.13":
        "https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.13/wine-devel-11.13-osx64.tar.xz",
    "wine-devel-11.12":
        "https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.12/wine-devel-11.12-osx64.tar.xz",
]

struct WineInstallView: View {
    @Binding var isPresented: Bool
    @State var selectedRunner = "wine-devel-11.13"
    var downloader = WineDownloader()
    var body: some View {
        VStack {
            Text("Choose Wine Runner to download")
            Picker("Runner: ", selection: $selectedRunner) {
                ForEach(runnerList.keys.sorted(), id: \.self) { key in
                    Text(key).tag(key)
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
                        isPresented = false
                    },
                    label: {
                        Text("Cancel")
                    })
                Spacer()
                Button(
                    action: {
                        guard
                            let downloadUrl = URL(
                                string: runnerList[selectedRunner] ?? "wine-devel-11.13"
                            )
                        else { return }
                        print("Started download")
                        downloader.startDownload(downloadUrl)
                    },
                    label: {
                        Text("Download Runner")
                    }
                ).disabled(downloader.state == .downloading || downloader.state == .extracting)
            }
        }.padding()
    }
}
