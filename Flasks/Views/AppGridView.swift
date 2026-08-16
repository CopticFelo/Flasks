import Foundation
import SwiftUI

struct AppGridView: View {
    let selectedFlask: Flask
    let columns = [GridItem(.adaptive(minimum: 100.0, maximum: 100.0), spacing: 20.0)]

    @State var selectedProgram: WineApp.ID?
    var body: some View {
        LazyVGrid(
            columns: columns, alignment: .leading
        ) {
            ForEach(selectedFlask.registeredApps) { wineApp in
                AppIconView(
                    flask: selectedFlask, wineApp: wineApp, selectedAppID: $selectedProgram
                )
            }
        }.frame(maxHeight: .infinity, alignment: .top).padding()
    }
}

struct AppIconView: View {
    let flask: Flask
    let wineApp: WineApp

    @Binding var selectedAppID: WineApp.ID?

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
                        try await flask.runApp(wineApp.appPath)
                        DispatchQueue.main.async {
                            isRunning = false
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
    }
}

// #Preview {
//     ContentView(selectedFlask: nil)
// }
