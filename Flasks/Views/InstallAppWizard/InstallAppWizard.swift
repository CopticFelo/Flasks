import SwiftUI

enum InstallAppWizardStep: Int, CaseIterable {
    case flask
    case app
    case options
}

struct InstallAppWizard: View {
    @Environment(FlaskLibrary.self) private var flaskLibrary
    @State private var runnerLibrary = WineLibrary()

    @Binding var isPresented: Bool
    @State private var step: InstallAppWizardStep = .flask

    @State private var selectedFlask: Flask.ID?

    @State var selectedRunner: Runner?
    @State var selectedWinVer: String = "win10"
    @State var name = ""

    @State var type: AppType = .standalone
    @State var path = ""
    @State var showFileDialog = false

    @State var error: FlaskError?
    @State var isCreating = false
    var body: some View {
        VStack {
            TabView(selection: $step) {
                VStack {
                    CreateFlaskView(
                        runnerLibrary: $runnerLibrary,
                        selectedFlask: $selectedFlask,
                        selectedRunner: $selectedRunner, selectedWinVer: $selectedWinVer,
                        name: $name
                    )
                }.tabItem {
                    Text("Flask")
                }.tag(InstallAppWizardStep.flask)
                SelectProgramView(type: $type, path: $path, showFileDialog: $showFileDialog).tabItem
                {
                    Text("App")
                }.tag(InstallAppWizardStep.app)
                VStack {
                    Spacer()
                    if let error = error {
                        Text("\(error.localizedDescription)").foregroundStyle(.red).fontWeight(
                            .semibold)
                    } else if isCreating {
                        ProgressView().progressViewStyle(.linear).padding()
                    }
                }.tabItem {
                    Text("Options")
                }.tag(InstallAppWizardStep.options)
            }
        }.padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(
                        action: {
                            isPresented = false
                        },
                        label: {
                            Text("Cancel")
                        }
                    ).keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .primaryAction) {
                    if step == .options {
                        Button(
                            action: {
                                Task {
                                    DispatchQueue.main.async {
                                        error = nil
                                    }
                                    do {
                                        if selectedFlask == nil {
                                            guard let selectedRunner else {
                                                throw FlaskError.formError(
                                                    description: "Select a runner")
                                            }
                                            guard !name.isEmpty else {
                                                throw FlaskError.formError(
                                                    description: "Enter a name")
                                            }
                                            guard FileManager.default.fileExists(atPath: path)
                                            else {
                                                throw FlaskError.fileError(
                                                    detail: CocoaError(.fileNoSuchFile))
                                            }
                                            DispatchQueue.main.async {
                                                isCreating = true
                                            }
                                            let flask = try await flaskLibrary.createFlask(
                                                selectedRunner, name: name,
                                                windowsString: selectedWinVer)
                                            // intentional return btw
                                            // we would probably need a more complex system
                                            guard !path.isEmpty else {
                                                flaskLibrary.flaskList.append(flask)
                                                isPresented = false
                                                return
                                            }
                                            let programURL = URL(
                                                filePath: path, directoryHint: .notDirectory)
                                            try flask.registerApp(programURL)
                                            flaskLibrary.flaskList.append(flask)
                                            isPresented = false
                                        } else {
                                            let flask = flaskLibrary.flaskList.first(where: {
                                                $0.id == selectedFlask
                                            })
                                            guard !path.isEmpty else {
                                                isPresented = false
                                                return
                                            }
                                            let programURL = URL(
                                                filePath: path, directoryHint: .notDirectory)
                                            try flask?.registerApp(programURL)
                                            isPresented = false
                                        }
                                    } catch let flaskError as FlaskError {
                                        DispatchQueue.main.async {
                                            isCreating = false
                                            self.error = flaskError
                                        }
                                    }
                                }
                            },
                            label: {
                                Text("Create")
                            }
                        )
                    } else {
                        Button(
                            action: {
                                next()
                            },
                            label: {
                                Text("Next")
                            }
                        ).disabled(isCreating || (name.isEmpty && selectedFlask == nil))
                    }
                }
            }
            .task {
                try? await runnerLibrary.scan()
                DispatchQueue.main.async {
                    selectedRunner = runnerLibrary.runners.first
                }
            }
    }

    func next() {
        switch step {
        case .flask: step = .app
        case .app: step = .options
        case .options: step = .options
        }
    }
}
