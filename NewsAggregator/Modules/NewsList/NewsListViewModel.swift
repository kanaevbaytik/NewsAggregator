import Foundation

final class NewsListViewModel {
    private(set) var articles: [NewsArticle] = []
    private(set) var filteredArticles: [NewsArticle] = []
    
    private var page = 1
    private var isLoading = false
    private var hasMoreData = true
    
    var onUpdate: (() -> Void)?
    
    // MARK: - Fetch News (Pagination)

    func fetchNews() {
        guard !isLoading, hasMoreData else { return }

        isLoading = true

        Task {
            do {
                let newArticles = try await APIService.shared.fetchNews(page: page)

                if newArticles.isEmpty {
                    hasMoreData = false
                }

                articles.append(contentsOf: newArticles)
                filteredArticles = articles
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
        let thresholdIndex = filteredArticles.count - 5
        if currentIndex >= thresholdIndex {
            fetchNews()
        }
    }

    // MARK: - Pull to Refresh

    func refreshNews(completion: @escaping () -> Void) {
        page = 1
        hasMoreData = true
        isLoading = true

        Task {
            do {
                let newArticles = try await APIService.shared.fetchNews(page: page)

                articles = newArticles
                filteredArticles = newArticles
                page += 1
                isLoading = false

                DispatchQueue.main.async {
                    self.onUpdate?()
                    completion()
                }
            } catch {
                isLoading = false
                print("Ошибка при обновлении новостей:", error)
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    // MARK: - Search

    func filter(with text: String) {
        if text.isEmpty {
            filteredArticles = articles
        } else {
            filteredArticles = articles.filter {
                $0.title?.localizedCaseInsensitiveContains(text) == true
            }
        }
        onUpdate?()
    }

    // MARK: - Access

    func article(at index: Int) -> NewsArticle {
        guard index < filteredArticles.count else {
            return NewsArticle(title: "Ошибка", link: nil, pubDate: nil, image_url: nil, description: "Индекс вне диапазона", creator: nil)
        }
        return filteredArticles[index]
    }

    var count: Int {
        filteredArticles.count
    }
}
