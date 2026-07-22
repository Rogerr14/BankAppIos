import Foundation

final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let requestInterceptors: [RequestInterceptor]
    private let responseInterceptors: [ResponseInterceptor]
    private let encoder = JSONEncoder()
    private let decoder: JSONDecoder

    init(baseURL: URL, session: URLSession = .shared, requestInterceptors: [RequestInterceptor] = [], responseInterceptors: [ResponseInterceptor] = []) {
        self.baseURL = baseURL
        self.session = session
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)
        if !endpoint.queryItems.isEmpty { components?.queryItems = endpoint.queryItems }
        guard let url = components?.url else { throw APIError.invalidRequest }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = endpoint.body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }
        for interceptor in requestInterceptors { request = try await interceptor.intercept(request, requiresAuth: endpoint.requiresAuth) }

        let data: Data
        let response: URLResponse
        do { (data, response) = try await session.data(for: request) }
        catch { throw APIError.transport("No fue posible conectar con el servidor.") }
        guard let http = response as? HTTPURLResponse else { throw APIError.transport("Respuesta HTTP inválida.") }
        for interceptor in responseInterceptors { try await interceptor.intercept(data: data, response: http) }

        let envelope: ServiceResult<Response>
        do { envelope = try decoder.decode(ServiceResult<Response>.self, from: data) }
        catch { throw APIError.decoding }
        guard (200..<300).contains(http.statusCode), envelope.success else {
            let detail = ([envelope.message].compactMap { $0 } + envelope.errors).joined(separator: "\n")
            throw APIError.server(status: http.statusCode, message: detail.isEmpty ? "Ocurrió un error inesperado." : detail)
        }
        guard let value = envelope.data else { throw APIError.emptyData }
        return value
    }

    func download(path: String, queryItems: [URLQueryItem]) async throws -> DownloadedFile {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.invalidRequest }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", forHTTPHeaderField: "Accept")
        for interceptor in requestInterceptors { request = try await interceptor.intercept(request, requiresAuth: true) }
        let (data, response): (Data, URLResponse)
        do { (data, response) = try await session.data(for: request) }
        catch { throw APIError.transport("No fue posible descargar el archivo.") }
        guard let http = response as? HTTPURLResponse else { throw APIError.transport("Respuesta HTTP inválida.") }
        for interceptor in responseInterceptors { try await interceptor.intercept(data: data, response: http) }
        guard (200..<300).contains(http.statusCode) else {
            let envelope = try? decoder.decode(ServiceResult<EmptyResponse>.self, from: data)
            throw APIError.server(status: http.statusCode, message: envelope?.message ?? "No fue posible exportar los movimientos.")
        }
        let disposition = http.value(forHTTPHeaderField: "Content-Disposition") ?? ""
        let rawName = disposition.components(separatedBy: "filename=").last?.trimmingCharacters(in: CharacterSet(charactersIn: "\"; ")) ?? "transactions.xlsx"
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
        let name = rawName.unicodeScalars.map { allowed.contains($0) ? Character(String($0)) : "_" }.reduce(into: "", { $0.append($1) })
        return DownloadedFile(data: data, fileName: name)
    }
}

struct DownloadedFile { let data: Data; let fileName: String }

private struct AnyEncodable: Encodable {
    private let encodeBlock: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { encodeBlock = wrapped.encode }
    func encode(to encoder: Encoder) throws { try encodeBlock(encoder) }
}
