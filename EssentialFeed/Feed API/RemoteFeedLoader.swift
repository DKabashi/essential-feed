//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/11/26.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: NetworkClient
    
    public enum APIError: Error {
        case connectivity, invalidData
    }
    
    public typealias Result = LoadFeedResult<APIError>
    
    public init(url: URL, client: NetworkClient) {
        self.url = url
        self.client = client
    }
    
    public func loadFeed(completion: @escaping (Result) -> Void) {
        client.get(url: url) { [weak self] response in
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
