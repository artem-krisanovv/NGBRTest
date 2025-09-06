import Foundation

// MARK: - APIClient Implementation
final class APIClient: APIClientProtocol {
    static let shared = APIClient(baseURL: URL(string: "https://truck-api.ngbr.avesweb.ru/api")!)
    
    private let baseURL: URL
    private let tokenManager: TokenManagerProtocol
    
    init(baseURL: URL, tokenManager: TokenManagerProtocol = TokenManager.shared) {
        self.baseURL = baseURL
        self.tokenManager = tokenManager
    }
    
    // MARK: - Request Methods
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil,
        retryingAfterRefresh: Bool = false
    ) async throws -> T {
        let url = makeURL(path: path, queryItems: queryItems)
        var req = URLRequest(url: url)
        req.httpMethod = method
        
        if let body = body {
            req.httpBody = body
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if path != "/login_check" && path != "/token/refresh" {
            do {
                let token = try await tokenManager.getValidAccessToken()
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } catch {
                throw APIError.unauthorized
            }
        }
        
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else {
                throw APIError.httpError(status: -1, data: data)
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? "No data"
            print("API Response (\(path)): \(responseString)")
            
            switch http.statusCode {
            case 200...299:
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    return decoded
                } catch {
                    print("Decoding error for \(path): \(error)")
                    print("Response data: \(responseString)")
                    throw APIError.decodingError
                }
                
            case 401:
                if retryingAfterRefresh {
                    throw APIError.unauthorized
                }
                do {
                    _ = try await tokenManager.refreshToken()
                    return try await request(
                        path: path,
                        method: method,
                        body: body,
                        queryItems: queryItems,
                        retryingAfterRefresh: true
                    )
                } catch {
                    throw APIError.unauthorized
                }
                
            case 403:
                Task.detached { [weak self] in
                    await self?.handle403Background()
                }
                throw APIError.accessDenied
                
            default:
                throw APIError.httpError(status: http.statusCode, data: data)
            }
        } catch {
            if error is APIError {
                throw error
            }
            throw APIError.networkError
        }
    }
    
    // MARK: - Error 403 Handling
    private func handle403Background() async {
        guard let saved = tokenManager.loadSavedToken() else { return }
        let oldRoles = saved.roles
        
        do {
            let newToken = try await tokenManager.refreshToken()
            let newRoles = JWTDecoder.roles(from: newToken.accessToken)
            
            JWTDecoder.removeFromCache(saved.accessToken)
            
            if Set(newRoles) == Set(oldRoles) {
                print("Доступ запрещен: роли не изменились")
            } else {
                print("Доступ запрещен: роли изменились")
            }
        } catch {
            print("Ошибка обновления токена: \(error)")
            clearJWTCache()
        }
    }
    
    // MARK: - URL Building
    private func makeURL(path: String, queryItems: [URLQueryItem]? = nil) -> URL {
        var comp = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        comp.queryItems = queryItems
        return comp.url!
    }
    
    // MARK: - Cache Management
    func clearJWTCache() {
        JWTDecoder.clearCache()
    }
}

// MARK: - Authentication Extension
extension APIClient {
    func authenticate(username: String, password: String) async throws -> AuthToken {
        let url = baseURL.appendingPathComponent("login_check")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(username: username, password: password)
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw APIError.httpError(status: -1, data: data)
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? "No data"
        print("API Response: \(responseString)")
        
        guard (200..<300).contains(http.statusCode) else {
            switch http.statusCode {
            case 400, 401, 500:
                throw APIError.unauthorized
            case 403:
                throw APIError.accessDenied
            default:
                let errorBody = String(data: data, encoding: .utf8) ?? "No data"
                print("API Error \(http.statusCode): \(errorBody)")
                throw APIError.httpError(status: http.statusCode, data: data)
            }
        }
        do {
            let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
            try tokenManager.saveTokens(access: decoded.token, refresh: decoded.refreshToken)
            return AuthToken(accessToken: decoded.token, refreshToken: decoded.refreshToken)
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(responseString)")
            throw APIError.decodingError
        }
    }
    
    func refreshToken() async throws -> AuthToken {
        guard let savedToken = tokenManager.loadSavedToken() else {
            throw AuthError.noRefreshToken
        }
        
        let url = baseURL.appendingPathComponent("token/refresh")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RefreshTokenRequest(refreshToken: savedToken.refreshToken)
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw APIError.httpError(status: -1, data: data)
        }
        
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 {
                throw AuthError.unauthorized
            } else {
                throw APIError.httpError(status: http.statusCode, data: data)
            }
        }
        
        do {
            let decoded = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
            try tokenManager.saveTokens(access: decoded.token, refresh: decoded.refreshToken)
            return AuthToken(accessToken: decoded.token, refreshToken: decoded.refreshToken)
        } catch {
            throw APIError.decodingError
        }
    }
}
