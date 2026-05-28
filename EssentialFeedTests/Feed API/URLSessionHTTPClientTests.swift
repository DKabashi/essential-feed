import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let url = URL(string: "http://wrong-url.com")!
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
        URLProtocolStub.stub(data: nil, response: nil, error: expectedError)
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
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
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
