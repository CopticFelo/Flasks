//
//  FlasksApp.swift
//  Flasks
//
//  Created by Philo on 17/07/2026.
//

import SwiftUI
import System
import XcodebuildNvimPreview

@main
struct FlasksApp: App {
    @State private var flaskLibrary = FlaskLibrary()

    @State private var selectedFlask: Flask.ID?
    @State var runnerDownloadSheet = false

    var body: some Scene {
        Window("Flasks", id: "0") {
            NavigationSplitView {
                List(flaskLibrary.flaskList, selection: $selectedFlask) {
                    Text($0.name)
                }.navigationTitle("Flasks")
            } detail: {
                if let flask = flaskLibrary.flaskList.first(where: { $0.id == selectedFlask }) {
                    ProgramsGridView(
                        selectedFlask: flask
                    )
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                runnerDownloadSheet = true
                            }) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                    }
                }
            }.sheet(
                isPresented: $runnerDownloadSheet,
                content: {
                    InstallAppWizard(isPresented: $runnerDownloadSheet).frame(
                        width: 400, height: 275
                    ).environment(flaskLibrary)
                }
            )
            // .setupNvimPreview {
            //     ContentView(selectedFlask: $selectedFlask)
            // }
        }
    }
}
