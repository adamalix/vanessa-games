import SharedAssets
import SharedGameEngine
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "cloud.rain")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Clausy the Cloud")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Water the plants!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
