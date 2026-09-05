import SwiftUI

struct OptionView: View {
    @Binding var selectedBackend: DXTranslationLayer?
    @Binding var sync: WineSync?
    var body: some View {
        Form {
            Picker("Rendering backend", selection: $selectedBackend) {
                ForEach(DXTranslationLayer.allCases) { backend in
                    Text(backend.rawValue).help(backend.help).tag(backend)
                }
            }
            Picker("Sync", selection: $sync) {
                ForEach(WineSync.allCases) { syncCase in
                    Text(syncCase.rawValue).tag(syncCase)
                }
            }.pickerStyle(.radioGroup)
        }.formStyle(.grouped).scrollContentBackground(.hidden)
    }
}
