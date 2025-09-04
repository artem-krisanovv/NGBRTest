import Foundation

enum APIError: Error {
    case httpError(status: Int, data: Data?)
    case decodingError
    case unauthorized
    case accessDenied
}

final class APIClient {
    static let shared = APIClient(baseURL: URL(string: "https://truck-api.ngbr.avesweb.ru/api")!)

    private let baseURL: URL
    private let tokenManager = TokenManager.shared

    init(baseURL: URL) {
        self.baseURL = baseURL
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

        do {
            let token = try await tokenManager.getValidAccessToken()
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } catch {
            throw APIError.unauthorized
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.httpError(status: -1, data: data) }

        switch http.statusCode {
        case 200...299:
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw APIError.decodingError
            }

        case 401:
            if retryingAfterRefresh {
                throw APIError.unauthorized
            }
            do {
                _ = try await tokenManager.getValidAccessToken()
                return try await request(path: path, method: method, body: body, queryItems: queryItems, retryingAfterRefresh: true)
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
    }

    private func handle403Background() async {
        guard let saved = await tokenManager.loadSavedToken() else { return }
        let oldRoles = saved.roles

        do {
            let newToken = try await tokenManager.getValidAccessToken()
            let newRoles = JWTDecoder.roles(from: newToken)
            if Set(newRoles) == Set(oldRoles) {
            } else {
                //
            }
        } catch {
            //
        }
    }

    private func makeURL(path: String, queryItems: [URLQueryItem]? = nil) -> URL {
        var comp = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        comp.queryItems = queryItems
        return comp.url!
    }
}

extension APIClient {
    struct LoginRequest: Encodable {
        let username: String
        let password: String
    }

    struct LoginResponse: Decodable {
        let token: String
        let refreshToken: String
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
                throw APIError.httpError(status: http.statusCode, data: data)
            }
        }

        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)

        try await TokenManager.shared.saveTokens(access: decoded.token,
                                                 refresh: decoded.refreshToken)

        return AuthToken(accessToken: decoded.token,
                         refreshToken: decoded.refreshToken)
    }
}

