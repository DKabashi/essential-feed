import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotReciveAnyMessageUponCreation() {
        let (_, feedStore) = makeSut()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_load_requestsRetrival() {
        let (sut, feedStore) = makeSut()
        
        sut.load() { _ in }
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_load_deliversErrorOnRetrivalFailure() {
        let (sut, feedStore) = makeSut()
        
        let expectedError = anyNSError()
        
        let exp = XCTestExpectation(description: "Wait for load to finish")
        var receivedError: NSError?
        sut.load() { error in
            receivedError = error
            exp.fulfill()
        }
        feedStore.completeRetrivalWithError(expectedError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(expectedError, receivedError)
    }
    
    private func makeSut(timestamp: Date = .now, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, createTimestamp: {
            return timestamp
        })
        checkForMemoryLeaks(for: feedStore, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return (sut: sut, store: feedStore)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "", code: 0, userInfo: nil)
    }
}
