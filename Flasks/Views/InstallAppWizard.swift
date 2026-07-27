import SwiftUI

enum InstallAppWizardStep: Int, CaseIterable {
    case flask
    case app
    case options
}

struct InstallAppWizard: View {
    @Binding var isPresented: Bool
    @State private var step: InstallAppWizardStep = .flask

    @State var selectedRunner: Runner?
    @State var selectedWinVer: String = "win10"
    @State var name = ""

    @State var type: AppType = .standalone
    @State var path = ""
    @State var showFileDialog = false
    var body: some View {
        VStack {
            TabView(selection: $step) {
                CreateFlaskView(
                    selectedRunner: $selectedRunner, selectedWinVer: $selectedWinVer, name: $name
                ).tabItem {
                    Text("Flask")
                }.tag(InstallAppWizardStep.flask)
                AppInstallView(type: $type, path: $path, showFileDialog: $showFileDialog).tabItem {
                    Text("App")
                }.tag(InstallAppWizardStep.app)
                VStack {}.tabItem {
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
                            guard let selectedRunner else { return }
                            let flask = FlaskLibrary.shared.createFlask(
                                selectedRunner, name: name, windowsString: selectedWinVer)
                            guard let flask else { return }
                            FlaskLibrary.shared.flaskList.append(flask)
                            isPresented = false
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
                    )
                }
            }
        }.padding()
    }
    func next() {
        switch step {
        case .flask: step = .app
        case .app: step = .options
        case .options: step = .options
        }
    }
}
