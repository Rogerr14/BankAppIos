import Foundation

protocol RequestInterceptor {
    func intercept(_ request: URLRequest, requiresAuth: Bool) async throws -> URLRequest
}

protocol ResponseInterceptor {
    func intercept(data: Data, response: HTTPURLResponse) async throws
}

@MainActor
protocol AccessTokenProviding: AnyObject { var accessToken: String? { get } }

struct AuthRequestInterceptor: RequestInterceptor {
    weak var tokenProvider: AccessTokenProviding?

    func intercept(_ request: URLRequest, requiresAuth: Bool) async throws -> URLRequest {
        guard requiresAuth else { return request }
        guard let token = await tokenProvider?.accessToken, !token.isEmpty else { throw APIError.unauthorized }
        var request = request
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct SessionResponseInterceptor: ResponseInterceptor {
    weak var session: SessionStore?

    func intercept(data: Data, response: HTTPURLResponse) async throws {
        guard response.statusCode == 401 else { return }
        await MainActor.run { session?.logout() }
        throw APIError.unauthorized
    }
}
