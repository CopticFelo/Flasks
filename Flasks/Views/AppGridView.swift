import Foundation
import SwiftUI

struct AppGridView: View {
    var selectedFlask: Flask
    let columns = [GridItem(.adaptive(minimum: 100.0, maximum: 100.0), spacing: 20.0)]

    @State var selectedProgram: WineApp.ID?
    @State var error: FlaskError?

    @Binding var showConsole: Bool
    var body: some View {
        VSplitView {
            ScrollView {
                LazyVGrid(
                    columns: columns, alignment: .leading
                ) {
                    ForEach(selectedFlask.registeredApps) { wineApp in
                        AppIconView(
                            wineApp: wineApp,
                            flask: selectedFlask, selectedAppID: $selectedProgram,
                            error: $error
                        )
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding()
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
            }.frame(minHeight: 300.0)
            if showConsole {
                ConsoleView(flask: selectedFlask)
            }
        }
    }
}

struct AppIconView: View {
    let wineApp: WineApp
    var flask: Flask

    @Binding var selectedAppID: WineApp.ID?
    @Binding var error: FlaskError?

    @State var isRunning = false

    var body: some View {
        VStack(alignment: .center) {
            if isRunning {
                PhaseAnimator([true, false]) { phase in
                    Image(systemName: "questionmark.app").resizable()
                        .scaledToFit().offset(y: phase ? -8 : 0)
                } animation: { _ in
                    return Animation.interpolatingSpring(stiffness: 170, damping: 12)
                }
            } else {
                Image(systemName: "questionmark.app").resizable()
                    .scaledToFit()
            }
            Text("\(wineApp.appPath.lastPathComponent.prefix(20))").lineLimit(1)
        }.padding()
            .background(
                RoundedRectangle(cornerRadius: 6).fill(
                    selectedAppID == wineApp.id ? Color.accentColor : Color.clear
                )
            )
            .frame(width: 100, height: 100)
            .contentShape(Rectangle())
            .gesture(
                TapGesture(count: 2).onEnded {
                    isRunning = true
                    Task.detached {
                        defer {
                            DispatchQueue.main.async {
                                isRunning = false
                            }
                        }
                        do {
                            try await flask.runApp(wineApp.appPath)
                        } catch let err as FlaskError {
                            DispatchQueue.main.async {
                                error = err
                            }
                        }
                    }
                }
            )
            .simultaneousGesture(
                TapGesture().onEnded {
                    selectedAppID = wineApp.id
                }
            )
            .padding()
            .contextMenu {
                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([wineApp.appPath])
                } label: {
                    Label("Show in finder", systemImage: "folder")
                }
                Button(role: .destructive) {
                    do {
                        try flask.removeApp(wineApp.id)
                    } catch let err as FlaskError {
                        error = err
                    } catch {
                        // TODO: Use typed throws to avoid this rubbish
                    }
                } label: {
                    Label("Remove app from Flask", systemImage: "trash")
                }
            }
    }
}

// #Preview {
//     ContentView(selectedFlask: nil)
// }
