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
    
    func test_validateCache_doesNotDeleteCacheBeforeExpirationDate() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: date)
        
        let beforeExpirationTimestamp = date.minusFeedCacheMaxAge().addSeconds(1)
        sut.validateCache()
        feedStore.completeRetrivalWithFeedData(timestamp: beforeExpirationTimestamp, localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpirationDate() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: date)
        
        let expirationTimestamp = date.minusFeedCacheMaxAge()
        sut.validateCache()
        feedStore.completeRetrivalWithFeedData(timestamp: expirationTimestamp, localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesCacheAfterExpirationDate() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: Date())
        
        let afterExpirationTimestamp = date.minusFeedCacheMaxAge().addSeconds(-1)
        sut.validateCache()
        feedStore.completeRetrivalWithFeedData(timestamp: afterExpirationTimestamp, localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheAfterSUTInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, createTimestamp: Date.init)
        
        sut?.validateCache()
        sut = nil
        
        store.completeRetrivalWithError(anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
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
