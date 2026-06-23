import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotReciveAnyMessageUponCreation() {
        let (_, feedStore) = makeSut()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrivalError() {
        let (sut, feedStore) = makeSut()
        
        sut.validateCache()
        feedStore.completeRetrivalWithError(anyNSError())
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, feedStore) = makeSut()
        
        sut.validateCache()
        feedStore.completeRetrivalWithFeedData(timestamp: Date(), localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
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
}
