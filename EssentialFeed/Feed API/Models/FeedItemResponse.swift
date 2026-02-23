//
//  FeedItemResponse.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

public struct FeedItemResponse: Codable {
    let items: [FeedItemAPIModel]
    
    public var feed: [FeedItem] {
        items.map { $0.item }
    }
    
    public init(items: [FeedItemAPIModel]) {
        self.items = items
    }
}
