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
        
        expect(sut, toCompleteWithResult: .failure(expectedError), when: {
            feedStore.completeRetrivalWithError(expectedError)
        })
    }
    
    func test_load_fetchesFeedDataFromCache() {
        let (sut, feedStore) = makeSut()
        
        let timestamp = Date()
        let localItems = [uniqueLocalFeedItem()]
        sut.load { _ in }
        
        feedStore.completeRetrivalWithFeedData(timestamp: timestamp, localItems: localItems)
        
        XCTAssertEqual(feedStore.receivedItems.count, 1)
        XCTAssertEqual(feedStore.receivedItems.first?.timestamp, timestamp)
        XCTAssertEqual(feedStore.receivedItems.first?.localItems, localItems)
    }
    
    func test_load_deliversNoErrorIfCacheIsLessThanSevenDaysOld() {
        let (sut, feedStore) = makeSut()
        
        let validTimestamp = Date().addingTimeInterval(60 * 60 * 24 * (sut.validExpireDays - 1))
        let localItems = [uniqueLocalFeedItem()]
        
        expect(sut, toCompleteWithResult: .success(nil), when: {
            feedStore.completeRetrivalWithFeedData(timestamp: validTimestamp, localItems: localItems)
        })
    }
    
    func test_load_requestsDataDeletionAndReturnsNoFeedImagesIfCacheExpired() {
        let (sut, feedStore) = makeSut()
        
        let expiredTimestamp = Date().addingTimeInterval(60 * 60 * 24 * -(sut.validExpireDays + 1))
        let localItems = [uniqueLocalFeedItem()]
        
        expect(sut, toCompleteWithResult: .success(nil), when: {
            feedStore.completeRetrivalWithFeedData(timestamp: expiredTimestamp, localItems: localItems)
            feedStore.completeCacheDeletionWithSuccess()
        })
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_load_returnsErrorWhenRequestsDataDeletionFails() {
        let (sut, feedStore) = makeSut()
        
        let expiredTimestamp = Date().addingTimeInterval(60 * 60 * 24 * -(sut.validExpireDays + 1))
        let localItems = [uniqueLocalFeedItem()]
        let expectedError = anyNSError()
        
        expect(sut, toCompleteWithResult: .failure(expectedError), when: {
            feedStore.completeRetrivalWithFeedData(timestamp: expiredTimestamp, localItems: localItems)
            feedStore.completeCacheDeletion(with: expectedError)
        })
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithResult expectedResult: LocalFeedLoader.LoadResult?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = XCTestExpectation(description: "Wait for load to finish")
        var receivedResult: LocalFeedLoader.LoadResult?
        
        sut.load { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
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
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func uniqueLocalFeedItem() -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), url: anyURL())
    }
}
