import SwiftUI

let winVersions = [
    "win7": "Windows 7",
    "win8": "Windows 8",
    "win8.1": "Windows 8.1",
    "win10": "Windows 10",
    "win11": "Windows 11",
]

struct CreateFlaskView: View {
    @State var selectedRunner: Runner?
    @State var selectedWinVer: String = "win10"
    @State var name = ""

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
                        ForEach(WineLibrary.shared.runners) { runner in
                            Text(runner.name ?? "Unknown").tag(runner)
                        }
                    }.labelsHidden().task {
                        Task.detached {
                            await WineLibrary.shared.scan()
                            DispatchQueue.main.async {
                                selectedRunner = WineLibrary.shared.runners.first
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
