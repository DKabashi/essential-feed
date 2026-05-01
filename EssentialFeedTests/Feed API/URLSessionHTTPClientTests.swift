//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Donat Kabashi on 5/1/26.
//

import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: URLRequest(url: url)) { _, _, _ in }
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
// subclass based testing
    
    func test_get_usesCorrectURL() {
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let url = URL(string: "http://any-url.com")!
        
        sut.get(from: url)
        
        XCTAssertEqual([url], session.receivedURLs)
    }
    
    final class URLSessionSpy: URLSession {
        var receivedURLs = [URL?]()
        
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(request.url)
            return FakeURLSessionDataTask()
        }
        
        class FakeURLSessionDataTask: URLSessionDataTask { }
    }
}
