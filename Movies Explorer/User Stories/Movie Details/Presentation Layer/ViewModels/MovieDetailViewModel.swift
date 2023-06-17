//
//  MovieDetailViewModel.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import Foundation

class MovieDetailViewModel {
    
    private let id: Int
    private let repository: MovieDetailRepositoryInterface
    private (set) var state: State = .loading {
        didSet {
            DispatchQueue.main.async {
                self.didStateChange?()
            }
        }
    }
    private(set) var movieDetail: MovieDetailModel?
    private(set) var sections: [Section] = []
    
    var didStateChange: (() -> Void)?
    
    var numberOfSections: Int {
        switch state {
        case .loading:
            return 1
        case .content:
            return sections.count
        }
    }
    
    enum DetailSectionType {
        case image
        case info
        case overview
    }
    
    enum State {
        case loading
        case content
    }
    
    enum Section {
        case detail(types: [DetailSectionType])
        case production(companies:  [MovieProductionCompanyModel])
    }
    
    init(id: Int, repository: MovieDetailRepositoryInterface) {
        self.id = id
        self.repository = repository
    }
    
    func getMovie() {
        state = .loading
        repository.getMovie(by: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movieDetail):
                self.movieDetail = movieDetail
                let types: [DetailSectionType] = [.image, .info, .overview]
                self.sections = [.detail(types: types),
                                 .production(companies: movieDetail.productionCompanies)]
                self.state = .content
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func numberOfItemsIn(section: Int) -> Int {
        switch state {
        case .loading:
            return 1
        case .content:
            switch sections[section] {
            case .detail(let types):
                return types.count
            case .production(let companies):
                return companies.count
            }
        }
    }
}

