import Foundation

// MARK: - JWT Token Info
struct JWTTokenInfo {
    let expirationDate: Date?
    let roles: [String]
    let username: String?
    let issuedAt: Date?
    
    var isExpired: Bool {
        guard let exp = expirationDate else { return true }
        return exp.timeIntervalSinceNow <= 0
    }
    
    var isValid: Bool {
        guard let exp = expirationDate else { return false }
        return exp.timeIntervalSinceNow > 60
    }
}

// MARK: - JWT Decoder Implementation
struct JWTDecoder {
    // MARK: - Cache Info
    private static var tokenInfoCache: [String: JWTTokenInfo] = [:]
    private static let cacheQueue = DispatchQueue(label: "jwt.cache", attributes: .concurrent)
    private static let maxCacheSize = 10
    
    // MARK: - Public Methods
    static func decodeTokenInfo(from jwt: String) -> JWTTokenInfo? {
        if let cached = cacheQueue.sync(execute: {
            return tokenInfoCache[jwt]
        }) {
            if cached.isExpired {
                cacheQueue.async(flags: .barrier) {
                    tokenInfoCache.removeValue(forKey: jwt)
                }
                return nil
            }
            return cached
        }
        
        cleanupExpiredTokens()
        
        guard let payload = try? decodePayload(jwt) else { return nil }
        
        let tokenInfo = JWTTokenInfo(
            expirationDate: extractExpirationDate(from: payload),
            roles: extractRoles(from: payload),
            username: payload["username"] as? String,
            issuedAt: extractIssuedAt(from: payload)
        )
        
        cacheQueue.async(flags: .barrier) {
            if tokenInfoCache.count >= maxCacheSize {
                if let firstKey = tokenInfoCache.keys.first {
                    tokenInfoCache.removeValue(forKey: firstKey)
                }
            }
            tokenInfoCache[jwt] = tokenInfo
        }
        
        return tokenInfo
    }
    
    static func expirationDate(from jwt: String) -> Date? {
        return decodeTokenInfo(from: jwt)?.expirationDate
    }
    
    static func roles(from jwt: String) -> [String] {
        return decodeTokenInfo(from: jwt)?.roles ?? []
    }
    
    // MARK: - Cache Management
    static func clearCache() {
        cacheQueue.async(flags: .barrier) {
            tokenInfoCache.removeAll()
        }
    }
    
    static func removeFromCache(_ jwt: String) {
        cacheQueue.async(flags: .barrier) {
            tokenInfoCache.removeValue(forKey: jwt)
        }
    }
    
    // MARK: - Automatic Cache Cleanup
    private static func cleanupExpiredTokens() {
        cacheQueue.async(flags: .barrier) {
            let expiredKeys = tokenInfoCache.compactMap { (key, tokenInfo) in
                tokenInfo.isExpired ? key : nil
            }
            
            expiredKeys.forEach { key in
                tokenInfoCache.removeValue(forKey: key)
            }
        }
    }
    
    // MARK: - Private Methods
    private static func decodePayload(_ jwt: String) throws -> [String: Any] {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw JWTDecodeError.invalidFormat
        }
        
        let payload = parts[1]
        let base64 = normalizeBase64(payload)
        
        guard let data = Data(base64Encoded: base64) else {
            throw JWTDecodeError.invalidBase64
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw JWTDecodeError.invalidJson
        }
        
        return json
    }
    
    private static func normalizeBase64(_ base64: String) -> String {
        return base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .appending(String(repeating: "=", count: (4 - base64.count % 4) % 4))
    }
    
    private static func extractExpirationDate(from payload: [String: Any]) -> Date? {
        guard let exp = payload["exp"] else { return nil }
        
        if let expDouble = exp as? Double {
            return Date(timeIntervalSince1970: expDouble)
        } else if let expString = exp as? String,
                  let expDouble = Double(expString) {
            return Date(timeIntervalSince1970: expDouble)
        }
        
        return nil
    }
    
    private static func extractRoles(from payload: [String: Any]) -> [String] {
        guard let roles = payload["roles"] else { return [] }
        
        if let rolesArray = roles as? [String] {
            return rolesArray
        } else if let roleString = roles as? String {
            return [roleString]
        } else if let rolesString = roles as? String {
            return rolesString
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }
        
        return []
    }
    
    private static func extractIssuedAt(from payload: [String: Any]) -> Date? {
        guard let iat = payload["iat"] else { return nil }
        
        if let iatDouble = iat as? Double {
            return Date(timeIntervalSince1970: iatDouble)
        } else if let iatString = iat as? String,
                  let iatDouble = Double(iatString) {
            return Date(timeIntervalSince1970: iatDouble)
        }
        
        return nil
    }
}
