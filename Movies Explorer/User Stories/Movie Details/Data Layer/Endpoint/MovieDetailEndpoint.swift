//
//  MovieDetailEndpoint.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import Foundation

enum MovieDetailEndpoint {
    case getMovie(id: Int)
}

extension MovieDetailEndpoint: RequestProviding {
    var urlRequest: URLRequest {
        switch self {
        case .getMovie(let id):
            guard let url =  URL(string: Constants.apiHost + "/movie/\(id)?language=en-US") else { fatalError() }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            return urlRequest
        }
    }
    
    var shouldAddAuthorizationToken: Bool {
        switch self {
        case .getMovie:
            return true
        }
    }
}
