import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedError: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: URLRequest(url: url)) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedError()))
            }
        }.resume()
    }
}

// end-to-end testing ❌
// subclass based testing
// protocol based testing
// URLProtocol stubbing

final class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        
        let expectation = XCTestExpectation(description: "Get request is perfomered and observer is called")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
       
        createSUT().get(from: url, completion: { _ in })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnInvalidRepresentationCases() {
        let anyUrlResponse = URLResponse()
        let anyHttpUrlResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let anyData = Data("any data".utf8)
        let anyError = NSError(domain: "", code: 0, userInfo: nil)
        
        XCTAssertNotNil(resultForRequestWith(data: nil, response: nil, error: nil).error)
        XCTAssertNotNil(resultForRequestWith(data: nil, response: anyUrlResponse, error: nil).error)
        XCTAssertNotNil(resultForRequestWith(data: nil, response: anyHttpUrlResponse, error: nil).error)
        XCTAssertNotNil(resultForRequestWith(data: anyData, response: nil, error: nil).error)
        XCTAssertNotNil(resultForRequestWith(data: anyData, response: nil, error: anyError).error)
        XCTAssertNotNil(resultForRequestWith(data: nil, response: anyUrlResponse, error: anyError).error)
        XCTAssertNotNil(resultForRequestWith(data: nil, response: anyHttpUrlResponse, error: anyError).error)
        XCTAssertNotNil(resultForRequestWith(data: anyData, response: anyUrlResponse, error: anyError).error)
        XCTAssertNotNil(resultForRequestWith(data: anyData, response: anyHttpUrlResponse, error: anyError).error)
        XCTAssertNotNil(resultForRequestWith(data: anyData, response: anyUrlResponse, error: nil).error)
    }
    
    func test_getFromURL_failsWithError() {
        let expectedError = NSError(domain: "any err", code: 1)
        
        let result = resultForRequestWith(data: nil, response: nil, error: expectedError)
        
        XCTAssertEqual(result.error?.domain, expectedError.domain)
        XCTAssertEqual(result.error?.code, expectedError.code)
    }
    
    private func resultForRequestWith(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data?, response: URLResponse?, error: NSError?) {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        var requestResult: (data: Data?, response: URLResponse?, error: NSError?)
        
        let expectation = XCTestExpectation(description: "wait for task to complete")
        createSUT().get(from: anyURL()) { result in
            switch result {
            case .failure(let error): requestResult.error = error as NSError
            default: XCTFail("Expected failure, but got result \(result)", file: file, line: line)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        return requestResult
    }
    
    private func createSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
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
