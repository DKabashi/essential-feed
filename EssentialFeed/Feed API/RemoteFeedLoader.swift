//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/11/26.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    // TODO: Check if you need this
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func loadFeed(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] response in
            guard self != nil else { return }
            switch response {
            case .success((let data, let urlResponse)):
                completion(FeedItemsMapper.map(data, urlResponse: urlResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
