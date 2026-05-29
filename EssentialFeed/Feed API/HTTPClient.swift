//
//  NetworkClient.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
