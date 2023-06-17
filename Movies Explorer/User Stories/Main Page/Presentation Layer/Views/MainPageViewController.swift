//
//  MainViewController.swift
//  Movies Explorer
//
//  Created by MacBook on 09.06.2023.
//

import UIKit

class MainPageViewController: UIViewController {
    private let viewModel: MainPageViewModel
    private var collectionView: UICollectionView!
    
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        return control
    }()
    
    init(viewModel: MainPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        getAllCategoriesMovies()
    }
    
    private func setupUI() {
        setupCollectionView()
        setupSearchButton()
    }
    
    private func setupSearchButton() {
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        searchButton.tintColor = .white
        navigationItem.rightBarButtonItem = searchButton
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
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
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: "contentHeader", withReuseIdentifier: SectionHeaderCollectionReusableView.identifier)
        collectionView.register(SectionSkeletonCollectionReusableView.self, forSupplementaryViewOfKind: "loadingHeader", withReuseIdentifier: SectionSkeletonCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        refreshControl.addTarget(self, action: #selector(getAllCategoriesMovies), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func bindViewModel() {
        viewModel.didStateChange = { [weak self] in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    @objc
    private func getAllCategoriesMovies() {
        viewModel.getAllCategoriesMovies()
    }
    
    @objc
    private func searchButtonTapped() {
        let network = Network()
        let dataSource = MovieSearchRemoteDataSource(network: network)
        let repository = MovieSearchRepository(remoteDataSource: dataSource)
        let viewModel = SearchMovieViewModel(repository: repository)
        let viewController = SearchMovieViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MainPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.state {
        case .loading:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieSkeletonCollectionViewCell.identifier, for: indexPath) as?
                    MovieSkeletonCollectionViewCell else { fatalError() }
            return cell
        case .content:
            var posterMovies: [MoviePosterModel] = []
            switch viewModel.sections[indexPath.section] {
            case .nowPlaying(let movies):
                posterMovies = movies
            case .popular(let movies):
                posterMovies = movies
            case .topRated(let movies):
                posterMovies = movies
            case .upcoming(let movies):
                posterMovies = movies
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviePosterCollectionViewCell.identifier, for: indexPath) as? MoviePosterCollectionViewCell else { fatalError() }
            cell.configure(movie: posterMovies[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getNumberOfItemIn(section: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }
}

extension MainPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case "contentHeader":
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderCollectionReusableView.identifier, for: indexPath)  as? SectionHeaderCollectionReusableView else { fatalError() }
            header.configure(title: viewModel.sections[indexPath.section].title, moviesCategory: viewModel.sections[indexPath.section ].moviesCategory)
            header.delegate = self 
            return header
        case "loadingHeader":
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionSkeletonCollectionReusableView.identifier, for: indexPath) as?
            SectionSkeletonCollectionReusableView else { fatalError() }
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard viewModel.state == .content else { return }
        var id: Int
        switch viewModel.sections[indexPath.section] {
        case .nowPlaying(let movies):
            id = movies[indexPath.row].id
        case .popular(let movies):
            id = movies[indexPath.row].id
        case .topRated(let movies):
            id = movies[indexPath.row].id
        case .upcoming(let movies):
            id = movies[indexPath.row].id
        }
        let network = Network()
        let dataSource = MovieDetailRemoteDataSource(network: network)
        let repository = MovieDetailRepository(dataSource: dataSource)
        let viewModel = MovieDetailViewModel(id: id, repository: repository)
        let viewController = MovieDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MainPageViewController {
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int,
                                                                        layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            return self.cellLayout()
        }
        
        return layout
    }
    
    private func cellLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(116),
                                              heightDimension: .absolute(200.9))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(200.9))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 6, trailing: 16)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let supplementarySize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .estimated(24))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: supplementarySize, elementKind: viewModel.state == .content ? "contentHeader" : "loadingHeader", alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }
}

extension MainPageViewController: SectionHeaderCollectionReusableViewDelegate {
    func didSeeAllButtonTapped(moviesCategory: MoviesCategory) {
        let viewModel = CategoryMoviesViewModel(moviesCategory: moviesCategory, repository: self.viewModel.repository)
        let viewController = CategoryMoviesViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
