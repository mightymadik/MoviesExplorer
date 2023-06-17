//
//  MovieProductionCompanyModel.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import Foundation

struct MovieProductionCompanyModel: Decodable {
    let id: Int
    let logoURLPath: String?
    let name: String
    let originCountry: String
    
    enum codingKeys: String, CodingKey {
        case id
        case logoURLPath = "logoPath"
        case name
        case originCountry = "originCountry"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: codingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        logoURLPath = try container.decodeIfPresent(String.self, forKey: .logoURLPath)
        name = try container.decode(String.self, forKey: .name)
        originCountry = try container.decode(String.self, forKey: KeyedDecodingContainer<codingKeys>.Key.originCountry)
    }
}
