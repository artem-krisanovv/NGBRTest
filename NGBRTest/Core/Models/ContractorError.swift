import Foundation

enum ContractorError: Error, LocalizedError {
    case success
    
    var errorDescription: String? {
        switch self {
        case .success:
            return "Контрагент успешно создан"
        }
    }
}
