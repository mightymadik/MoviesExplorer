//
//  SearchMovieViewModel.swift
//  Movies Explorer
//
//  Created by MacBook on 16.06.2023.
//

import Foundation

class SearchMovieViewModel: ObservableObject {
    let repository: MovieSearchRepositoryInterface
    private var currentPage: Int = 1
    private var currentQuery: String?

    @Published var movies: [MoviePosterModel] = []
    @Published var state: State = .loading {
        didSet {
            DispatchQueue.main.async {
                self.didStateChange?()
            }
        }
    }

    func clearMovies() {
        movies = []
    }

    var navigationTitle: String {
        return "Search"
    }

    var didStateChange: (() -> Void)?
    var didGetError: ((String) -> Void)?

    enum State {
        case loading
        case content
    }

    init(repository: MovieSearchRepositoryInterface) {
        self.repository = repository
    }

    func searchMovies(with query: String) {
        currentPage = 1
        currentQuery = query
        state = .loading
        movies = []

        repository.search(by: query, page: currentPage) { [weak self] result in
            guard let self = self, let currentQuery = self.currentQuery, currentQuery == query else { return }
            switch result {
            case .success(let paginationModel):
                DispatchQueue.main.async {
                    self.movies = paginationModel.results
                    self.state = .content
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didGetError?(error.localizedDescription)
                    self.state = .content
                }
            }
        }
    }


    func refreshMovies(with query: String) {
        currentPage = 1
        currentQuery = query

        repository.search(by: query, page: currentPage) { [weak self] result in
            guard let self = self, let currentQuery = self.currentQuery, currentQuery == query else { return }
            switch result {
            case .success(let paginationModel):
                DispatchQueue.main.async {
                    self.movies = paginationModel.results
                    self.state = .content
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didGetError?(error.localizedDescription)
                    self.state = .content
                }
            }
        }
    }

    func loadMoreMovies() {
        guard state != .loading, let query = currentQuery else { return }

        currentPage += 1
        state = .loading

        repository.search(by: query, page: currentPage) { [weak self] result in
            guard let self = self, let currentQuery = self.currentQuery, currentQuery == query else { return }
            switch result {
            case .success(let paginationModel):
                self.movies.append(contentsOf: paginationModel.results)
                self.state = .content
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didGetError?(error.localizedDescription)
                    self.state = .content // Set state to content even on error to show partial results
                }
            }
        }
    }

    func getNumberOfItemsIn(section: Int) -> Int {
        switch state {
        case .loading:
            return 6
        case .content:
            return movies.count
        }
    }
}
