
import XCTest
import EssentialFeed

class FeedStore {
    private(set) var deleteCachedFeedCount = 0
    private(set) var insertFeedCacheCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCount += 1
    }
    
    func completeCacheDeletion(with error: NSError) {
        
    }
    
    func completeCacheDeletionWithSuccess() {
        insertFeedCacheCount += 1
    }
}

class LocalFeedLoader {
    var feedStore: FeedStore
    
    init(store: FeedStore) {
        feedStore = store
    }
    
    func save(items: [FeedItem]) {
        feedStore.deleteCachedFeed()
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
    
    func test_save_failedDeletionDoesNotIncreaseFeedCacheCount() {
        let (sut, feedStore) = makeSut()
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items: items)
        feedStore.completeCacheDeletion(with: anyNSError())
        
        XCTAssertEqual(feedStore.insertFeedCacheCount, 0)
    }
    
    func test_save_successfulDeletionIncreasesFeedCacheCount() {
        let (sut, feedStore) = makeSut()
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items: items)
        feedStore.completeCacheDeletionWithSuccess()
        
        XCTAssertEqual(feedStore.insertFeedCacheCount, 1)
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

