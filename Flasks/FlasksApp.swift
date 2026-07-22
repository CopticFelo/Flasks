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
    @State private var selectedFlask: DummyFlask.ID?
    @State var installer = WineDownloader()

    init() {
        guard
            let downloadUrl = URL(
                string:
                    "https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.13/wine-devel-11.13-osx64.tar.xz"
            )
        else { return }
        print("Started download")
        installer.untarAndInstall(
            URL(fileURLWithPath: "/Users/felo/Library/Caches/wine-devel-11.13-osx64.tar.xz"))
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
                                print("Add item to sidebar")
                            }) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                    }
            }.setupNvimPreview {
                ContentView(selectedFlask: $selectedFlask)
            }
        }
    }
}
