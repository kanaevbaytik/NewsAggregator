import UIKit

final class NewsTableViewCell: UITableViewCell {

    static let identifier = "NewsTableViewCell"

    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .secondarySystemBackground
        iv.widthAnchor.constraint(equalToConstant: 80).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let rightStack = UIStackView()
    private let mainStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        rightStack.axis = .vertical
        rightStack.spacing = 6
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.addArrangedSubview(titleLabel)
        rightStack.addArrangedSubview(metaLabel)
        rightStack.addArrangedSubview(descriptionLabel)

        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .top
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(thumbnailImageView)
        mainStack.addArrangedSubview(rightStack)

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with article: NewsArticle) {
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        metaLabel.text = formatMeta(author: article.creator?.first, date: article.pubDate)

        if let urlStr = article.image_url, let url = URL(string: urlStr) {
            ImageLoader.shared.loadImage(from: url) { [weak self] image in
                self?.thumbnailImageView.image = image ?? UIImage(systemName: "photo")
            }
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
        }
    }

    private func formatMeta(author: String?, date: String?) -> String {
        var parts: [String] = []
        if let author = author { parts.append(author) }
        if let date = date {
            let formatted = DateFormatter.localizedString(from: ISO8601DateFormatter().date(from: date) ?? Date(), dateStyle: .medium, timeStyle: .none)
            parts.append(formatted)
        }
        return parts.joined(separator: " • ")
    }
}
