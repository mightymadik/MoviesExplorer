//
//  MovieSearchRepositoryInterface.swift
//  Movies Explorer
//
//  Created by MacBook on 16.06.2023.
//

import Foundation

protocol MovieSearchRepositoryInterface: AnyObject {
    func search(by query: String, page: Int, completion: @escaping (Result<PaginationModel<MoviePosterModel>, Error>) -> Void)
}
