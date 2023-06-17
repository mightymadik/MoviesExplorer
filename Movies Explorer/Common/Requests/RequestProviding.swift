//
//  RequestProviding.swift
//  Movies Explorer
//
//  Created by MacBook on 09.06.2023.
//

import Foundation

protocol RequestProviding {
    var urlRequest: URLRequest { get }
    var shouldAddAuthorizationToken: Bool { get }
}
