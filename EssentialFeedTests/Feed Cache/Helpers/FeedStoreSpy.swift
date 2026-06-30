import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    private var deletionCompletion: DeleteCompletion?
    private var insertionCompletion: InsertionCompletion?
    private var retrieveCompletion: RetriveCompletion?
    
    private(set) var receivedMessages = [FeedStoreAction]()
    
    enum FeedStoreAction: Equatable {
        case deleteCachedFeed
        case insert(items: [LocalFeedImage], timestamp: Date)
        case retrieve
    }
    
    private(set) var receivedItems = [(timestamp: Date, localItems: [LocalFeedImage])]()
        
    func deleteCachedFeed(completion: @escaping DeleteCompletion) {
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
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(items: items, timestamp: timestamp))
        insertionCompletion = completion
    }
    
    func retrieve(completion: @escaping RetriveCompletion) {
        receivedMessages.append(.retrieve)
        retrieveCompletion = completion
    }
    
    func completeRetrivalWithError(_ error: NSError) {
        retrieveCompletion?(.failure(error))
    }
    
    func completeRetrivalWithEmptyCache() {
        retrieveCompletion?(.success(.empty))
    }
    
    func completeRetrivalWithFeedData(timestamp: Date, localItems: [LocalFeedImage]) {
        receivedItems.append((timestamp: timestamp, localItems: localItems))
        retrieveCompletion?(.success(.found(localItems, timestamp)))
    }
}
