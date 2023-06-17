//
//  URLRequest + Extension.swift
//  Movies Explorer
//
//  Created by MacBook on 09.06.2023.
//

import Foundation

extension URLRequest {
    mutating func addAuthorizationToken() {
        allHTTPHeaderFields = ["Authorization": "Bearer \(Constants.apiToken)"]
    }
}
