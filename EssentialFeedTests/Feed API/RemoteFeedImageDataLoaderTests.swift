import XCTest

final class RemoteFeedImageDataLoader {
    
    init(client: Any) {
        
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequests() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        checkForMemoryLeaks(for: client, file: file, line: line)
        return (sut, client)
    }

    final class HTTPClientSpy {
        private(set) var requestedURLs = [URL]()
        
    }
}
