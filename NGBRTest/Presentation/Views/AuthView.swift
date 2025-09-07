import SwiftUI

// MARK: - Authentication View
struct AuthView: View {
    @ObservedObject private var viewModel: AuthViewModel
    @ObservedObject private var appState: AppStateManager
    
    // MARK: - Init
    init(viewModel: AuthViewModel, appState: AppStateManager) {
        self.viewModel = viewModel
        self.appState = appState
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Image("logo")
                    .resizable()
                    .frame(width: 55, height: 70)
                    .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Имя пользователя")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите имя пользователя", text: $viewModel.username)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray.opacity(0.3)))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пароль")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SecureField("Введите пароль", text: $viewModel.password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray.opacity(0.3)))
                }
                
                Button(action: { [weak viewModel] in
                    Task {
                        await viewModel?.login()
                    }
                }, label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Войти")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                })
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("ОК", role: .cancel) { [weak viewModel] in
                    viewModel?.errorMessage = nil
                }
            }, message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            })
            .onChange(of: viewModel.isAuthenticated) { [weak appState] _, newValue in
                if newValue {
                    appState?.login()
                }
            }
        }
    }
}
