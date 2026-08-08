import SwiftUI

let winVersions = [
    "win7": "Windows 7",
    "win8": "Windows 8",
    "win8.1": "Windows 8.1",
    "win10": "Windows 10",
    "win11": "Windows 11",
]

struct CreateFlaskView: View {
    @Environment(WineLibrary.self) private var runnerLibrary

    @Binding var selectedRunner: Runner?
    @Binding var selectedWinVer: String
    @Binding var name: String
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20.0) {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Flask name", text: $name)
                }
                HStack {
                    Text("Runner")
                    Spacer()
                    Picker("Runner", selection: $selectedRunner) {
                        ForEach(runnerLibrary.runners) { runner in
                            Text(runner.name ?? "Unknown").tag(runner)
                        }
                    }.labelsHidden().task {
                        Task.detached {
                            try? await runnerLibrary.scan()
                            DispatchQueue.main.async {
                                selectedRunner = runnerLibrary.runners.first
                            }
                        }
                    }
                }
                HStack {
                    Text("Windows version")
                    Spacer()
                    Picker("Windows version", selection: $selectedWinVer) {
                        ForEach(winVersions.keys.sorted(), id: \.self) { key in
                            Text(winVersions[key]!).tag(key)
                        }
                    }.labelsHidden()
                }
            }.padding()
        }.padding()
    }
}
