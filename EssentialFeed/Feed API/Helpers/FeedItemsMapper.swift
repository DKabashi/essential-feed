//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

final class FeedItemsMapper {
    static func map(_ data: Data, urlResponse: HTTPURLResponse) throws -> [FeedItem] {
        guard urlResponse.statusCode == 200 else {
            throw LoadFeedResultError.invalidData
        }

        guard let itemsResponse = try? JSONDecoder().decode(FeedItemResponse.self, from: data) else {
            throw LoadFeedResultError.invalidData
        }
        
        return itemsResponse.items.map { $0.item }
    }
}
