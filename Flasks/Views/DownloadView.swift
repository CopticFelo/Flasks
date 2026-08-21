import SwiftUI

struct DownloadView: View {
    @Environment(\.dismissWindow) private var dismissWindow
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

    @State var alertError: FlaskError?
    var body: some View {
        VStack {
            Text("Choose Wine Runner to download")
            Table(runnerList) {
                TableColumn("Name", value: \.name)
                TableColumn("Download") { downloadable in
                    TableDownloadView(
                        name: downloadable.name, downloadURL: downloadable.url,
                        alertError: $alertError)
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
            }
        }.padding().alert(item: $alertError) { err in
            Alert(
                title: Text(err.localizedDescription), message: Text(err.recoverySuggestion ?? ""))
        }
    }
}
