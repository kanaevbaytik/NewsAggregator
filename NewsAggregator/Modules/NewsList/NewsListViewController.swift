import UIKit

final class NewsListViewController: UIViewController {

    // MARK: - UI
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    private let viewModel = NewsListViewModel()

    private lazy var latestCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 160)
        layout.minimumLineSpacing = 12

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LatestNewsCollectionViewCell.self, forCellWithReuseIdentifier: LatestNewsCollectionViewCell.identifier)
        return collectionView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новости"
        view.backgroundColor = .systemBackground
        setupSearch()
        setupTableView()
        setupHeader()
        bindViewModel()
        viewModel.fetchNews()
    }

    // MARK: - Setup

    private func setupSearch() {
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Поиск"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupHeader() {
        let headerContainer = UIView()
        headerContainer.addSubview(latestCollectionView)

        latestCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            latestCollectionView.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            latestCollectionView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            latestCollectionView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            latestCollectionView.heightAnchor.constraint(equalToConstant: 180),
            latestCollectionView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -16)
        ])

        // 👇 Это важно
        let targetWidth = view.bounds.width
        let targetHeight: CGFloat = 212

        headerContainer.frame = CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
        headerContainer.layoutIfNeeded() // ⚠️ ОБЯЗАТЕЛЬНО: применяет constraints

        tableView.tableHeaderView = headerContainer
    }


    // MARK: - Logic

    @objc private func refreshNews() {
        viewModel.refreshNews {
            self.refreshControl.endRefreshing()
        }
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
            self?.latestCollectionView.reloadData()
        }
    }
}

// MARK: - TableView
extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = viewModel.article(at: indexPath.row)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: article)
        viewModel.fetchMoreIfNeeded(currentIndex: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = viewModel.article(at: indexPath.row)
        let vc = NewsDetailViewController(article: article)
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Search
extension NewsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(with: searchText)
    }
}

// MARK: - CollectionView
extension NewsListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(viewModel.count, 10)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LatestNewsCollectionViewCell.identifier, for: indexPath) as? LatestNewsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let article = viewModel.article(at: indexPath.row)
        cell.configure(with: article)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let article = viewModel.article(at: indexPath.row)
        let vc = NewsDetailViewController(article: article)
        navigationController?.pushViewController(vc, animated: true)
    }
}
