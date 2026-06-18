
import XCTest
import EssentialFeed

class FeedStore {
    typealias MessageCompletion = (NSError?) -> Void
    
    private var deletionCompletion: MessageCompletion?
    private var insertionCompletion: MessageCompletion?
    
    private(set) var receivedMessages = [FeedStoreAction]()
    
    enum FeedStoreAction: Equatable {
        case deleteCachedFeed
        case insert(items: [FeedItem], timestamp: Date)
    }
        
    func deleteCachedFeed(completion: @escaping MessageCompletion) {
        receivedMessages.append(.deleteCachedFeed)
        deletionCompletion = completion
    }
    
    func completeCacheDeletion(with error: NSError) {
        deletionCompletion?(error)
    }
    
    func completeCacheDeletionWithSuccess() {
        deletionCompletion?(nil)
    }
    
    func completeInsertion(with error: NSError) {
        insertionCompletion?(error)
    }
    
    func completeCacheInsertionWithSuccess() {
        insertionCompletion?(nil)
    }
    
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping MessageCompletion) {
        receivedMessages.append(.insert(items: items, timestamp: timestamp))
        insertionCompletion = completion
    }
}

class LocalFeedLoader {
    private var feedStore: FeedStore
    private var createTimestamp: () -> Date
    
    init(store: FeedStore, createTimestamp: @escaping () -> Date) {
        feedStore = store
        self.createTimestamp = createTimestamp
    }
    
    func save(items: [FeedItem], completion: @escaping (NSError?) -> Void) {
        feedStore.deleteCachedFeed { [unowned self] deletionError in
            if let error = deletionError {
                completion(error)
            } else {
                self.feedStore.insertItems(items, timestamp: createTimestamp(), completion: completion)
            }
        }
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, feedStore, _) = makeSut()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, feedStore, items) = makeSut()
        
        sut.save(items: items) { _ in }
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_failedDeletionDoesNotStoreItems() {
        let (sut, feedStore, items) = makeSut()
        
        sut.save(items: items) { _ in }
        feedStore.completeCacheDeletion(with: anyNSError())
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_capturesItemsWithTimestampAfterSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, feedStore, items) = makeSut(timestamp: timestamp)
        
        sut.save(items: items) { _ in }
        
        feedStore.completeCacheDeletionWithSuccess()
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed, .insert(items: items, timestamp: timestamp)])
    }
    
    func test_save_failedDeletionDoesNotStoreItemsAndReturnsError() {
        let (sut, feedStore, items) = makeSut()
        
        let expectedError = anyNSError()
        
        let receivedError = save(items: items, using: sut, deletionAction: {
            feedStore.completeCacheDeletion(with: expectedError)
        }, insertionAction: { })
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
        XCTAssertEqual(expectedError, receivedError)
    }
    
    func test_save_failedDInsertionReturnsError() {
        let timestamp = Date()
        let (sut, feedStore, items) = makeSut(timestamp: timestamp)
        
        let expectedError = anyNSError()
        
        let receivedError = save(items: items, using: sut, deletionAction: feedStore.completeCacheDeletionWithSuccess, insertionAction: {
            feedStore.completeInsertion(with: expectedError)
        })

        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed, .insert(items: items, timestamp: timestamp)])
        XCTAssertEqual(expectedError, receivedError)
    }
    
    func test_save_succeedsWithNoErrorAfterCacheInsertion() {
        let timestamp = Date()
        let (sut, feedStore, items) = makeSut(timestamp: timestamp)
        
        let receivedError = save(items: items, using: sut, deletionAction: feedStore.completeCacheDeletionWithSuccess, insertionAction: feedStore.completeCacheInsertionWithSuccess)
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed, .insert(items: items, timestamp: timestamp)])
        XCTAssertEqual(receivedError, nil)
    }
    
    func save(items: [FeedItem], using sut: LocalFeedLoader, deletionAction: @escaping () -> Void, insertionAction: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
        let expectation = XCTestExpectation(description: "Expect save to fail with error")
        var capturedError: NSError?
        sut.save(items: items) { error in
            capturedError = error
            expectation.fulfill()
        }
        
        deletionAction()
        insertionAction()
        
        wait(for: [expectation], timeout: 1.0)
        
        return capturedError
    }
    
    private func makeSut(timestamp: Date = .now, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore, items: [FeedItem]) {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore, createTimestamp: {
            return timestamp
        })
        checkForMemoryLeaks(for: feedStore, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return (sut: sut, store: feedStore, items: [uniqueFeedItem(), uniqueFeedItem()])
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

