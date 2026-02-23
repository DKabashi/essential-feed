//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

final class FeedItemsMapper {
    static func map(_ data: Data, urlResponse: HTTPURLResponse) -> LoadFeedResult {
        guard
            urlResponse.statusCode == 200,
            let itemsResponse = try? JSONDecoder().decode(FeedItemResponse.self, from: data)
        else {
            return .failure(LoadFeedResultError.invalidData)
        }
        
        return .success(itemsResponse.feed)
    }
}
