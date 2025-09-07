import SwiftUI

// MARK: - Content View
struct ContentView: View {
    @StateObject private var appState: AppStateManager
    @StateObject private var serviceContainer: ServiceContainer
    
    // MARK: - Init
    init() {
        let container = ServiceContainer()
        _serviceContainer = StateObject(wrappedValue: container)
        _appState = StateObject(wrappedValue: AppStateManager(tokenManager: container.tokenManager))
    }
    
    // MARK: - View Body
    var body: some View {
        Group {
            if appState.isAuthenticated {
                ContractorViewFactory.create(serviceContainer: serviceContainer, appState: appState)
                    .environmentObject(appState)
                    .environmentObject(serviceContainer)
            } else {
                AuthViewFactory.create(serviceContainer: serviceContainer, appState: appState)
                    .environmentObject(appState)
                    .environmentObject(serviceContainer)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
