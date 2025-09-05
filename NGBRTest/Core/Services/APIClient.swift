import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(
        path: String,
        method: String,
        body: Data?,
        queryItems: [URLQueryItem]?,
        retryingAfterRefresh: Bool
    ) async throws -> T
    
    func authenticate(username: String, password: String) async throws -> AuthToken
}

enum APIError: Error, LocalizedError {
    case httpError(status: Int, data: Data?)
    case decodingError
    case unauthorized
    case accessDenied
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .httpError(let status, _):
            return "HTTP Error: \(status)"
        case .decodingError:
            return "Failed to decode response"
        case .unauthorized:
            return "Unauthorized access"
        case .accessDenied:
            return "Access denied"
        case .networkError:
            return "Network error"
        }
    }
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient(baseURL: URL(string: "https://truck-api.ngbr.avesweb.ru/api")!)
    
    private let baseURL: URL
    private let tokenManager: TokenManagerProtocol
    
    init(baseURL: URL, tokenManager: TokenManagerProtocol = TokenManager.shared) {
        self.baseURL = baseURL
        self.tokenManager = tokenManager
    }
    
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
            
            switch http.statusCode {
            case 200...299:
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    return decoded
                } catch {
                    print("Decoding error: \(error)")
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
    
    private func handle403Background() async {
        guard let saved = tokenManager.loadSavedToken() else { return }
        let oldRoles = saved.roles
        
        do {
            let newToken = try await tokenManager.refreshToken()
            let newRoles = JWTDecoder.roles(from: newToken.accessToken)
            if Set(newRoles) == Set(oldRoles) {
                print("Access denied: roles match but access is still forbidden")
            } else {
                print("Access denied: roles have changed")
            }
        } catch {
            print("Failed to refresh token in background: \(error)")
        }
    }
    
    private func makeURL(path: String, queryItems: [URLQueryItem]? = nil) -> URL {
        var comp = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        comp.queryItems = queryItems
        return comp.url!
    }
}

// MARK: - Authentication
extension APIClient {
    struct LoginRequest: Encodable {
        let username: String
        let password: String
    }
    
    struct LoginResponse: Decodable {
        let token: String
        let refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case token
            case refreshToken = "refresh_token"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            token = try container.decode(String.self, forKey: .token)
            
            if let refresh = try? container.decode(String.self, forKey: .refreshToken) {
                refreshToken = refresh
            } else {
                refreshToken = token
            }
        }
    }
    
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
        
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 {
                throw APIError.unauthorized
            } else {
                let errorBody = String(data: data, encoding: .utf8) ?? "No data"
                print("API Error \(http.statusCode): \(errorBody)")
                throw APIError.httpError(status: http.statusCode, data: data)
            }
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? "No data"
        print("API Response: \(responseString)")
        
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
}
