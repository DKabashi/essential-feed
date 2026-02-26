//
//  NetworkClient.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 2/20/26.
//

import Foundation

public typealias NetworkClientResult = Result<(Data, HTTPURLResponse), APIError>

public protocol NetworkClient {
    func get(url: URL, completion: @escaping (NetworkClientResult) -> Void)
}
