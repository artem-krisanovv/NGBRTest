import SwiftUI

struct LoginView: View {

    @State private var username: String = "" //"92d0e8d5-4ecb-4ae2-9d1a-4a66331f65d3"
    @State private var password: String = "" //12345"

    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

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
                    TextField("Введите имя пользователя", text: $username)
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
                    SecureField("Введите пароль", text: $password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray.opacity(0.3)))
                }

                Button(action: {
                    Task { await performLogin() }
                }, label: {
                    if isLoading {
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
                .disabled(isLoading || username.isEmpty || password.isEmpty)
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .alert("Ошибка", isPresented: $showAlert, actions: {
                Button("ОК", role: .cancel) {}
            }, message: {
                Text(alertMessage)
            })
        }
    }

    private func performLogin() async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await APIClient.shared.authenticate(username: username, password: password)

            await MainActor.run {
                //isLoggedIn = true
            }
        } catch APIError.unauthorized {
            alertMessage = "Неверный логин или пароль"
            showAlert = true
        } catch APIError.httpError(let status, let data) {
            var body = ""
            if let data = data, let s = String(data: data, encoding: .utf8) { body = s }
            alertMessage = "Ошибка сервера: \(status). \(body)"
            showAlert = true
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}

#Preview {
    LoginView()
}
