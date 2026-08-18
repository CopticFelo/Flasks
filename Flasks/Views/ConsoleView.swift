import SwiftUI

struct ConsoleView: View {
    var flask: Flask
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("Console").font(.headline)
                Spacer()
                Button(role: .destructive) {
                    flask.consoleOutput.removeAll()
                } label: {
                    Image(systemName: "clear")
                }.buttonStyle(.bordered).buttonBorderShape(.circle).controlSize(.large)
            }.padding().frame(height: 35)
            Divider()
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(flask.consoleOutput) { line in
                            Text(
                                line.fullMessage()
                            ).font(
                                .system(.body, design: .monospaced)
                            ).id(line.id)
                        }
                    }
                }.frame(minHeight: 200.0).background(Color.black.opacity(0.15)).cornerRadius(8.0)
                    .onChange(of: flask.consoleOutput) {
                        if let lastLog = flask.consoleOutput.last {
                            proxy.scrollTo(lastLog.id)
                        }
                    }
            }
        }
    }
}
