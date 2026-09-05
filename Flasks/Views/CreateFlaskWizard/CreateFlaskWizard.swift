import SwiftUI

let winVersions = [
    "win7": "Windows 7",
    "win8": "Windows 8",
    "win8.1": "Windows 8.1",
    "win10": "Windows 10",
    "win11": "Windows 11",
]

enum CreateFlaskWizardStep: Int, CaseIterable {
    case flask
    case options
}

struct CreateFlaskWizard: View {
    @Environment(FlaskLibrary.self) private var flaskLibrary
    @State private var runnerLibrary = WineLibrary()

    @Binding var isPresented: Bool
    @State private var step: CreateFlaskWizardStep = .flask

    @State var selectedRunner: Runner?
    @State var selectedWinVer: String = "win10"
    @State var name = ""

    @State var selectedBackend: DXTranslationLayer? = .wined3d
    @State var sync: WineSync? = WineSync.none

    @State var error: FlaskError?
    @State var isCreating = false
    var body: some View {
        VStack {
            if step == .flask {
                Form {
                    TextField("Flask name", text: $name)
                    Picker("Runner", selection: $selectedRunner) {
                        ForEach(runnerLibrary.runners) { runner in
                            Text(runner.name ?? "Unknown").tag(runner)
                        }
                    }
                    Picker("Windows version", selection: $selectedWinVer) {
                        ForEach(winVersions.keys.sorted(), id: \.self) { key in
                            Text(winVersions[key]!).tag(key)
                        }
                    }
                }.formStyle(.grouped).scrollContentBackground(.hidden)
            } else {
                OptionView(selectedBackend: $selectedBackend, sync: $sync)
                Spacer()
                if let error = error {
                    Text("\(error.localizedDescription)").foregroundStyle(.red).fontWeight(
                        .semibold)
                } else if isCreating {
                    ProgressView().progressViewStyle(.linear).padding()
                }
            }
        }.padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if step == .flask {
                        Button(
                            action: {
                                isPresented = false
                            },
                            label: {
                                Text("Cancel")
                            }
                        ).keyboardShortcut(.cancelAction)
                    } else {
                        Button(
                            action: {
                                step = .flask
                            },
                            label: {
                                Text("Back")
                            }
                        ).keyboardShortcut(.cancelAction)
                    }
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
                                        guard let selectedRunner else {
                                            throw FlaskError.formError(
                                                description: "Select a runner")
                                        }
                                        guard !name.isEmpty else {
                                            throw FlaskError.formError(
                                                description: "Enter a name")
                                        }
                                        DispatchQueue.main.async {
                                            isCreating = true
                                        }
                                        let flask = try await flaskLibrary.createFlask(
                                            selectedRunner, name: name,
                                            windowsString: selectedWinVer)
                                        // Set DXTranslationLayer
                                        try flask.settings.setDXTranslationLayer(
                                            to: selectedBackend ?? .wined3d)
                                        try flask.saveJson()
                                        flaskLibrary.flaskList.append(flask)
                                        isPresented = false
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
                        ).disabled(isCreating)
                    } else {
                        Button(
                            action: {
                                step = .options
                            },
                            label: {
                                Text("Next")
                            }
                        ).disabled(isCreating || name.isEmpty)
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
}
