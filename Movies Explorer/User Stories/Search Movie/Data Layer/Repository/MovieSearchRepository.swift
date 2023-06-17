//
//  MovieSearchRepository.swift
//  Movies Explorer
//
//  Created by MacBook on 16.06.2023.
//

import Foundation

class MovieSearchRepository: MovieSearchRepositoryInterface {
    
    private let remoteDataSource: MovieSearchDataSource
    
    init(remoteDataSource: MovieSearchDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func search(by query: String, page: Int, completion: @escaping (Result<PaginationModel<MoviePosterModel>, Error>) -> Void) {
        remoteDataSource.searchMovies(by: query, page: page, completion: completion)
    }
}
