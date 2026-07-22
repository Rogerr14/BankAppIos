import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidRequest
    case transport(String)
    case unauthorized
    case server(status: Int, message: String)
    case decoding
    case emptyData
    case unexpected

    var errorDescription: String? {
        switch self {
        case .invalidRequest: "No se pudo construir la solicitud."
        case .transport(let message): message
        case .unauthorized: "Tu sesión expiró. Inicia sesión nuevamente."
        case .server(_, let message): message
        case .decoding: "No se pudo interpretar la respuesta del servidor."
        case .emptyData: "El servidor no devolvió información."
        case .unexpected: "Ocurrió un error inesperado."
        }
    }
}
