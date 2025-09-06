import Foundation

// MARK: - Keychain Errors
enum KeychainError: Error {
    case unexpectedEncoding
    case unhandledError(status: OSStatus)
}
