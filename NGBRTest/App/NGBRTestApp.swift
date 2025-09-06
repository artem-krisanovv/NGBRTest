import SwiftUI

// MARK: - App Entry Point
@main
struct NGBRTestApp: App {
    let persistenceController = PersistenceController.shared
    
    // MARK: - App Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
