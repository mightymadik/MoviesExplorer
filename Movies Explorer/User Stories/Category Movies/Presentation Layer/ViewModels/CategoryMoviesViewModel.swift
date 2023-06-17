//
//  CategoryMoviesViewModel.swift
//  Movies Explorer
//
//  Created by MacBook on 14.06.2023.
//

import Foundation

class CategoryMoviesViewModel {
    let repository: MoviesByCategoryRepositoryInterface
    private let moviesCategory: MoviesCategory
    private (set) var movies: [MoviePosterModel] = []
    
    private(set) var state: State = .loading {
        didSet {
            DispatchQueue.main.async {
                self.didStateChange?()
            }
        }
    }
    
    var navigationTitle: String {
        moviesCategory.title
    }
    
    var didStateChange: (() -> Void)?
    var didGetError: ((String) -> Void)?
    
    enum State {
        case loading
        case content
    }
    
    enum Section {
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
    }
    
    init(moviesCategory: MoviesCategory, repository: MoviesByCategoryRepositoryInterface) {
        self.moviesCategory = moviesCategory
        self.repository = repository
    }
    
    func getMovies() {
        state = .loading
        movies = []
        
        repository.getMovies(by: moviesCategory, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                self.movies = movies
                self.state = .content
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didGetError?(error.localizedDescription)
                }
            }
        })
    }
    
    func getMoreMovies() {
        repository.getMoreMovies(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                self.movies += movies
                self.state = .content
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didGetError?(error.localizedDescription)
                }
            }
        })
    }
    
    func getNumberOfItemIn(section: Int) -> Int {
        switch state {
        case .loading:
            return 6 
        case .content:
            return movies.count
        }
    }
}
