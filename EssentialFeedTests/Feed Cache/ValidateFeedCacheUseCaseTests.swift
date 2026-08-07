import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotReciveAnyMessageUponCreation() {
        let (_, feedStore) = makeSut()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrivalError() {
        let (sut, feedStore) = makeSut()
        
        sut.validateCache { _ in }
        feedStore.completeRetrivalWithError(anyNSError())
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, feedStore) = makeSut()
        
        sut.validateCache { _ in }
        feedStore.completeRetrivalWithFeedData(timestamp: Date(), localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCacheBeforeExpirationDate() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: date)
        
        let beforeExpirationTimestamp = date.minusFeedCacheMaxAge().addSeconds(1)
        sut.validateCache { _ in }
        feedStore.completeRetrivalWithFeedData(timestamp: beforeExpirationTimestamp, localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpirationDate() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: date)
        
        let expirationTimestamp = date.minusFeedCacheMaxAge()
        sut.validateCache { _ in }
        feedStore.completeRetrivalWithFeedData(timestamp: expirationTimestamp, localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesCacheAfterExpirationDate() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: Date())
        
        let afterExpirationTimestamp = date.minusFeedCacheMaxAge().addSeconds(-1)
        sut.validateCache { _ in }
        feedStore.completeRetrivalWithFeedData(timestamp: afterExpirationTimestamp, localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheAfterSUTInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, createTimestamp: Date.init)
        
        sut?.validateCache { _ in }
        sut = nil
        
        store.completeRetrivalWithError(anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrival() {
        let (sut, store) = makeSut()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrivalWithError(anyNSError())
            store.completeCacheDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrival() {
        let (sut, store) = makeSut()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrivalWithError(anyNSError())
            store.completeCacheDeletionWithSuccess()
        })
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSut()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrivalWithEmptyCache()
        })
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let feed = [uniqueLocalFeedItem()]
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().addSeconds(1)
        let (sut, store) = makeSut(timestamp: fixedCurrentDate)
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrivalWithFeedData(timestamp: nonExpiredTimestamp, localItems: feed)
        })
    }
    
    func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
        let feed = [uniqueLocalFeedItem()]
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().addSeconds(-1)
        let (sut, store) = makeSut(timestamp: fixedCurrentDate)
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrivalWithFeedData(timestamp: expiredTimestamp, localItems: feed)
            store.completeCacheDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let feed = [uniqueLocalFeedItem()]
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().addSeconds(-1)
        let (sut, store) = makeSut(timestamp: fixedCurrentDate)
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrivalWithFeedData(timestamp: expiredTimestamp, localItems: feed)
            store.completeCacheDeletionWithSuccess()
        })
    }
    
    // MARK: Helpers
    
    private func makeSut(timestamp: Date = .now, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, createTimestamp: {
            return timestamp
        })
        checkForMemoryLeaks(for: feedStore, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return (sut: sut, store: feedStore)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
