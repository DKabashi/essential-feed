//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

internal final class FeedItemsMapper {
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard
            response.statusCode == OK_200,
            let itemsResponse = try? JSONDecoder().decode(FeedItemResponse.self, from: data)
        else {
            throw APIError.invalidData
        }
        
        return itemsResponse.items
    }
}
