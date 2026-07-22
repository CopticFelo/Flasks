//
//  ContentView.swift
//  Flasks
//
//  Created by Philo on 17/07/2026.
//

import SwiftUI

struct ContentView: View {
    @Binding var selectedFlask: DummyFlask.ID?
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(
                DummyConstants.flaskList.first(where: { $0.id == selectedFlask })?.name ?? "Nuh uh")
        }
    }
}

// #Preview {
//     ContentView(selectedFlask: nil)
// }
