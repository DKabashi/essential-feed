//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/10/26.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
