import SwiftUI

struct ContentView: View {
    @StateObject private var daemonClient = WonderlandDaemonClient()

    var body: some View {
        VStack {
            Text("Aetheris Command Hub")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Ensure the view is rendered here:
            VirtualMachinesView(daemonClient: self.daemonClient)

            Spacer()
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}
