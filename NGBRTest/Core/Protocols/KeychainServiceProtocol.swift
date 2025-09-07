import Foundation

// MARK: - Keychain Service Protocol
protocol KeychainServiceProtocol {
    func save(_ data: String, for key: String) throws
    func read(_ key: String) throws -> String
    func delete(_ key: String) throws
}
