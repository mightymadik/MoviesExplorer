//
//  SearchMovieViewController.swift
//  Movies Explorer
//
//  Created by MacBook on 16.06.2023.
//
import UIKit

class SearchMovieViewController: UIViewController {

    private let dataSource: MovieSearchRemoteDataSource
    private let viewModel: SearchMovieViewModel
    private var collectionView: UICollectionView!
    private let width = UIScreen.main.bounds.width - 32

    private var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        return control
    }()

    private var searchText: String?

    private let searchController: UISearchController = {
        let viewController = UISearchController(searchResultsController: nil)
        return viewController
    }()

    init(viewModel: SearchMovieViewModel) {
        self.viewModel = viewModel
        self.dataSource = MovieSearchRemoteDataSource(network: Network())
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        setupCollectionView()
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Search"
        navigationItem.searchController = searchController
        searchController.delegate = self
        searchController.searchBar.delegate = self
    }

    private func setupCollectionView() {
        let layout = generateLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.backgroundColor = .black
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        collectionView.register(MoviePosterCollectionViewCell.self, forCellWithReuseIdentifier: MoviePosterCollectionViewCell.identifier)
        collectionView.register(MovieSkeletonCollectionViewCell.self, forCellWithReuseIdentifier: MovieSkeletonCollectionViewCell.identifier)
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.identifier)
        collectionView.register(SectionSkeletonCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionSkeletonCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshMovies), for: .valueChanged)
    }

    @objc private func refreshMovies() {
        guard let searchText = searchText else { return }
        viewModel.refreshMovies(with: searchText)
    }

    private func bindViewModel() {
        viewModel.didStateChange = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SearchMovieViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.state {
        case .loading:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieSkeletonCollectionViewCell.identifier, for: indexPath) as? MovieSkeletonCollectionViewCell else {
                fatalError("Failed to dequeue MovieSkeletonCollectionViewCell")
            }
            return cell
        case .content:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviePosterCollectionViewCell.identifier, for: indexPath) as? MoviePosterCollectionViewCell else {
                fatalError("Failed to dequeue MoviePosterCollectionViewCell")
            }
            let movie = viewModel.movies[indexPath.row]
            cell.configure(movie: movie)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
}

// MARK: - UICollectionViewDelegate
extension SearchMovieViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = viewModel.movies[indexPath.row]
        let id = selectedMovie.id

        let network = Network()
        let dataSource = MovieDetailRemoteDataSource(network: network)
        let repository = MovieDetailRepository(dataSource: dataSource)
        let viewModel = MovieDetailViewModel(id: id, repository: repository)
        let viewController = MovieDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchMovieViewController: UICollectionViewDelegateFlowLayout {

    private func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .absolute(((width - 16) / 2) / 0.58))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(((width - 16) / 2) / 0.58) )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(16)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 6, trailing: 16)
        section.interGroupSpacing = 16

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - UISearchControllerDelegate
extension SearchMovieViewController: UISearchControllerDelegate {

}

// MARK: - UISearchBarDelegate
extension SearchMovieViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            collectionView.reloadData()
            return
        }

        self.searchText = searchText
        searchMovies(with: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        collectionView.reloadData()
    }

    private func searchMovies(with searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performMovieSearch), object: nil)
        self.perform(#selector(performMovieSearch), with: nil, afterDelay: 0.5)
    }

    @objc private func performMovieSearch() {
        guard let searchText = searchText else { return }
        viewModel.searchMovies(with: searchText)
    }
}
