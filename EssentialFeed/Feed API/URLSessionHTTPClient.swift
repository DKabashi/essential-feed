//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Donat Kabashi on 5/29/26.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedError: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                   return (data, response)
                } else {
                    throw UnexpectedError()
                }
            })
        }.resume()
    }
}
