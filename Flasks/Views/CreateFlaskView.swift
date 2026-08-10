import SwiftUI

let winVersions = [
    "win7": "Windows 7",
    "win8": "Windows 8",
    "win8.1": "Windows 8.1",
    "win10": "Windows 10",
    "win11": "Windows 11",
]

struct CreateFlaskView: View {
    @Binding var runnerLibrary: WineLibrary

    @Binding var selectedRunner: Runner?
    @Binding var selectedWinVer: String
    @Binding var name: String
    var body: some View {
        Form {
            TextField("Flask name", text: $name)
            Picker("Runner", selection: $selectedRunner) {
                ForEach(runnerLibrary.runners) { runner in
                    Text(runner.name ?? "Unknown").tag(runner)
                }
            }
            Picker("Windows version", selection: $selectedWinVer) {
                ForEach(winVersions.keys.sorted(), id: \.self) { key in
                    Text(winVersions[key]!).tag(key)
                }
            }
        }.formStyle(.grouped).scrollContentBackground(.hidden)
    }
}
