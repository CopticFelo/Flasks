import SwiftUI

enum InstallAppWizardStep: Int, CaseIterable {
    case flask
    case app
    case options
}

struct InstallAppWizard: View {
    @Binding var isPresented: Bool
    @State private var step: InstallAppWizardStep = .flask
    var body: some View {
        VStack {
            TabView(selection: $step) {
                CreateFlaskView().tabItem {
                    Text("Flask")
                }.tag(InstallAppWizardStep.flask)
                VStack {}.tabItem {
                    Text("App")
                }.tag(InstallAppWizardStep.app)
                VStack {}.tabItem {
                    Text("Options")
                }.tag(InstallAppWizardStep.options)
            }
            Divider()
            HStack {
                Spacer()
                if step == .flask {
                    Button(
                        action: {
                            isPresented = false
                        },
                        label: {
                            Text("Cancel")
                        })
                } else {
                    Button(
                        action: {
                            prev()
                        },
                        label: {
                            Text("Back")
                        })
                }
                if step == .options {
                    Button(
                        action: {
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
    func prev() {
        switch step {
        case .flask: step = .flask
        case .app: step = .flask
        case .options: step = .app
        }
    }
}
