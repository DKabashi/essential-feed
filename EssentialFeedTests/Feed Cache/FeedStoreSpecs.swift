import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversCachedDataOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCacheRetrival()
    
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedValues()
    
    func test_deleteCachedFeed_deliversNoErrorOnEmptyCache()
    func test_deleteCachedFeed_hasNoSideEffectsOnEmptyCache()
    func test_deleteCachedFeed_deliversNoErrorOnNonEmptyCache()
    func test_deleteCachedFeed_emptiesThePreviouslyInsertedCache()
    
    func test_storeSideEffects_runSerially()
}

protocol FailableRetrivalFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrivalError()
    func test_retrieve_hasNoSideEffectsOnFailedRetrival()
}

protocol FailableInsertionFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnFailedInsertion()
    func test_insert_hasNoSideEffectsOnFaliedInsertion()
}

protocol FailableDeletionFeedStoreSpecs: FeedStoreSpecs {
    func test_deleteCachedFeed_deliversErrorOnFailedDeletion()
    func test_deleteCachedFeed_hasNoSideEffectOnFaliedDeletion()
}

typealias FailableFeedStoreTestSpecs = FailableRetrivalFeedStoreSpecs & FailableInsertionFeedStoreSpecs & FailableDeletionFeedStoreSpecs
