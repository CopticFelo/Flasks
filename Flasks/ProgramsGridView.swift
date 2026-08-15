//
//  ContentView.swift
//  Flasks
//
//  Created by Philo on 17/07/2026.
//

import SwiftUI

struct ProgramsGridView: View {
    let selectedFlask: Flask
    let columns = [GridItem(.adaptive(minimum: 100.0, maximum: 100.0), spacing: 20.0)]

    @State var selectedProgram: URL?
    var body: some View {
        LazyVGrid(
            columns: columns, alignment: .leading
        ) {
            ForEach(selectedFlask.registeredApps) { path in
                ProgramIconView(
                    flask: selectedFlask, programPath: path, selectedProgram: $selectedProgram
                )
            }
        }.frame(maxHeight: .infinity, alignment: .top).padding()
    }
}

struct ProgramIconView: View {
    let flask: Flask
    let programPath: URL

    @Binding var selectedProgram: URL?

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "questionmark.app").resizable()
                .scaledToFit()
            Text("\(programPath.lastPathComponent.prefix(20))").lineLimit(1)
        }.padding()
            .background(
                RoundedRectangle(cornerRadius: 6).fill(
                    selectedProgram == programPath ? Color.accentColor : Color.clear
                )
            )
            .frame(width: 100, height: 100)
            .contentShape(Rectangle())
            .gesture(
                TapGesture(count: 2).onEnded {
                    Task.detached {
                        try await flask.runApp(programPath)
                    }
                }
            )
            .simultaneousGesture(
                TapGesture().onEnded {
                    selectedProgram = programPath
                }
            )
            .padding()
    }
}

// #Preview {
//     ContentView(selectedFlask: nil)
// }
