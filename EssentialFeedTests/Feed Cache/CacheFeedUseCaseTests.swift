
import XCTest
import EssentialFeed

class FeedStore {
    typealias DeletionCompletion = (NSError?) -> Void
    
    private(set) var deleteCachedFeedCount = 0
    private(set) var capturedTimestampWithItems = [Date:[FeedItem]]()
    
    private var deletionCompletion: DeletionCompletion?
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCount += 1
        deletionCompletion = completion
    }
    
    func completeCacheDeletion(with error: NSError) {
        deletionCompletion?(error)
    }
    
    func completeCacheDeletionWithSuccess() {
        deletionCompletion?(nil)
    }
    
    func insertItems(_ items: [FeedItem], timestamp: Date) {
        capturedTimestampWithItems[timestamp] = items
    }
}

class LocalFeedLoader {
    private var feedStore: FeedStore
    private var createTimestamp: () -> Date
    
    init(store: FeedStore, createTimestamp: @escaping () -> Date) {
        feedStore = store
        self.createTimestamp = createTimestamp
    }
    
    func save(items: [FeedItem]) {
        feedStore.deleteCachedFeed { [weak self] error in
            // Why unowned here?
            guard let self = self else { return }
            
            if error == nil {
                self.feedStore.insertItems(items, timestamp: createTimestamp())
            }
        }
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, feedStore) = makeSut()
        
        XCTAssertEqual(feedStore.deleteCachedFeedCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, feedStore) = makeSut()
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items: items)
        
        XCTAssertEqual(feedStore.deleteCachedFeedCount, 1)
    }
    
    func test_save_failedDeletionDoesNotStoreItems() {
        let (sut, feedStore) = makeSut()
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        sut.save(items: items)
        feedStore.completeCacheDeletion(with: anyNSError())
        
        XCTAssertEqual(feedStore.capturedTimestampWithItems, [:])
        XCTAssertEqual(feedStore.deleteCachedFeedCount, 1)
    }
    
    func test_save_capturesItemsWithTimestampAfterSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, feedStore) = makeSut(timestamp: timestamp)
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items: items)
        
        feedStore.completeCacheDeletionWithSuccess()
        
        XCTAssertEqual(feedStore.deleteCachedFeedCount, 1)
        XCTAssertEqual(feedStore.capturedTimestampWithItems[timestamp], items)
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

