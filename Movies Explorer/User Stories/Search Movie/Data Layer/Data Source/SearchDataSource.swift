//
//  SearchDataSource.swift
//  Movies Explorer
//
//  Created by MacBook on 19.06.2023.
//

import Foundation

protocol SearchDataSource: AnyObject {
    func getMovies(by query: String, page: Int, completion: @escaping(Result<PaginationModel<MoviePosterModel>, Error>) -> Void)
}

class SearchRemoteDataSource {
    private let network: Network
    
    init(network: Network) {
        self.network = network
    }
}

extension SearchRemoteDataSource: SearchDataSource {
    func getMovies(by query: String, page: Int, completion: @escaping (Result<PaginationModel<MoviePosterModel>, Error>) -> Void) {
        network.execute(SearchEndpoint.movies(query: query, page: page), completion: completion)
    }
}
