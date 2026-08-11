//
//  ContentView.swift
//  Flasks
//
//  Created by Philo on 17/07/2026.
//

import SwiftUI

struct ProgramsGridView: View {
    let selectedFlask: Flask

    let columns = [GridItem(.adaptive(minimum: 80.0, maximum: 80.0), spacing: 20.0)]
    var body: some View {
        LazyVGrid(
            columns: columns, alignment: .leading
        ) {
            ForEach(selectedFlask.registeredApps) { path in
                ProgramIconView(flask: selectedFlask, programPath: path).padding()
            }
        }.frame(maxHeight: .infinity, alignment: .top).padding()
    }
}

struct ProgramIconView: View {
    let flask: Flask
    let programPath: URL
    var body: some View {
        VStack(alignment: .center) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: programPath.path)).resizable()
                .scaledToFit()
            Text("\(programPath.lastPathComponent.prefix(20))").lineLimit(1)
        }.contentShape(Rectangle())
            .onTapGesture(count: 2) {
                Task.detached {
                    try await flask.runApp(programPath)
                }
            }
    }
}

// #Preview {
//     ContentView(selectedFlask: nil)
// }
