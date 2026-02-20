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
                do {
                    let items = try FeedItemsMapper.map(data, urlResponse: urlResponse)
                    completion(.success(items))
                } catch {
                    let feedLoaderError = (error as? LoadFeedResultError) ?? .invalidData
                    completion(.failure(feedLoaderError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public class FeedItemsMapper {
    public struct FeedItemResponse: Codable {
        let items: [FeedItemAPIModel]
        
        public init(items: [FeedItemAPIModel]) {
            self.items = items
        }
    }

    public struct FeedItemAPIModel: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        public init(id: UUID, description: String? = nil, location: String? = nil, image: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.image = image
        }
        
        public var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static func map(_ data: Data, urlResponse: HTTPURLResponse) throws -> [FeedItem] {
        guard urlResponse.statusCode == 200 else {
            throw LoadFeedResultError.invalidData
        }

        guard let itemsResponse = try? JSONDecoder().decode(FeedItemResponse.self, from: data) else {
            throw LoadFeedResultError.invalidData
        }
        
        return itemsResponse.items.map { $0.item }
    }
}



