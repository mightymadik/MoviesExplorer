//
//  MovieDetailRepository.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import Foundation

class MovieDetailRepository {
    private let dataSource: MovieDetailDataSource
    
    init(dataSource: MovieDetailDataSource) {
        self.dataSource = dataSource
    }
}

extension MovieDetailRepository: MovieDetailRepositoryInterface {
    func getMovie(by id: Int, completion: @escaping (Result <MovieDetailModel, Error>) -> Void)  {
        dataSource.getMovie(by: id, completion: completion)
    }
}
