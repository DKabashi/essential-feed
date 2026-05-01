//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Donat Kabashi on 5/1/26.
//

import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: URLRequest(url: url)) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
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
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(dataTask.counter, 1)
    }
    
    
    func test_getFromURL_failsWithError() {
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let dataTask = URLSessionDataTaskWithCounter()
        let url = URL(string: "http://any-url.com")!
        let expectedError = NSError(domain: "any err", code: 1)
        session.stub(url: url, dataTask: dataTask, error: expectedError)
        
        let expectation = XCTestExpectation(description: "wait for task to complete")
        sut.get(from: url) { result in
            switch result {
            case .failure(let error as NSError):
                XCTAssertEqual(error, expectedError)
            default: XCTFail("Expected failure with \(expectedError), but got result \(result)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
    }
    
    final class URLSessionSpy: URLSession {
        var receivedStubs = [URL: Stub]()
        
        struct Stub {
            let dataTask: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, dataTask: URLSessionDataTask, error: Error? = nil) {
            receivedStubs[url] = Stub(dataTask: dataTask, error: error)
        }
        
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            if let url = request.url, let stub = receivedStubs[url] {
                completionHandler(nil, nil, stub.error)
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
