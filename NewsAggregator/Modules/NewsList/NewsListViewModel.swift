import Foundation

final class NewsListViewModel {
    private(set) var articles: [NewsArticle] = []
    
    private var page = 1
    private var isLoading = false
    private var hasMoreData = true
    
    var onUpdate: (() -> Void)?
    
    func fetchNews() {
        guard !isLoading, hasMoreData else { return }

        isLoading = true

        Task {
            do {
                let newArticles = try await APIService.shared.fetchNews(page: page)

                if newArticles.isEmpty {
                    hasMoreData = false
                }

                self.articles.append(contentsOf: newArticles)
                page += 1
                isLoading = false

                DispatchQueue.main.async {
                    self.onUpdate?()
                }
            } catch {
                isLoading = false
                print("Ошибка при получении новостей:", error)
            }
        }
    }
    
    func fetchMoreIfNeeded(currentIndex: Int) {
        let thresholdIndex = articles.count - 5
        if currentIndex >= thresholdIndex {
            fetchNews()
        }
    }

    func article(at index: Int) -> NewsArticle {
        articles[index]
    }
    
    var count: Int {
        articles.count
    }
}
