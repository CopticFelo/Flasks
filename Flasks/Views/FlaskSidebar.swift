import SwiftUI

struct FlaskSidebar: View {
    let flask: Flask

    @State var error: FlaskError?
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image(systemName: "wineglass").font(.largeTitle)
                Text("\(flask.name)").font(.largeTitle).bold()
            }
            Form {
                Section {
                    Button(
                        "Kill all Programs", systemImage: "xmark.circle",
                        action: {
                            Task {
                                do {
                                    try await flask.killAll()
                                } catch {
                                    self.error = error as? FlaskError
                                }
                            }
                        }
                    )
                    .buttonStyle(
                        .borderless)
                    Button(
                        "Open Task Manager", systemImage: "waveform.path.ecg.rectangle",
                        action: {
                            Task {
                                do {
                                    try await flask.runApp("taskmgr")
                                } catch {
                                    self.error = error as? FlaskError
                                }
                            }
                        }
                    ).buttonStyle(.borderless)
                }
                Section {
                    Button(
                        "Open winecfg", systemImage: "wrench.adjustable",
                        action: {
                            Task {
                                do {
                                    try await flask.runApp("winecfg")
                                } catch {
                                    self.error = error as? FlaskError
                                }
                            }
                        }
                    ).buttonStyle(.borderless)
                    Button(
                        "Open winetricks", systemImage: "wineglass",
                        action: {
                            // TODO: winetricks support
                        }
                    ).buttonStyle(.borderless)
                }
            }.formStyle(.grouped)
            Spacer()
        }.padding().frame(width: 350).frame(maxHeight: .infinity).background(.ultraThinMaterial)
            .alert(item: $error) { err in
                Alert(
                    title: Text(err.localizedDescription),
                    message: Text(
                        err.recoverySuggestion
                            ?? "Please open an issue on https://github.com/CopticFelo/Flasks/issues"
                    ),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}
