import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppStateManager()
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                ContractorView()
                    .environmentObject(appState)
            } else {
                AuthView()
                    .environmentObject(appState)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
