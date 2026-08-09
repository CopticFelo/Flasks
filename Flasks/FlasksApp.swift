//
//  FlasksApp.swift
//  Flasks
//
//  Created by Philo on 17/07/2026.
//

import SwiftUI
import System
import XcodebuildNvimPreview

struct DummyFlask: Identifiable, Hashable {
    let name: String
    let id = UUID()
}

class DummyConstants {
    static var flaskList = [
        DummyFlask(name: "All"),
        DummyFlask(name: "General"),
        DummyFlask(name: "Omor"),
        DummyFlask(name: "GTAV"),
        DummyFlask(name: "Office"),
    ]
}

@main
struct FlasksApp: App {
    @State private var flaskLibrary = FlaskLibrary()

    // TODO: This instance is not actually need in this view, consider alternative locations
    @State private var runnerLibrary = WineLibrary()

    @State private var selectedFlask: DummyFlask.ID?
    @State var runnerDownloadSheet = false

    init() {
        try? flaskLibrary.scan()
    }

    var body: some Scene {
        Window("Flasks", id: "0") {
            NavigationSplitView {
                List(DummyConstants.flaskList, selection: $selectedFlask) {
                    Text($0.name)
                }.navigationTitle("Flasks")
            } detail: {
                ContentView(selectedFlask: $selectedFlask)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                runnerDownloadSheet = true
                            }) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                    }.task {
                        // HACK: This is sorta not good
                        try? await runnerLibrary.scan()
                    }
            }.sheet(
                isPresented: $runnerDownloadSheet,
                content: {
                    InstallAppWizard(isPresented: $runnerDownloadSheet).frame(
                        width: 500, height: 400
                    ).environment(flaskLibrary).environment(runnerLibrary)
                }
            )
            // .setupNvimPreview {
            //     ContentView(selectedFlask: $selectedFlask)
            // }
        }
    }
}
