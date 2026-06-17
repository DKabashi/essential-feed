
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
        let feedStore = FeedStore()
        _ = LocalFeedLoader(store: feedStore)
        
        XCTAssertEqual(feedStore.deleteCachedFeedCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore)
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items: items)
        
        XCTAssertEqual(feedStore.deleteCachedFeedCount, 1)
    }
    
    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}

