import Foundation

final class NewsListViewModel {
    private(set) var articles: [NewsArticle] = []
    
    var onUpdate: (() -> Void)?
    
    func fetchNews() {
        Task {
            do {
                let news = try await APIService.shared.fetchNews()
                self.articles = news
                DispatchQueue.main.async {
                    self.onUpdate?()
                }
            } catch {
                print("Ошибка при получении новостей:", error)
            }
        }
    }
    func article(at index: Int) -> NewsArticle {
        articles[index]
    }
    
    var count: Int {
        articles.count
    }
}
