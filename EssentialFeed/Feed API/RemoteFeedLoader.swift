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

public typealias RemoteFeedLoaderResult = Result<(Data, HTTPURLResponse), RemoteFeedLoader.Error>

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: NetworkClient
    
    public enum Error: Swift.Error {
        case connectivity, invalidData
    }
    public init(url: URL, client: NetworkClient) {
        self.url = url
        self.client = client
    }
    
    public func loadFeed(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(url: url) { response in
            switch response {
            case .success(let data, let urlResponse):
                guard urlResponse.statusCode == 200 else {
                    completion(.failure(Self.Error.invalidData))
                    return
                }

                guard let items = try? JSONDecoder().decode([FeedItem].self, from: data) else {
                    completion(.failure(Self.Error.invalidData))
                    return
                }
                
                completion(.success([]))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

