//
//  MoviesByCategoryRepositoryInterface.swift
//  Movies Explorer
//
//  Created by MacBook on 09.06.2023.
//

import Foundation

protocol MoviesByCategoryRepositoryInterface: AnyObject {
    func getMovies(by category: MoviesCategory, completion: @escaping (Result<[MoviePosterModel], Error>) -> Void)
    func getMoreMovies(completion: @escaping (Result<[MoviePosterModel], Error>) -> Void)
}
