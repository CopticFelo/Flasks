import Foundation
import Subprocess

enum FlaskError: Identifiable {
    case formError(description: String)
    case fileError(detail: CocoaError)
    case processError(detail: SubprocessError)
    case wineError(detail: String)
    case networkError(detail: URLError)
    case serverError(code: Int)
    case invalidResponseError
    case unknownError

    var id: String {
        switch self {
        case .formError:
            return "formError"
        case .fileError(let detail):
            return "fileError_\(detail.errorCode)"
        case .processError(let detail):
            return "processError_\(detail)"
        case .wineError(let detail):
            return "wineError_\(detail)"
        case .networkError(let detail):
            return "networkError_\(detail.errorCode)"
        case .serverError(let code):
            return "serverError_\(code)"
        case .invalidResponseError:
            return "invalidResponseError"
        case .unknownError:
            return "unknownError"
        }
    }
}

extension FlaskError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .formError(let desc): return desc
        case .fileError(let detail): return "File Error: \(detail.localizedDescription)"
        case .processError(let detail): return "Process Error: \(detail.localizedDescription)"
        case .wineError(let detail): return "Wine Error: \(detail)"
        case .networkError: return "Network Error"
        case .serverError(let code): return "Server Error: \(code)"
        case .invalidResponseError: return "invalid Response from Server"
        case .unknownError: return "Unknown Error"
        }
    }
    var recoverySuggestion: String? {
        switch self {
        case .wineError: return "Please check console logs for more details"
        case .networkError: return "Please check your internet connection"
        default: return "Please open an issue on https://github.com/CopticFelo/Flasks/issues"
        }
    }
}
