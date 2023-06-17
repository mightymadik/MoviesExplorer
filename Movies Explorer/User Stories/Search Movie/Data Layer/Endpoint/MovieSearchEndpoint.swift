//
//  MovieSearchEndpoint.swift
//  Movies Explorer
//
//  Created by MacBook on 16.06.2023.
//

import Foundation

enum MovieSearchEndpoint {
    case search(query: String)
}

extension MovieSearchEndpoint: RequestProviding {
    
    var urlRequest: URLRequest {
        switch self {
        case .search(let query):
            guard let url = URL(string: Constants.apiHost + "/search/movie?query=\(query)&language=en-US") else {
                fatalError("Invalid URL")
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            return urlRequest
        }
    }
    
    var shouldAddAuthorizationToken: Bool {
        switch self {
        case .search:
            return true
        }
    }
}

