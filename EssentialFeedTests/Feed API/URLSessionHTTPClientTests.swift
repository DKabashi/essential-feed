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
        session.dataTask(with: URLRequest(url: url)) { _, _, _ in }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
// subclass based testing
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let dataTask = URLSessionDataTaskWithCounter()
        let url = URL(string: "http://any-url.com")!
        session.stub(url: url, dataTask: dataTask)
        
        sut.get(from: url)
        
        XCTAssertEqual(dataTask.counter, 1)
    }
    
    final class URLSessionSpy: URLSession {
        var receivedStubs = [URL: Stub]()
        
        struct Stub {
            let dataTask: URLSessionDataTask
        }
        
        func stub(url: URL, dataTask: URLSessionDataTask) {
            receivedStubs[url] = Stub(dataTask: dataTask)
        }
        
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            if let url = request.url, let stub = receivedStubs[url] {
                return stub.dataTask
            }
            
            return FakeURLSessionDataTask()
        }
    }
    
    // MARK: DataTasks
    final class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    
    final class URLSessionDataTaskWithCounter: URLSessionDataTask {
        var counter: Int = 0
        
        override func resume() {
            counter += 1
        }
    }
}
