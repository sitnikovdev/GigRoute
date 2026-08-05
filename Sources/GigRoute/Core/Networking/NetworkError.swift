import Foundation

enum NetworkError: Error, Equatable {
    case invalidRequest
    case transport(String)
    case invalidResponse
    case httpStatus(Int)
    case decoding(String)

    var localizedDescription: String {
        switch self {
        case .invalidRequest:
            return "Не удалось сформировать запрос."
        case .transport(let message):
            return "Ошибка сети: \(message)"
        case .invalidResponse:
            return "Некорректный ответ сервера."
        case .httpStatus(let code):
            return "Сервер вернул код \(code)."
        case .decoding(let message):
            return "Не удалось разобрать ответ: \(message)"
        }
    }
}
