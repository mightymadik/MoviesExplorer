//
//  MovieDetailModel.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import Foundation

struct MovieDetailModel: Decodable {
    let id: Int
    let title: String
    let imageURLPath: String
    let releaseDate: String
    let duration: Int
    var voteAverage: Double?
    var popularity: Double?
    var overview: String
    var productionCompanies: [MovieProductionCompanyModel]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURLPath = "backdropPath"
        case releaseDate = "releaseDate"
        case duration = "runtime"
        case voteAverage = "voteAverage"
        case popularity
        case overview
        case productionCompanies = "productionCompanies"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        imageURLPath = try container.decodeIfPresent(String.self, forKey: .imageURLPath) ?? ""
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? ""
        duration = try container.decode(Int.self, forKey: .duration)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity)
        overview = try container.decode(String.self, forKey: .overview)
        productionCompanies = try container.decode([MovieProductionCompanyModel].self, forKey: .productionCompanies)
    }
}
