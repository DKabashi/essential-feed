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
                do {
                    let items = try FeedItemsMapper.map(data, from: urlResponse)
                    completion(.success(items.modelItems))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    var modelItems: [FeedItem] {
        self.map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
