import SwiftUI
import UniformTypeIdentifiers

enum AppType {
    case install
    case standalone
}

struct SelectProgramView: View {
    @Binding var type: AppType
    @Binding var path: String
    @Binding var showFileDialog: Bool
    var body: some View {
        Form {
            Picker("App Type", selection: $type) {
                Text("Standalone (Portable)").tag(AppType.standalone)
                Text("Installer").tag(AppType.install)
            }
            HStack {
                TextField("Path", text: $path)
                Button("Browse") {
                    showFileDialog = true
                }
            }
        }.formStyle(.grouped).scrollContentBackground(.hidden).padding().fileImporter(
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
