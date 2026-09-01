import SwiftUI

struct OptionView: View {
    @Binding var selectedBackend: DXTranslationLayer?
    var body: some View {
        Form {
            Picker("Rendering backend", selection: $selectedBackend) {
                ForEach(DXTranslationLayer.allCases) { backend in
                    Text(backend.rawValue).help(backend.help).tag(backend)
                }
            }
        }.formStyle(.grouped).scrollContentBackground(.hidden)
    }
}
