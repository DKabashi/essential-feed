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

public typealias RemoteFeedLoaderResult = Result<HTTPURLResponse, RemoteFeedLoader.Error>

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
            case .success(let urlResponse):
                completion(.failure(Self.Error.invalidData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

