//
//  NetworkClient.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

public protocol NetworkClient {
    func get(url: URL, completion: @escaping (RemoteFeedLoaderResult) -> Void)
}
