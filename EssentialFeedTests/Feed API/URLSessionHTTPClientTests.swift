import EssentialFeed
import XCTest

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
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
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyUrlResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyUrlResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHttpUrlResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyUrlResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHttpUrlResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyUrlResponse(), error: nil)))
    }
    
    func test_getFromURL_failsWithError() {
        let expectedError = anyNSError()
        
        let receivedError = resultErrorFor((data: nil, response: nil, error: expectedError))
        
        XCTAssertEqual(receivedError?.domain, expectedError.domain)
        XCTAssertEqual(receivedError?.code, expectedError.code)
    }
    
    func test_getFromURL_succeedsWithDataAndResponse() {
        let expectedData = anyData()
        let expectedResponse = anyHttpUrlResponse()
        
        let result = resultValueFor((data: expectedData, response: expectedResponse, error: nil))
        
        XCTAssertEqual(result?.data, expectedData)
        XCTAssertEqual(result?.response.url, expectedResponse.url)
        XCTAssertEqual(result?.response.statusCode, expectedResponse.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmptyDataAndResponseOnNilData() {
        let expectedResponse = anyHttpUrlResponse()
        
        let result = resultValueFor((data: nil, response: anyHttpUrlResponse(), error: nil))
        
        let emptyData = Data()
        
        XCTAssertEqual(result?.data, emptyData)
        XCTAssertEqual(result?.response.url, expectedResponse.url)
        XCTAssertEqual(result?.response.statusCode, expectedResponse.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        var receivedError: NSError?
        
        receivedError = resultErrorFor(nil, taskHandler: { $0.cancel() })
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch result {
        case .failure(let err):
            return err as NSError
        default:
            XCTFail("Expected failure but got result \(String(describing: result))")
            return nil
        }
    }
    
    private func resultValueFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch result {
        case .success((let data, let response)):
            return (data, response)
        default:
            XCTFail("Expected success but got result \(String(describing: result))")
            return nil
        }
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result? {
        values.map { URLProtocolStub.stub(data: $0.data, response: $0.response, error: $0.error) }
        
        var receivedResult: HTTPClient.Result?
        
        let expectation = XCTestExpectation(description: "wait for task to complete")
        taskHandler(
            createSUT().get(from: anyURL()) { result in
                receivedResult = result
                expectation.fulfill()
            }
        )
        wait(for: [expectation], timeout: 1)
        
        return receivedResult
    }

    // MARK: Factory methods

    private func createSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
    
    // MARK: URLProtocol Stub
    
    private class URLProtocolStub: URLProtocol {
        
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
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
            guard let stub = URLProtocolStub.stub else { return }

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
            
            URLProtocolStub.stub?.requestObserver?(request)
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func stopLoading() { }
        
    }
}
