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
                let result = RemoteFeedLoader.map(data: data, with: urlResponse)
                completion(result)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func map(data: Data, with response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.modelItems)
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    var modelItems: [FeedImage] {
        self.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}
