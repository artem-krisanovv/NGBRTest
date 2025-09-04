import SwiftUI

struct ContractorView: View {

    var body: some View {
        NavigationStack {
            LazyVStack {
                Text("Список контрагентов")
                    .font(.title2)
                    .padding()
                
                List {
                    
                }

                Spacer()

                Button("Выйти") {
                    Task {
                        await TokenManager.shared.clearTokens()
                        await MainActor.run {
                            //isLoggedIn = false
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .cornerRadius(8)
                .padding()
            }
        }
    }
}

#Preview {
    ContractorView()
}
