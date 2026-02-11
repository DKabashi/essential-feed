//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/11/26.
//

import Foundation


protocol NetworkClient {
    func get(url: URL)
}

class RemoteFeedLoader: FeedLoader {
    let url: URL
    let client: NetworkClient
    
    init(url: URL, client: NetworkClient) {
        self.url = url
        self.client = client
    }
    
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(url: url)
    }
}

