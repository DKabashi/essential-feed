import EssentialFeed
import XCTest

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        URLProtocolStub.removeStub()
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
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let urlSession = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: urlSession)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
}
