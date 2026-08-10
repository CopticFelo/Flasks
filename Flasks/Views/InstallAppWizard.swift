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
                CreateFlaskView(
                    runnerLibrary: $runnerLibrary,
                    selectedRunner: $selectedRunner, selectedWinVer: $selectedWinVer, name: $name
                ).tabItem {
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
            Divider()
            HStack {
                Spacer()
                Button(
                    action: {
                        isPresented = false
                    },
                    label: {
                        Text("Cancel")
                    })
                if step == .options {
                    Button(
                        action: {
                            // TODO: Handle empty fields
                            Task {
                                error = nil
                                guard let selectedRunner else { return }
                                do {
                                    isCreating = true
                                    let flask = try await flaskLibrary.createFlask(
                                        selectedRunner, name: name, windowsString: selectedWinVer)
                                    flaskLibrary.flaskList.append(flask)
                                    isPresented = false
                                } catch let flaskError as FlaskError {
                                    isCreating = false
                                    self.error = flaskError
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
                    ).disabled(isCreating)
                }
            }
        }.padding().task {
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
