import Foundation
import Security

// MARK: - Keychain Service Implementation
final class KeychainService {
    static let shared = KeychainService()

    private init() {}
    
    // MARK: - Keychain Operations
    func save(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.unexpectedEncoding
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let statusUpdate = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if statusUpdate == errSecSuccess {
            return
        }

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func read(_ key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        guard let data = item as? Data, let str = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedEncoding
        }
        return str
    }

    func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecItemNotFound { return }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

