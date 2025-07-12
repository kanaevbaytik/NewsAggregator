import SafariServices
import UIKit

final class NewsDetailViewController: UIViewController {
    private let article: NewsArticle
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let sourceButton = UIButton(type: .system)
    
    private var isFavorite: Bool = false {
        didSet {
            updateFavoriteIcon()
        }
    }
    
    init(article: NewsArticle) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
        self.title = "Детали"
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
        isFavorite = FavoritesManager.shared.isFavorite(article)
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // ⚠️ ВАЖНО: добавляем stackView внутрь scrollView
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        // Элементы
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.numberOfLines = 0

        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .secondaryLabel

        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel

        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0

        sourceButton.setTitle("Читать в источнике", for: .normal)
        sourceButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        sourceButton.addTarget(self, action: #selector(openSource), for: .touchUpInside)

        // Добавляем в stackView
        [imageView, titleLabel, authorLabel, dateLabel, descriptionLabel, sourceButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        // Навбар кнопка
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
    }

    private func configure() {
        titleLabel.text = article.title
        authorLabel.text = "Автор: \(article.creator?.first ?? "неизвестен")"
        dateLabel.text = article.pubDate
        descriptionLabel.text = article.description
        
        if let imageURLString = article.image_url,
           let url = URL(string: imageURLString) {
            loadImage(from: url)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data , _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }
    @objc private func openSource() {
        guard let urlString = article.link, let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }

    private func updateFavoriteIcon() {
        let imageName = isFavorite ? "star.fill" : "star"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
    }

    @objc private func toggleFavorite() {
        FavoritesManager.shared.toggleFavorite(article)
        isFavorite.toggle()
    }
}
