import Foundation

// MARK: - Keychain Errors
enum KeychainError: Error {
    case invalidData
    case saveFailed(status: OSStatus)
    case readFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
}
