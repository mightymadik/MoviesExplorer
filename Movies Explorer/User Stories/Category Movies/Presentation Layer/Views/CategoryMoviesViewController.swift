//
//  CategoryMoviesViewController.swift
//  Movies Explorer
//
//  Created by MacBook on 10.06.2023.
//

import UIKit

class CategoryMoviesViewController: UIViewController {
    
    private let viewModel: CategoryMoviesViewModel
    private var collectionView: UICollectionView!
    private let width = UIScreen.main.bounds.width - 32
    
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        return control
    }()
    
    init(viewModel: CategoryMoviesViewModel) {
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
        getMovies()
    }
    
    private func setupUI() {
        setupCollectionView()
        navigationItem.title = viewModel.navigationTitle
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
        refreshControl.addTarget(self, action: #selector(getMovies), for: .valueChanged)
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
    private func getMovies() {
        viewModel.getMovies()
    }
}
extension CategoryMoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.state {
        case .loading:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieSkeletonCollectionViewCell.identifier, for: indexPath) as?
                    MovieSkeletonCollectionViewCell else { fatalError() }
            return cell
        case .content:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviePosterCollectionViewCell.identifier, for: indexPath) as? MoviePosterCollectionViewCell else { fatalError() }
            cell.configure(movie: viewModel.movies[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getNumberOfItemIn(section: section)
    }
}

extension CategoryMoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row == viewModel.movies.count - 4 else { return }
        viewModel.getMoreMovies()
    }
    
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

extension CategoryMoviesViewController {
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int,
                                                                        layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            return self.cellLayout()
        }
        
        return layout
    }
    
    private func cellLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .absolute(((width - 16) / 2) / 0.58))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(((width - 16) / 2) / 0.58) )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 6, trailing: 16)
        section.interGroupSpacing = 16
        return section
    }
}

