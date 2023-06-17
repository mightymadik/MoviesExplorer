//
//  MovieDetailViewController.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    private let viewModel: MovieDetailViewModel
    private var collectionView: UICollectionView!
    private var width = UIScreen.main.bounds.width - 32
    
    init(viewModel: MovieDetailViewModel) {
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
        viewModel.getMovie()
    }
    
    private func setupUI() {
//        setupNavigationBar()
        setupCollectionView()
    }
    
    private func bindViewModel() {
        viewModel.didStateChange = { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.navigationItem.title = self.viewModel.movieDetail?.title ?? ""
        }
    }
    
//    private func setupNavigationBar() {
//
//    }
    
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
        collectionView.register(MovieDetailBackgroundImageCollectionViewCell.self, forCellWithReuseIdentifier: MovieDetailBackgroundImageCollectionViewCell.identifier)
        collectionView.register(MovieDetailInfoCollectionViewCell.self, forCellWithReuseIdentifier: MovieDetailInfoCollectionViewCell.identifier)
        collectionView.register(MovieDetailOverviewCollectionViewCell.self, forCellWithReuseIdentifier: MovieDetailOverviewCollectionViewCell.identifier)
        collectionView.register(MovieDetailProductionCompanyCollectionViewCell.self, forCellWithReuseIdentifier: MovieDetailProductionCompanyCollectionViewCell.identifier)
        collectionView.register(MovieSkeletonCollectionViewCell.self, forCellWithReuseIdentifier: MovieSkeletonCollectionViewCell.identifier)
        
        //        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: "contentHeader", withReuseIdentifier: SectionHeaderCollectionReusableView.identifier)
        //        collectionView.register(SectionSkeletonCollectionReusableView.self, forSupplementaryViewOfKind: "loadingHeader", withReuseIdentifier: SectionSkeletonCollectionReusableView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension MovieDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.state {
        case .loading:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieSkeletonCollectionViewCell.identifier, for: indexPath) as? MovieSkeletonCollectionViewCell else { fatalError() }
            return cell
        case .content:
            switch viewModel.sections[indexPath.section] {
            case .detail(let types):
                switch types[indexPath.row] {
                case .image:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieDetailBackgroundImageCollectionViewCell.identifier , for: indexPath) as? MovieDetailBackgroundImageCollectionViewCell else { fatalError() }
                    cell.configure(imageURLPath: viewModel.movieDetail?.imageURLPath ?? "")
                    return cell
                case .info:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieDetailInfoCollectionViewCell.identifier, for: indexPath) as? MovieDetailInfoCollectionViewCell else { fatalError() }
                    if let movieDetail = viewModel.movieDetail {
                        cell.configure(movieDetail: movieDetail)
                    }
                    return cell
                    
                case .overview:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieDetailOverviewCollectionViewCell.identifier, for: indexPath) as? MovieDetailOverviewCollectionViewCell else { fatalError() }
                    if let movieDetail = viewModel.movieDetail {
                        cell.configure(movieDetail: movieDetail)
                    }
                    return cell
                }
            case .production(let companies):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieDetailProductionCompanyCollectionViewCell.identifier, for: indexPath) as? MovieDetailProductionCompanyCollectionViewCell else { fatalError() }
                    cell.configure(productionCompany: companies[indexPath.row])
                return cell
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsIn(section: section)
    }
}

extension MovieDetailViewController: UICollectionViewDelegate {
    
}

extension MovieDetailViewController {
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int,
                                                                        layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            switch self.viewModel.state {
            case .loading:
                return self.loadingCellLayout()
            case .content:
                switch self.viewModel.sections[sectionIndex] {
                case .production:
                    return self.productionCellLayout()
                case .detail:
                    return self.detailCellLayout()
                }
            }
        }
        
        return layout
    }
    
    private func detailCellLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(220))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(220))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func productionCellLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(68),
                                              heightDimension: .estimated(100))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(100))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
    
    private func loadingCellLayout() -> NSCollectionLayoutSection {
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
