//
//  FeedItemAPIModel.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

public struct FeedItemAPIModel: Codable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, image: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.image = image
    }
    
    public var item: FeedItem {
        return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
}
