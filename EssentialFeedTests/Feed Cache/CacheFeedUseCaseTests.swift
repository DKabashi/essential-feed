
import XCTest
import EssentialFeed

class FeedStore {
    typealias DeletionCompletion = (NSError?) -> Void
    
    private var deletionCompletion: DeletionCompletion?
    private(set) var receivedMessages = [FeedStoreAction]()
    
    enum FeedStoreAction: Equatable {
        case deleteCachedFeed
        case insert(items: [FeedItem], timestamp: Date)
    }
        
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        receivedMessages.append(.deleteCachedFeed)
        deletionCompletion = completion
    }
    
    func completeCacheDeletion(with error: NSError) {
        deletionCompletion?(error)
    }
    
    func completeCacheDeletionWithSuccess() {
        deletionCompletion?(nil)
    }
    
    func insertItems(_ items: [FeedItem], timestamp: Date) {
        receivedMessages.append(.insert(items: items, timestamp: timestamp))
    }
}

class LocalFeedLoader {
    private var feedStore: FeedStore
    private var createTimestamp: () -> Date
    
    init(store: FeedStore, createTimestamp: @escaping () -> Date) {
        feedStore = store
        self.createTimestamp = createTimestamp
    }
    
    func save(items: [FeedItem], didFailWithError: @escaping (NSError) -> Void) {
        feedStore.deleteCachedFeed { [unowned self] error in
            if let error = error {
                didFailWithError(error)
            } else {
                self.feedStore.insertItems(items, timestamp: createTimestamp())
            }
        }
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, feedStore) = makeSut()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, feedStore) = makeSut()
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items: items) { _ in }
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_failedDeletionDoesNotStoreItems() {
        let (sut, feedStore) = makeSut()
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        sut.save(items: items) { _ in }
        feedStore.completeCacheDeletion(with: anyNSError())
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_capturesItemsWithTimestampAfterSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, feedStore) = makeSut(timestamp: timestamp)
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items: items) { _ in }
        
        feedStore.completeCacheDeletionWithSuccess()
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed, .insert(items: items, timestamp: timestamp)])
    }
    
    func test_save_failedDeletionDoesNotStoreItemsAndReturnsError() {
        let (sut, feedStore) = makeSut()
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        let expectation = XCTestExpectation(description: "Expect save to complete with error")
        var capturedError: NSError?
        sut.save(items: items) { error in
            capturedError = error
            expectation.fulfill()
        }
        
        let error = anyNSError()
        feedStore.completeCacheDeletion(with: error)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
        XCTAssertEqual(capturedError, error)
    }
    
    private func makeSut(timestamp: Date = .now, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore, createTimestamp: {
            return timestamp
        })
        checkForMemoryLeaks(for: feedStore, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return (sut: sut, store: feedStore)
    }
    
    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "", code: 0, userInfo: nil)
    }
}

