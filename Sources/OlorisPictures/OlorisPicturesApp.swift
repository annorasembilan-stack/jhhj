import SwiftUI

@main
struct OlorisPicturesApp: App {
    @StateObject private var vm = ConverterViewModel()

    var body: some Scene {
        WindowGroup("Oloris Pictures") {
            ContentView()
                .environmentObject(vm)
                .frame(minWidth: 860, minHeight: 660)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
