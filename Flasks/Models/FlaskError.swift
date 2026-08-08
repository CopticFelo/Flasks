import Foundation
import Subprocess

enum FlaskError {
    case fileError(detail: CocoaError)
    case processError(detail: SubprocessError)
    case wineError(detail: String)
    case networkError(detail: URLError)
    case serverError(code: Int)
    case invalidResponseError
    case unknownError
}

extension FlaskError: LocalizedError {
    var errorDescription: String? {
        switch self {
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
