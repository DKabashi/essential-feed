import EssentialFeed
import XCTest

protocol HTTPSession {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
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
// end-to-end testing ❌
// subclass based testing
// protocol based testing
    
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let session = HTTPSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let dataTask = URLSessionDataTaskWithCounter()
        let url = URL(string: "http://any-url.com")!
        session.stub(url: url, dataTask: dataTask)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(dataTask.counter, 1)
    }
    
    
    func test_getFromURL_failsWithError() {
        let session = HTTPSessionSpy()
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
    
    final class HTTPSessionSpy: HTTPSession {
        var receivedStubs = [URL: Stub]()
        
        struct Stub {
            let dataTask: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, dataTask: HTTPSessionTask, error: Error? = nil) {
            receivedStubs[url] = Stub(dataTask: dataTask, error: error)
        }
        
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask {
            if let url = request.url, let stub = receivedStubs[url] {
                completionHandler(nil, nil, stub.error)
                return stub.dataTask
            }
            
            return FakeURLSessionDataTask()
        }
    }
    
    // MARK: DataTasks
    final class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() { }
    }
    
    final class URLSessionDataTaskWithCounter: HTTPSessionTask {
        var counter: Int = 0
        
        func resume() {
            counter += 1
        }
    }
}
