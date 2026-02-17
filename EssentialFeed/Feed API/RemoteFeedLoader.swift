//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/11/26.
//

import Foundation


public protocol NetworkClient {
    func get(url: URL, completion: @escaping (RemoteFeedLoaderResult) -> Void)
}

public typealias RemoteFeedLoaderResult = Result<(Data, HTTPURLResponse), LoadFeedResultError>

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: NetworkClient
    
    public init(url: URL, client: NetworkClient) {
        self.url = url
        self.client = client
    }
    
    public func loadFeed(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(url: url) { response in
            switch response {
            case .success((let data, let urlResponse)):
                guard urlResponse.statusCode == 200 else {
                    completion(.failure(.invalidData))
                    return
                }

                guard let itemsResponse = try? JSONDecoder().decode(FeedItemResponse.self, from: data) else {
                    completion(.failure(.invalidData))
                    return
                }
                
                completion(.success(itemsResponse.items))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public struct FeedItemResponse: Codable {
    let items: [FeedItem]
    
    public init(items: [FeedItem]) {
        self.items = items
    }
}

