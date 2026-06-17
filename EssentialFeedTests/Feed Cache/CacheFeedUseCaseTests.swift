
import XCTest
import EssentialFeed

class FeedStore {
    private(set) var deleteCachedFeedCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCount += 1
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
    
    private func makeSut() -> (sut: LocalFeedLoader, store: FeedStore) {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore)
        
        return (sut: sut, store: feedStore)
    }
    
    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}

