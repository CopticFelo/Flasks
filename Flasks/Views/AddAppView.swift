import SwiftUI
import UniformTypeIdentifiers

struct AddAppView: View {
    var flask: Flask

    @State var path: String = ""
    @State var showFileDialog: Bool = false
    @State var error: FlaskError?

    @Binding var showAppAddSheet: Bool
    var body: some View {
        Form {
            HStack {
                TextField("Path", text: $path)
                Button("Browse") {
                    showFileDialog = true
                }
            }
            if let error {
                Text("\(error.localizedDescription)").foregroundStyle(.red).fontWeight(
                    .semibold)
            }
        }.formStyle(.grouped).scrollContentBackground(.hidden).padding().fileImporter(
            isPresented: $showFileDialog, allowedContentTypes: [.exe],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files): path = files.first?.path ?? ""
            case .failure(let error): print(error)
            }
        }.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    showAppAddSheet = false
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    defer {
                        showAppAddSheet = false
                    }
                    do {
                        guard FileManager.default.fileExists(atPath: path) else {
                            throw FlaskError.fileError(detail: CocoaError(.fileNoSuchFile))
                        }
                        try flask.registerApp(URL(filePath: path))
                    } catch let err as FlaskError {
                        error = err
                    } catch {
                        self.error = FlaskError.unknownError
                    }
                } label: {
                    Text("Add")
                }.keyboardShortcut(.defaultAction)
                    .disabled(path.isEmpty)
            }
        }
    }
}
