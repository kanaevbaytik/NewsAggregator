import UIKit

protocol CategoriesFilterViewDelegate: AnyObject {
    func didSelectCategory(key: String?)
}

final class CategoriesFilterView: UIView {
    
    var categories: [(title: String, key: String?)] = [] {
        didSet {
            selectedIndex = 0
            collectionView.reloadData()
        }
    }
    
    weak var delegate: CategoriesFilterViewDelegate?
    
    private var selectedIndex: Int = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        collection.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension CategoriesFilterView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.item]
        let isSelected = indexPath.item == selectedIndex
        cell.configure(title: category.title, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedIndex else { return }
        
        selectedIndex = indexPath.item
        collectionView.reloadData()
        
        let selectedCategoryKey = categories[selectedIndex].key
        delegate?.didSelectCategory(key: selectedCategoryKey)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = categories[indexPath.item].title
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: 32)
        let width = label.systemLayoutSizeFitting(targetSize).width + 24 // padding
        return CGSize(width: width, height: 32)
    }
}
