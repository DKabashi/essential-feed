//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/10/26.
//

import Foundation

public struct FeedItem: Codable, Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
    
    // TODO: Not sure if I need this
//    public init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(UUID.self, forKey: .id)
//        self.description = try container.decodeIfPresent(String.self, forKey: .description)
//        self.location = try container.decodeIfPresent(String.self, forKey: .location)
//        let image = try container.decode(String.self, forKey: .imageURL)
//        guard let imageUrl = URL(string: image) else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.imageURL], debugDescription: "imageURL not converting to URL"))
//        }
//        self.imageURL = imageUrl
//    }
    
}
