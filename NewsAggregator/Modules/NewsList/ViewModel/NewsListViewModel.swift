import Foundation

final class NewsListViewModel {

    // MARK: - Public

    let categories: [(title: String, key: String?)] = [
        ("Все", nil),
        ("Наука", "science"),
        ("Здоровье", "health"),
        ("Культура", "entertainment"),
        ("Бизнес", "business")
    ]

    private(set) var articles: [NewsArticle] = []
    private(set) var filteredArticles: [NewsArticle] = []
    private(set) var latestArticles: [NewsArticle] = []

    var onUpdate: (() -> Void)?

    // MARK: - Private

    private var currentCategory: String? = nil
    private var page = 1
    private var isLoading = false
    private var hasMoreData = true

    // MARK: - Public Methods

    func fetchNews() {
        loadNews()
    }

    func refreshNews(completion: @escaping () -> Void) {
        loadNews(reset: true, completion: completion)
    }

    func fetchMoreIfNeeded(currentIndex: Int) {
        let thresholdIndex = filteredArticles.count - 5
        if currentIndex >= thresholdIndex {
            loadNews()
        }
    }

    func setCategory(_ category: String?) {
        currentCategory = category
        loadNews(reset: true)
    }

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

    func article(at index: Int) -> NewsArticle {
        guard index < filteredArticles.count else {
            return NewsArticle(title: "Ошибка", link: nil, pubDate: nil, image_url: nil, description: "Индекс вне диапазона", creator: nil, keywords: nil)
        }
        return filteredArticles[index]
    }

    var count: Int {
        filteredArticles.count
    }
    
    func latestArticle(at index: Int) -> NewsArticle {
        guard index < latestArticles.count else {
            return NewsArticle(title: "Ошибка", link: nil, pubDate: nil, image_url: nil, description: "Индекс вне диапазона", creator: nil, keywords: nil)
        }
        return latestArticles[index]
    }

    var latestCount: Int {
        latestArticles.count
    }


    // MARK: - Private Methods

    private func loadNews(reset: Bool = false, completion: (() -> Void)? = nil) {
        if reset {
            page = 1
            hasMoreData = true
            articles = []
            filteredArticles = []
            onUpdate?()
        }

        guard !isLoading, hasMoreData else {
            completion?()
            return
        }

        isLoading = true

        Task {
            do {
                let newArticles = try await APIService.shared.fetchNews(page: page, category: currentCategory)
                
                if reset && currentCategory == nil {
                    latestArticles = newArticles
                }

                if newArticles.isEmpty {
                    hasMoreData = false
                }

                articles.append(contentsOf: newArticles)
                filteredArticles = articles
                page += 1

                DispatchQueue.main.async {
                    self.onUpdate?()
                    completion?()
                }

            } catch {
                print("❌ Ошибка при загрузке новостей:", error)
                DispatchQueue.main.async {
                    completion?()
                }
            }

            isLoading = false
        }
    }
}
