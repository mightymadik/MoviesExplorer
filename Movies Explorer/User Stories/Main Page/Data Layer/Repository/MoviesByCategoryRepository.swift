//
//  MoviesByCategoryRepository.swift
//  Movies Explorer
//
//  Created by MacBook on 09.06.2023.
//

import Foundation

class MoviesByCategoryRepository {
    private let remoteDataSource: MoviesByCategoryDataSource
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var category: MoviesCategory?
    
    init(remoteDataSource: MoviesByCategoryDataSource) {
        self.remoteDataSource = remoteDataSource
    }
}

extension MoviesByCategoryRepository: MoviesByCategoryRepositoryInterface {
    func getMovies(by category: MoviesCategory, completion: @escaping (Result<[MoviePosterModel], Error>) -> Void) {
        currentPage = 1
        self.category = category
        
        remoteDataSource.getMovies(by: category.rawValue, page: currentPage, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let paginationModel):
                self.totalPages = paginationModel.totalPages
                self.currentPage = paginationModel.page
                
                completion(.success(paginationModel.results))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getMoreMovies(completion: @escaping (Result<[MoviePosterModel], Error>) -> Void) {
        if currentPage > totalPages {
            completion(.success([]))
            return
        }
        
        guard let category = category else {
            completion(.failure(NSError(domain: "No Category", code: 0)))
            return
        }
       
        remoteDataSource.getMovies(by: category.rawValue, page: currentPage + 1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let paginationModel):
                self.totalPages = paginationModel.totalPages
                self.currentPage = paginationModel.page
                
                completion(.success(paginationModel.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
