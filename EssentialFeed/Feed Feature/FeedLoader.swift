//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/10/26.
//

import Foundation

public enum LoadFeedResult: Equatable {
    case success([FeedItem])
    case failure(LoadFeedResultError)
}

// TODO: PotentialREfactor here, as api and database may use different errors
public enum LoadFeedResultError: Error, Equatable {
    case connectivity, invalidData
}

public protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
