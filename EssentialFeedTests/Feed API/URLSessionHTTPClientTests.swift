import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
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

// end-to-end testing ❌
// subclass based testing
// protocol based testing
// URLProtocol stubbing

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsWithError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "http://any-url.com")!
        let expectedError = NSError(domain: "any err", code: 1)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: expectedError)
        let sut = URLSessionHTTPClient()
        
        let expectation = XCTestExpectation(description: "wait for task to complete")
        sut.get(from: url) { result in
            switch result {
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            default: XCTFail("Expected failure with \(expectedError), but got result \(result)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var receivedStubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            receivedStubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            receivedStubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return Self.receivedStubs[url] != nil
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = Self.receivedStubs[url] else {
                return
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func stopLoading() { }
        
    }
}
