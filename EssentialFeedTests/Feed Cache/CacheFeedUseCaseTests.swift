import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotReciveAnyMessageUponCreation() {
        let (_, feedStore) = makeSut()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, feedStore) = makeSut()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        sut.save(feed: items) { _ in }
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_failedDeletionDoesNotRequestInsertion() {
        let (sut, feedStore) = makeSut()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(feed: items) { _ in }
        feedStore.completeCacheDeletion(with: anyNSError())
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_capturesItemsWithTimestampAfterSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, feedStore) = makeSut(timestamp: timestamp)
        let items = [uniqueFeedItem()]
        let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        
        sut.save(feed: items) { _ in }
        
        feedStore.completeCacheDeletionWithSuccess()
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed, .insert(items: localItems, timestamp: timestamp)])
    }
    
    func test_save_failedDeletionDoesNotStoreItemsAndReturnsError() {
        let (sut, feedStore) = makeSut()
        
        let expectedError = anyNSError()
        expect(sut, toCompleteWithError: expectedError, when: {
            feedStore.completeCacheDeletion(with: expectedError)
        })
    }
    
    func test_save_failedInsertionReturnsError() {
        let timestamp = Date()
        let (sut, feedStore) = makeSut(timestamp: timestamp)
        
        let expectedError = anyNSError()
        
        expect(sut, toCompleteWithError: expectedError) {
            feedStore.completeCacheDeletionWithSuccess()
            feedStore.completeInsertion(with: expectedError)
        }
    }
    
    func test_save_succeedsWithNoErrorAfterCacheInsertion() {
        let timestamp = Date()
        let (sut, feedStore) = makeSut(timestamp: timestamp)
        
        expect(sut, toCompleteWithError: nil) {
            feedStore.completeCacheDeletionWithSuccess()
            feedStore.completeCacheInsertionWithSuccess()
        }
    }
    
    func test_save_doesNotReturnDeletionErrorAfterSUTIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, createTimestamp: Date.init)
        
        var receivedErrors = [LocalFeedLoader.SaveResult]()
        
        sut?.save(feed: [uniqueFeedItem()]) { error in
            receivedErrors.append(error)
        }
        
        sut = nil
        store.completeCacheDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func test_save_doesNotReturnInsertionErrorAfterSUTIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, createTimestamp: Date.init)
        
        var receivedErrors = [LocalFeedLoader.SaveResult]()
        
        sut?.save(feed: [uniqueFeedItem()]) { error in
            receivedErrors.append(error)
        }
        
        store.completeCacheDeletionWithSuccess()
        sut = nil
        
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = XCTestExpectation(description: "Expect save to fail with error")
        var capturedError: NSError?
        sut.save(feed: [uniqueFeedItem()]) { error in
            capturedError = error
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(capturedError, expectedError, file: file, line: line)
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

