//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/10/26.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
