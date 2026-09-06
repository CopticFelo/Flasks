import SwiftUI

struct FlaskSettingsView: View {
    @Environment(FlaskLibrary.self) private var flaskLibrary

    let flask: Flask

    @Binding var isPresented: Bool

    @State var selectedBackend: DXTranslationLayer = .wined3d
    @State var sync: WineSync = WineSync.none
    @State var error: FlaskError?

    init(flask: Flask, isPresented: Binding<Bool>) {
        self.flask = flask
        self._isPresented = isPresented
        self._selectedBackend = State(initialValue: flask.settings.dxTranslationLayer)
        self._sync = State(initialValue: flask.settings.sync)
    }
    var body: some View {
        VStack {
            OptionView(selectedBackend: $selectedBackend, sync: $sync)
        }.toolbar {
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
                Button(
                    action: {
                        Task {
                            DispatchQueue.main.async {
                                error = nil
                            }
                            do {
                                // Set DXTranslationLayer
                                try flask.settings.setDXTranslationLayer(
                                    to: selectedBackend)
                                flask.settings.sync = self.sync
                                try flask.saveJson()
                                isPresented = false
                            } catch let flaskError as FlaskError {
                                DispatchQueue.main.async {
                                    self.error = flaskError
                                }
                            }
                        }
                    },
                    label: {
                        Text("Apply")
                    }
                )
            }
        }
    }
}
