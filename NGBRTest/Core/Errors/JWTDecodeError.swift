import Foundation

// MARK: - JWT Decode Errors
enum JWTDecodeError: Error {
    case invalidFormat
    case invalidBase64
    case invalidJson
}
