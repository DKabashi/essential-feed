//
//  FeedItemResponse.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

public struct FeedItemResponse: Decodable {
    let items: [RemoteFeedItem]
    
    public init(items: [RemoteFeedItem]) {
        self.items = items
    }
}
