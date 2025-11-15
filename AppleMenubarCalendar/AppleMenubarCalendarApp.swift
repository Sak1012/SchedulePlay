import SwiftUI

@main
struct AppleMenubarCalendarApp: App {
    @StateObject private var model = StatusItemViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        MenuBarExtra {
            ContentView(model: model)
        } label: {
            MenuLabelView(model: model)
        }
        .menuBarExtraStyle(.window)
        .onChange(of: scenePhase) { newPhase in
            guard newPhase == .active else { return }
            Task { await model.refreshNow() }
        }
    }
}
