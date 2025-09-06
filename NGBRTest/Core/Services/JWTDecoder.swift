import Foundation

// MARK: - JWT Decoder Implementation
struct JWTDecoder {
    static func decodePayload(_ jwt: String) throws -> [String: Any] {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count >= 2 else { throw JWTDecodeError.invalidFormat }
        let payload = parts[1]
        var base64 = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddedLength = base64.count + (4 - (base64.count % 4)) % 4
        base64 = base64.padding(toLength: paddedLength, withPad: "=", startingAt: 0)

        guard let data = Data(base64Encoded: base64) else { throw JWTDecodeError.invalidBase64 }
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = json as? [String: Any] else { throw JWTDecodeError.invalidJson }
        return dict
    }

    static func expirationDate(from jwt: String) -> Date? {
        guard let payload = try? decodePayload(jwt) else { return nil }
        if let exp = payload["exp"] as? TimeInterval {
            return Date(timeIntervalSince1970: exp)
        }
        if let expString = payload["exp"] as? String, let expDouble = TimeInterval(expString) {
            return Date(timeIntervalSince1970: expDouble)
        }
        return nil
    }

    static func roles(from jwt: String) -> [String] {
        guard let payload = try? decodePayload(jwt) else { return [] }
        if let roles = payload["roles"] as? [String] { return roles }
        if let role = payload["role"] as? String { return [role] }
        if let rolesAny = payload["roles"] as? String {
            return rolesAny.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }
        return []
    }
}
