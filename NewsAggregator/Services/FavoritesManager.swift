import Foundation

final class FavoritesManager {
    static let shared = FavoritesManager()

    private let key = "favoriteArticles"

    private init() {}

    func isFavorite(_ article: NewsArticle) -> Bool {
        guard let saved = getFavorites() else { return false }
        return saved.contains { $0.link == article.link }
    }

    func addToFavorites(_ article: NewsArticle) {
        var current = getFavorites() ?? []
        guard !current.contains(where: { $0.link == article.link }) else { return }
        current.append(article)
        saveFavorites(current)
    }

    func removeFromFavorites(_ article: NewsArticle) {
        guard var current = getFavorites() else { return }
        current.removeAll { $0.link == article.link }
        saveFavorites(current)
    }

    func toggleFavorite(_ article: NewsArticle) {
        if isFavorite(article) {
            removeFromFavorites(article)
        } else {
            addToFavorites(article)
        }
    }

    func getFavorites() -> [NewsArticle]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([NewsArticle].self, from: data)
    }

    private func saveFavorites(_ articles: [NewsArticle]) {
        if let data = try? JSONEncoder().encode(articles) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
