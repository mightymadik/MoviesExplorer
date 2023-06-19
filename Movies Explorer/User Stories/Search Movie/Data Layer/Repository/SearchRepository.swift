//
//  SearchRepository.swift
//  Movies Explorer
//
//  Created by MacBook on 19.06.2023.
//

import Foundation

class SearchRepository {
    private let remoteDataSource: SearchDataSource
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var query: String?
    
    init(remoteDataSource: SearchDataSource) {
        self.remoteDataSource = remoteDataSource
    }
}

extension SearchRepository: SearchRepositoryInterface {
    func getMovies(by query: String, completion: @escaping (Result<[MoviePosterModel], Error>) -> Void) {
        remoteDataSource.getMovies(by: query, page: currentPage, completion: { [weak self]
            result in
            guard let self = self else { return }
            switch result {
            case .success(let paginationModel):
                self.currentPage = paginationModel.page
                self.totalPages = paginationModel.totalPages
                self.query = query
                completion(.success(paginationModel.results))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    func getMoreMovies(completion: @escaping (Result<[MoviePosterModel], Error>) -> Void) {
        guard let query = query,
              currentPage <= totalPages else {
            completion.success([]))
            return
        }
        remoteDataSource.getMovies(by: query, page: currentPage + 1, completion: { [weak self]
            result in
            guard let self = self else { return }
            switch result {
            case .success(let paginationModel):
                self.currentPage = paginationModel.page
                self.totalPages = paginationModel.totalPages
                self.query = query
                completion(.success(paginationModel.results))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
