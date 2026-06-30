import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotReciveAnyMessageUponCreation() {
        let (_, feedStore) = makeSut()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_load_requestsRetrival() {
        let (sut, feedStore) = makeSut()
        
        sut.loadFeed { _ in }
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_load_deliversErrorOnRetrivalFailure() {
        let (sut, feedStore) = makeSut()
        let expectedError = anyNSError()
        
        expect(sut, toCompleteWithResult: .failure(expectedError), when: {
            feedStore.completeRetrivalWithError(expectedError)
        })
    }
    
    func test_load_fetchesFeedDataFromCache() {
        let (sut, feedStore) = makeSut()
        
        let timestamp = Date()
        let localItems = [uniqueLocalFeedItem()]
        sut.loadFeed { _ in }
        
        feedStore.completeRetrivalWithFeedData(timestamp: timestamp, localItems: localItems)
        
        XCTAssertEqual(feedStore.receivedItems.count, 1)
        XCTAssertEqual(feedStore.receivedItems.first?.timestamp, timestamp)
        XCTAssertEqual(feedStore.receivedItems.first?.localItems, localItems)
    }
    
    func test_load_hasNoSideEffectsOnRetrivalFailure() {
        let (sut, feedStore) = makeSut()
        
        sut.loadFeed { _ in }
        feedStore.completeRetrivalWithError(anyNSError())
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, feedStore) = makeSut()
        
        sut.loadFeed { _ in }
        feedStore.completeRetrivalWithEmptyCache()
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsBeforeExpirationDate() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: date)
        
        let beforeExpirationTimestamp = date.minusFeedCacheMaxAge().addSeconds(1)
        sut.loadFeed { _ in }
        feedStore.completeRetrivalWithFeedData(timestamp: beforeExpirationTimestamp, localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpirationDate() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: date)
        
        let expirationDateTimestamp = date.minusFeedCacheMaxAge()
        sut.loadFeed { _ in }
        feedStore.completeRetrivalWithFeedData(timestamp: expirationDateTimestamp, localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsAfterExpirationDate() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: date)
        
        let expiredDateTimestamp = date.minusFeedCacheMaxAge().addSeconds(-1)
        sut.loadFeed { _ in }
        feedStore.completeRetrivalWithFeedData(timestamp: expiredDateTimestamp, localItems: [])
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_load_returnsNoFeedImagesWhenEmptyCacheData() {
        let date = Date()
        let (sut, feedStore) = makeSut(timestamp: date)
        
        expect(sut, toCompleteWithResult: .success([]), when: {
            feedStore.completeRetrivalWithEmptyCache()
        })
    }
    
    func test_load_returnsImageFeedAfterSuccessfulRetrival() {
        let (sut, feedStore) = makeSut()
        
        let localItems = [uniqueLocalFeedItem()]
        let feedImages = localItems.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
        
        expect(sut, toCompleteWithResult: .success(feedImages), when: {
            feedStore.completeRetrivalWithFeedData(timestamp: Date(), localItems: localItems)
        })
    }
    
    func test_load_doesNotReceiveCallbackOnInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, createTimestamp: Date.init)
        
        var receivedCallbacks = [FeedLoader.Result]()
        sut?.loadFeed { receivedCallbacks.append($0) }
        
        sut = nil
        store.completeRetrivalWithError(anyNSError())
        
        XCTAssertTrue(receivedCallbacks.isEmpty)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithResult expectedResult: LocalFeedLoader.LoadResult?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = XCTestExpectation(description: "Wait for load to finish")
        
        sut.loadFeed { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedResult)):
                XCTAssertEqual(receivedError as NSError, expectedResult as NSError, file: file, line: line)
            case let (.success(receivedItems), .success(expetedItems)):
                XCTAssertEqual(receivedItems, expetedItems, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult.debugDescription), but got \(receivedResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
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
