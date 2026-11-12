// /Users/wonderland/Developer/projects/aetheris/Sources/Exec/WonderlandApp.swift

import SwiftUI
import WonderlandApp

@main
public struct WonderlandAppExec: App {
    @StateObject private var runtimeViewModel = WonderlandRuntimeViewModel()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            WonderlandDashboardView(viewModel: self.runtimeViewModel)
        }
        .windowStyle(.automatic)
    }
}
