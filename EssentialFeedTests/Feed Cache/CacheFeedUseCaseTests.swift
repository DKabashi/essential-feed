
import XCTest
import EssentialFeed

class FeedStore {
    typealias DeletionCompletion = (NSError?) -> Void
    
    private(set) var deleteCachedFeedCount = 0
    private(set) var capturedItems = [FeedItem]()
    
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
    
    func insertItems(_ items: [FeedItem]) {
        capturedItems = items
    }
}

class LocalFeedLoader {
    var feedStore: FeedStore
    
    init(store: FeedStore) {
        feedStore = store
    }
    
    func save(items: [FeedItem]) {
        feedStore.deleteCachedFeed { [weak self] error in
            // Why unowned here?
            guard let self = self else { return }
            
            if error == nil {
                self.feedStore.insertItems(items)
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
        
        XCTAssertEqual(feedStore.capturedItems, [])
        XCTAssertEqual(feedStore.deleteCachedFeedCount, 1)
    }
    
    func test_save_storeItemsAfterSuccessfulDeletion() {
        let (sut, feedStore) = makeSut()
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items: items)
        
        feedStore.completeCacheDeletionWithSuccess()
        
        XCTAssertEqual(feedStore.deleteCachedFeedCount, 1)
        XCTAssertEqual(feedStore.capturedItems, items)
    }
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore)
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

