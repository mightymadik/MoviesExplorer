//
//  MainPageViewModel.swift
//  Movies Explorer
//
//  Created by MacBook on 09.06.2023.
//

import Foundation

class MainPageViewModel {
    let repository: MoviesByCategoryRepositoryInterface
    private(set) var sections: [Section] = []
    private var group = DispatchGroup()
    private(set) var state: State = .loading {
        didSet {
            DispatchQueue.main.async {
                self.didStateChange?()
            }
        }
    }
 
    var didStateChange: (() -> Void)?
    var didGetError: ((String) -> Void)?
    
    enum State {
        case loading
        case content
    }
    
    enum Section: Comparable {
        case nowPlaying(movies: [MoviePosterModel])
        case popular(movies: [MoviePosterModel])
        case topRated(movies: [MoviePosterModel])
        case upcoming(movies: [MoviePosterModel])
        
        var title: String {
            switch self {
            case .nowPlaying:
                return "Now Playing"
            case .popular:
                return "Popular"
            case .topRated:
                return "Top Rated"
            case .upcoming:
                return "Upcoming"
            }
        }
        
        var orderValue: Int {
            switch self {
            case .nowPlaying:
                return 0
            case .popular:
                return 1
            case .topRated:
                return 2
            case .upcoming:
                return 3
            }
        }
        
        var moviesCategory: MoviesCategory {
            switch self {
            case .nowPlaying:
                return .nowPlaying
            case .popular:
                return .popular
            case .topRated:
                return .topRated
            case .upcoming:
                return .upcoming
            }
        }
        
        static func < (lhs: MainPageViewModel.Section, rhs: MainPageViewModel.Section) -> Bool {
            lhs.orderValue < rhs.orderValue
        }
        
        static func == (lhs: MainPageViewModel.Section, rhs: MainPageViewModel.Section) -> Bool {
            lhs.orderValue == rhs.orderValue
        }
    }
    
    var numberOfSections: Int {
        switch state {
        case .loading:
            return 4
        case .content:
            return sections.count
        }
    }
    
    init(repository: MoviesByCategoryRepositoryInterface) {
        self.repository = repository
    }
    
    func getAllCategoriesMovies() {
        state = .loading
        sections.removeAll(keepingCapacity: true)
        group.enter()
        repository.getMovies(by: .nowPlaying) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                self.sections.append(.nowPlaying(movies: movies))
                
                self.group.leave()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didGetError?(error.localizedDescription)
                }
                self.group.leave()
            }
        }
        
        group.enter()

        repository.getMovies(by: .popular) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                self.sections.append(.popular(movies: movies))
                
                self.group.leave()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didGetError?(error.localizedDescription)
                }
                self.group.leave()
            }
        }
        
        group.enter()
        repository.getMovies(by: .topRated) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                self.sections.append(.topRated(movies: movies))
                
                self.group.leave()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didGetError?(error.localizedDescription)
                }
                self.group.leave()
            }
        }
        
        group.enter()
        repository.getMovies(by: .upcoming) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                self.sections.append(.upcoming(movies: movies))
                
                self.group.leave()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didGetError?(error.localizedDescription)
                }
                self.group.leave()
            }
        }
        group.notify(queue: .main) {
            self.sections.sort()
            self.state = .content
        }
    }
    
    func getNumberOfItemIn(section: Int) -> Int {
        switch state {
        case .loading:
            return 4
        case .content:
            switch sections[section] {
            case .nowPlaying(let movies):
                return movies.count
            case .popular(let movies):
                return movies.count
            case .topRated(let movies):
                return movies.count
            case .upcoming(let movies):
                return movies.count
            }
        }
    }
}
