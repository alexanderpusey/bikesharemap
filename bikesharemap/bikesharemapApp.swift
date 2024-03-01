import SwiftUI
import SwiftData

@main
struct bikesharemapApp: App {
    
    @State private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: GBFSSystem.self)
        .environment(dataManager)
    }
}

