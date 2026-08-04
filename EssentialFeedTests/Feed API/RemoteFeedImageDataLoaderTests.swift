import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private struct HTTPTaskWrapper: FeedImageDataLoaderTask {
        let wrapped: HTTPClientTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, urlResponse)):
                guard urlResponse.statusCode == 200, !data.isEmpty else {
                    completion(.failure(Error.invalidData))
                    return
                }

                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
        return HTTPTaskWrapper(wrapped: task)
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequests() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            client.completeRequest(with: anyNSError())
        }
    }
    
    func test_loadImageDataFromURL_deliversErrorOnNon200Response() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.completeRequest(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.completeRequest(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.completeRequest(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }
        
        sut = nil
        client.completeRequest(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_cancelLoadImageURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty)
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url])
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        checkForMemoryLeaks(for: client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    final class HTTPClientSpy: HTTPClient {
        /// Received requests
        private(set) var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        private(set) var cancelledURLs = [URL]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        private struct TaskSpy: HTTPClientTask {
            let callback: () -> Void
            
            func cancel() {
                callback()
            }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url: url, completion: completion))
            return TaskSpy { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func completeRequest(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func completeRequest(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
}
