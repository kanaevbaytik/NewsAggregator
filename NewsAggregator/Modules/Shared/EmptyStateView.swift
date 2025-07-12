
import UIKit

final class EmptyStateView: UIView {
    private let imageView = UIImageView()
    private let messageLabel = UILabel()
    
    init(message: String, image: UIImage? = UIImage(systemName: "star")) {
        super.init(frame: .zero)
        setupUI(message: message, image: image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(message: String, image: UIImage?) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [imageView, messageLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 64),
            imageView.widthAnchor.constraint(equalToConstant: 64),
            
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
