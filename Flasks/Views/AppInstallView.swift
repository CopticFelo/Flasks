import SwiftUI
import UniformTypeIdentifiers

enum AppType {
    case install
    case standalone
}

struct AppInstallView: View {
    @State private var type: AppType = .standalone
    @State private var path = ""
    @State private var showFileDialog = false
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Spacer()
            Picker("App Type", selection: $type) {
                Text("Standalone (Portable)").tag(AppType.standalone)
                Text("Installer").tag(AppType.install)
            }
            HStack {
                Text("Path to .exe")
                TextField("Path", text: $path)
                Button("Browse") {
                    showFileDialog = true
                }
            }
            Spacer()
        }.padding().fileImporter(
            isPresented: $showFileDialog, allowedContentTypes: [.exe],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files): path = files.first?.path ?? ""
            case .failure(let error): print(error)
            }
        }
    }
}
