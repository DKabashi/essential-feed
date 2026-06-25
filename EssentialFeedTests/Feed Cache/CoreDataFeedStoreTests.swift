import XCTest
import EssentialFeed


class CoreDataFeedStore: FeedStore {
    
    func retrieve(completion: @escaping RetriveCompletion) {
        completion(.empty)
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        fatalError("Implement")
    }
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        fatalError("Implement")
    }
}

final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStoreTestSpecs {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CoreDataFeedStore()
        
        expect(sut, toRetriveWithResult: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {}
    func test_retrieve_deliversCachedDataOnNonEmptyCache() {}
    func test_retrieve_hasNoSideEffectsOnNonEmptyCacheRetrival() {}
    func test_retrieve_deliversFailureOnRetrivalError() {}
    func test_retrieve_hasNoSideEffectsOnFailedRetrival() {}
    func test_insert_deliversNoErrorOnEmptyCache() {}
    func test_insert_deliversNoErrorOnNonEmptyCache() {}
    func test_insert_overridesPreviouslyInsertedValues() {}
    func test_insert_deliversErrorOnFailedInsertion() {}
    func test_insert_hasNoSideEffectsOnFaliedInsertion() {}
    func test_deleteCachedFeed_deliversNoErrorOnEmptyCache() {}
    func test_deleteCachedFeed_hasNoSideEffectsOnEmptyCache() {}
    func test_deleteCachedFeed_deliversNoErrorOnNonEmptyCache() {}
    func test_deleteCachedFeed_emptiesThePreviouslyInsertedCache() {}
    func test_deleteCachedFeed_deliversErrorOnFailedDeletion() {}
    func test_deleteCachedFeed_hasNoSideEffectOnFaliedDeletion() {}
    func test_storeSideEffects_runSerially() {}
}
