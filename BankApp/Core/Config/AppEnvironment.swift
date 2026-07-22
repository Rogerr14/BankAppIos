import Foundation

enum AppEnvironment: String {
    case dev = "DEV"
    case prod = "PROD"

    static var current: AppEnvironment {
        AppEnvironment(rawValue: Bundle.main.object(forInfoDictionaryKey: "APP_ENVIRONMENT") as? String ?? "DEV") ?? .dev
    }

    var baseURL: URL {
        let configured = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
        let fallback = self == .dev ? "http://localhost:5169" : "https://api.example.com"
        guard let url = URL(string: configured ?? fallback) else { preconditionFailure("API_BASE_URL inválida") }
        return url
    }
}

