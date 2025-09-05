import SwiftUI

@main
struct NGBRTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AuthView()
        }
    }
}
