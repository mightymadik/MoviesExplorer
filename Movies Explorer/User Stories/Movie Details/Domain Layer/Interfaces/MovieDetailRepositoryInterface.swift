//
//  MovieDetailRepositoryInterface.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import Foundation

protocol MovieDetailRepositoryInterface: AnyObject {
    func getMovie(by id: Int, completion: @escaping (Result <MovieDetailModel, Error>) -> Void)
}
