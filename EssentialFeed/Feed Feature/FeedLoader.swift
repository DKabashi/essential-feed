//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/10/26.
//

import Foundation

public enum LoadFeedResult<AppError: Error> {
    case success([FeedItem])
    case failure(AppError)
}

public protocol FeedLoader {
    associatedtype AppError: Error
    func loadFeed(completion: @escaping (LoadFeedResult<AppError>) -> Void)
}
