//
//  MovieSearchDataSource.swift
//  Movies Explorer
//
//  Created by MacBook on 16.06.2023.
//

import Foundation

protocol MovieSearchDataSource: AnyObject {
    func searchMovies(by query: String, page: Int, completion: @escaping (Result<PaginationModel<MoviePosterModel>, Error>) -> Void)
}

class MovieSearchRemoteDataSource {
    private let network: Network
    
    init(network: Network) {
        self.network = network
    }
}

extension MovieSearchRemoteDataSource: MovieSearchDataSource {
    func searchMovies(by query: String, page: Int, completion: @escaping (Result<PaginationModel<MoviePosterModel>, Error>) -> Void) {
        network.execute(MovieSearchEndpoint.search(query: query), completion: completion)
    }
}

