
import Foundation
final class APIService {
    static let shared = APIService()
    private let apiKey = "pub_ac8db700d574477ab5586f0fb141c751"
    private let baseURL = "https://newsdata.io/api/1/news"
    
    private init() {}
    
    func fetchNews(page: Int = 1, category: String? = nil) async throws -> [NewsArticle] {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }

        var queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "language", value: "ru")
        ]

        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
        return decoded.results
    }

}
