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
    // FIX: Outdated name for the following var
    @State var showCreateFlaskSheet = false
    @State var showConsole = false

    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        Window("Flasks", id: "0") {
            NavigationSplitView {
                List(selection: $selectedFlask) {
                    Section {
                        ForEach(flaskLibrary.flaskList) { flask in
                            Text(flask.name)
                        }
                    }
                }.navigationTitle("Flasks")
                Section {
                    Button {
                        showCreateFlaskSheet = true
                    } label: {
                        Label("Create Flask", systemImage: "plus")
                    }.padding()
                }
            } detail: {
                if let flask = flaskLibrary.flaskList.first(where: { $0.id == selectedFlask }) {
                    AppGridView(
                        selectedFlask: flask,
                        showConsole: $showConsole
                    )
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                openWindow(id: "downloader")
                            }) {
                                Label("Downloader", systemImage: "arrow.down.circle")
                            }
                        }
                        ToolbarSpacer()
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                showConsole.toggle()
                            }) {
                                Label("Show Console", systemImage: "apple.terminal")
                            }
                        }
                    }
                }
            }.sheet(
                isPresented: $showCreateFlaskSheet,
                content: {
                    CreateFlaskWizard(isPresented: $showCreateFlaskSheet).frame(
                        width: 400, height: 275
                    ).environment(flaskLibrary)
                }
            )
        }
        WindowGroup(id: "downloader") {
            DownloadView()
        }
    }
}
